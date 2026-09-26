import 'dart:async';
import 'dart:io';

import 'package:audio_waveforms/audio_waveforms.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/user_avatar.dart';

/// Bolha de mensagem de áudio: avatar de quem enviou, botão de play,
/// waveform do arquivo e duração — baixa o áudio pra um arquivo local
/// antes de preparar o player (audio_waveforms espera um caminho local).
class AudioMensagem extends StatefulWidget {
  final String? url;
  final String? avatarUrl;
  final bool minha;

  const AudioMensagem({
    required this.url,
    required this.avatarUrl,
    required this.minha,
    super.key,
  });

  @override
  State<AudioMensagem> createState() => _AudioMensagemState();
}

class _AudioMensagemState extends State<AudioMensagem> {
  final _playerController = PlayerController();
  StreamSubscription<PlayerState>? _estadoSub;
  StreamSubscription<int>? _duracaoSub;

  // `preparePlayer(shouldExtractWaveform: true)` dispara extração de
  // waveform NATIVA, em background, que continua rodando mesmo depois
  // do await retornar. Se o widget for descartado (usuário sai da tela)
  // antes dessa extração terminar, e o controller for disposed nesse
  // meio-tempo, a extração tenta parar um MediaCodec que já foi
  // liberado — daí o crash nativo "codec is released already". Essa
  // flag evita qualquer chamada ao controller depois que o widget já
  // foi desmontado.
  bool _disposed = false;

  bool _preparado = false;
  bool _falhaAoCarregar = false;
  bool _tocando = false;
  Duration _duracaoTotal = Duration.zero;
  Duration _duracaoAtual = Duration.zero;

  @override
  void initState() {
    super.initState();
    _estadoSub = _playerController.onPlayerStateChanged.listen((estado) {
      if (!mounted) return;
      setState(() => _tocando = estado == PlayerState.playing);
    });
    _duracaoSub = _playerController.onCurrentDurationChanged.listen((ms) {
      if (!mounted) return;
      setState(() => _duracaoAtual = Duration(milliseconds: ms));
    });
    _preparar();
  }

  Future<void> _preparar() async {
    final url = widget.url;
    if (url == null) {
      if (mounted) setState(() => _falhaAoCarregar = true);
      return;
    }
    try {
      final caminhoLocal = await _baixarArquivoTemporario(url);
      if (_disposed) return;

      await _playerController.preparePlayer(
        path: caminhoLocal,
        shouldExtractWaveform: true,
      );
      if (_disposed) return;

      final duracaoMs = await _playerController.getDuration(DurationType.max);
      if (!mounted || _disposed) return;
      setState(() {
        _preparado = true;
        _duracaoTotal = Duration(milliseconds: duracaoMs);
      });
    } catch (e) {
      if (mounted && !_disposed) setState(() => _falhaAoCarregar = true);
    }
  }

  Future<String> _baixarArquivoTemporario(String url) async {
    final resposta = await http.get(Uri.parse(url));

    if (resposta.statusCode != 200) {
      throw Exception('Falha ao baixar áudio: HTTP ${resposta.statusCode}');
    }
    final diretorio = await getTemporaryDirectory();
    final caminho =
        '${diretorio.path}/audio_${DateTime.now().microsecondsSinceEpoch}.m4a';
    await File(caminho).writeAsBytes(resposta.bodyBytes);
    return caminho;
  }

  String _formatarDuracao(Duration duracao) {
    final minutos = duracao.inMinutes.toString().padLeft(2, '0');
    final segundos = (duracao.inSeconds % 60).toString().padLeft(2, '0');
    return '$minutos:$segundos';
  }

  @override
  void dispose() {
    _disposed = true;
    _estadoSub?.cancel();
    _duracaoSub?.cancel();
    // Evita que uma exceção nativa (ex: extração de waveform ainda em
    // andamento tentando parar um codec já liberado) derrube o dispose
    // e, com ele, o resto da árvore de widgets sendo desmontada.
    try {
      _playerController.dispose();
    } catch (_) {
      // Ignorado de propósito: o controller já está sendo descartado
      // de qualquer forma; não há o que fazer aqui além de não
      // deixar a exceção subir.
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final duracaoExibida = _duracaoAtual > Duration.zero
        ? _duracaoAtual
        : _duracaoTotal;
    final corBase = widget.minha ? Colors.white : AppColors.primary;

    return SizedBox(
      width: 240,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          UserAvatar(avatarUrl: widget.avatarUrl, radius: 16),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: _preparado
                ? () {
                    _tocando
                        ? _playerController.pausePlayer()
                        : _playerController.startPlayer();
                  }
                : null,
            child: CircleAvatar(
              radius: 16,
              backgroundColor: widget.minha
                  ? Colors.white24
                  : AppColors.primary.withValues(alpha: 0.1),
              child: !_preparado
                  ? (_falhaAoCarregar
                        ? Icon(Icons.error_outline, size: 16, color: corBase)
                        : SizedBox(
                            width: 14,
                            height: 14,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: corBase,
                            ),
                          ))
                  : Icon(
                      _tocando ? Icons.pause : Icons.play_arrow,
                      size: 18,
                      color: corBase,
                    ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _preparado
                ? AudioFileWaveforms(
                    size: const Size(double.infinity, 32),
                    playerController: _playerController,
                    enableSeekGesture: true,
                    waveformType: WaveformType.fitWidth,
                    playerWaveStyle: PlayerWaveStyle(
                      fixedWaveColor: widget.minha
                          ? Colors.white54
                          : AppColors.primary.withValues(alpha: 0.3),
                      liveWaveColor: corBase,
                      spacing: 4,
                    ),
                  )
                : const SizedBox(height: 32),
          ),
          const SizedBox(width: 8),
          Text(
            _formatarDuracao(duracaoExibida),
            style: TextStyle(
              fontSize: 11,
              color: widget.minha ? Colors.white70 : AppColors.textoSecundario,
            ),
          ),
        ],
      ),
    );
  }
}
