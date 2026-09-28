import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:ajudai/features/conversas/widgets/miniatura_anexo.dart';
import 'package:audio_waveforms/audio_waveforms.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared/shared.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import 'anexo_selecionado.dart';

/// Barra de digitação do chat.
///
/// Visual: campo em formato de pílula cinza (anexo à esquerda, câmera à
/// direita enquanto não há texto) e botão redondo vermelho de
/// enviar/gravar. Durante a gravação de áudio, a pílula vira o painel de
/// gravação (lixeira, tempo, waveform).
class Composer extends StatefulWidget {
  final TextEditingController controller;
  final bool enviando;
  final VoidCallback onAnexar;
  final List<AnexoSelecionado> anexos;
  final ValueChanged<AnexoSelecionado> onRemoverAnexo;
  final VoidCallback onEnviar;
  final ValueChanged<ArquivoUpload> onEnviarAudio;
  final ValueChanged<String>? onErro;
  final VoidCallback onCamera;

  const Composer({
    required this.controller,
    required this.enviando,
    required this.anexos,
    required this.onAnexar,
    required this.onRemoverAnexo,
    required this.onEnviar,
    required this.onEnviarAudio,
    this.onErro,
    required this.onCamera,
    super.key,
  });

  @override
  State<Composer> createState() => _ComposerState();
}

class _ComposerState extends State<Composer> {
  final _recorderController = RecorderController();

  bool _temTexto = false;
  bool _gravando = false;
  String? _caminhoGravacaoAtual;
  Duration _duracaoGravacao = Duration.zero;
  Timer? _timerGravacao;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_aoMudarTexto);
  }

  void _aoMudarTexto() {
    final temTexto = widget.controller.text.trim().isNotEmpty;
    if (temTexto != _temTexto) setState(() => _temTexto = temTexto);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_aoMudarTexto);
    _timerGravacao?.cancel();
    _recorderController.dispose();
    super.dispose();
  }

  Future<void> _iniciarGravacao() async {
    final temPermissao = await _recorderController.checkPermission();
    if (!temPermissao) {
      widget.onErro?.call(
        'É preciso permitir o uso do microfone para gravar áudio.',
      );
      return;
    }

    final diretorio = await getTemporaryDirectory();
    final caminho =
        '${diretorio.path}/gravacao_${DateTime.now().microsecondsSinceEpoch}.m4a';

    await _recorderController.record(
      path: caminho,
      recorderSettings: const RecorderSettings(
        androidEncoderSettings: AndroidEncoderSettings(
          androidEncoder: AndroidEncoder.aacLc,
        ),
        iosEncoderSettings: IosEncoderSetting(
          iosEncoder: IosEncoder.kAudioFormatMPEG4AAC,
        ),
        sampleRate: 44100,
      ),
    );

    if (!mounted) return;
    setState(() {
      _gravando = true;
      _caminhoGravacaoAtual = caminho;
      _duracaoGravacao = Duration.zero;
    });
    _timerGravacao = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      setState(() => _duracaoGravacao += const Duration(seconds: 1));
    });
  }

  Future<void> _cancelarGravacao() async {
    _timerGravacao?.cancel();
    await _recorderController.stop();
    final caminho = _caminhoGravacaoAtual;
    if (caminho != null) {
      final arquivo = File(caminho);
      if (await arquivo.exists()) await arquivo.delete();
    }
    if (!mounted) return;
    setState(() {
      _gravando = false;
      _caminhoGravacaoAtual = null;
    });
  }

  Future<void> _confirmarGravacao() async {
    _timerGravacao?.cancel();
    try {
      final caminho = await _recorderController.stop();
      final caminhoFinal = caminho ?? _caminhoGravacaoAtual;
      if (mounted) setState(() => _gravando = false);

      if (caminhoFinal == null) {
        widget.onErro?.call('Não foi possível salvar o áudio gravado.');
        return;
      }

      final arquivo = File(caminhoFinal);
      if (!await arquivo.exists()) {
        widget.onErro?.call(
          'O arquivo de áudio não foi encontrado após gravar.',
        );
        return;
      }

      final bytes = await arquivo.readAsBytes();
      if (bytes.isEmpty) {
        widget.onErro?.call('O áudio gravado ficou vazio.');
        return;
      }

      widget.onEnviarAudio(
        ArquivoUpload(
          nomeOriginal: 'audio.m4a',
          extensao: 'm4a',
          bytesBase64: base64Encode(bytes),
        ),
      );
      await arquivo.delete();
      if (mounted) setState(() => _caminhoGravacaoAtual = null);
    } catch (_) {
      if (mounted) setState(() => _gravando = false);
      widget.onErro?.call('Erro ao processar o áudio gravado.');
    }
  }

  String _formatarDuracao(Duration duracao) {
    final minutos = duracao.inMinutes.toString().padLeft(2, '0');
    final segundos = (duracao.inSeconds % 60).toString().padLeft(2, '0');
    return '$minutos:$segundos';
  }

  /// Botão redondo vermelho (enviar / gravar / enviar áudio).
  Widget _botaoPrincipal({
    required VoidCallback? onPressed,
    required Widget icon,
    required String tooltip,
  }) {
    return IconButton.filled(
      onPressed: onPressed,
      icon: icon,
      tooltip: tooltip,
      style: IconButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        disabledBackgroundColor: AppColors.outline,
        minimumSize: const Size(48, 48),
      ),
    );
  }

  Widget _painelGravacao() {
    return Row(
      children: [
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            decoration: BoxDecoration(
              color: AppColors.surfaceAlt,
              borderRadius: BorderRadius.circular(26),
            ),
            child: Row(
              children: [
                IconButton(
                  onPressed: widget.enviando ? null : _cancelarGravacao,
                  icon: const Icon(
                    Icons.delete_outline_rounded,
                    color: AppColors.primary,
                  ),
                  tooltip: 'Cancelar gravação',
                ),
                Container(
                  width: 8,
                  height: 8,
                  margin: const EdgeInsets.only(right: 8),
                  decoration: const BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                ),
                Text(
                  _formatarDuracao(_duracaoGravacao),
                  style: AppTextStyles.corpo.copyWith(
                    color: AppColors.textoTitulo,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: AudioWaveforms(
                    size: const Size(double.infinity, 36),
                    recorderController: _recorderController,
                    waveStyle: const WaveStyle(
                      waveColor: AppColors.primary,
                      extendWaveform: true,
                      showMiddleLine: false,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
              ],
            ),
          ),
        ),
        const SizedBox(width: 8),
        _botaoPrincipal(
          onPressed: widget.enviando ? null : _confirmarGravacao,
          icon: const Icon(Icons.send_rounded),
          tooltip: 'Enviar áudio',
        ),
      ],
    );
  }

  Widget _painelDigitacao(bool podeEnviarTexto) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.surfaceAlt,
              borderRadius: BorderRadius.circular(26),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                IconButton(
                  onPressed: widget.enviando ? null : widget.onAnexar,
                  icon: const Icon(
                    Icons.attach_file_rounded,
                    color: AppColors.textoSecundario,
                  ),
                  tooltip: 'Anexar imagem ou vídeo',
                ),
                Expanded(
                  child: TextField(
                    controller: widget.controller,
                    minLines: 1,
                    maxLines: 4,
                    cursorColor: AppColors.primary,
                    textCapitalization: TextCapitalization.sentences,
                    textInputAction: TextInputAction.newline,
                    style: AppTextStyles.corpo.copyWith(
                      color: AppColors.textoTitulo,
                      fontSize: 15,
                    ),
                    decoration: const InputDecoration(
                      hintText: 'Escreva uma mensagem',
                      hintStyle: TextStyle(
                        color: AppColors.textoSecundario,
                        fontSize: 15,
                      ),
                      border: InputBorder.none,
                      isDense: true,
                      contentPadding: EdgeInsets.symmetric(vertical: 14),
                    ),
                    onSubmitted: (_) => widget.onEnviar(),
                  ),
                ),
                if (!_temTexto)
                  IconButton(
                    onPressed: widget.enviando ? null : widget.onCamera,
                    icon: const Icon(
                      Icons.photo_camera_outlined,
                      color: AppColors.textoSecundario,
                    ),
                    tooltip: 'Câmera',
                  )
                else
                  const SizedBox(width: 12),
              ],
            ),
          ),
        ),
        const SizedBox(width: 8),
        _botaoPrincipal(
          onPressed: widget.enviando
              ? null
              : (podeEnviarTexto ? widget.onEnviar : _iniciarGravacao),
          icon: widget.enviando
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppColors.primary,
                  ),
                )
              : Icon(podeEnviarTexto ? Icons.send_rounded : Icons.mic_rounded),
          tooltip: podeEnviarTexto ? 'Enviar mensagem' : 'Gravar áudio',
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final podeEnviarTexto = _temTexto || widget.anexos.isNotEmpty;

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.outline)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (widget.anexos.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: SizedBox(
                    height: 110,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: widget.anexos.length,
                      separatorBuilder: (context, index) =>
                          const SizedBox(width: 8),
                      itemBuilder: (context, index) {
                        final anexo = widget.anexos[index];
                        return MiniaturaAnexo(
                          key: ValueKey(anexo.caminho),
                          anexo: anexo,
                          desabilitado: widget.enviando,
                          onRemover: () => widget.onRemoverAnexo(anexo),
                        );
                      },
                    ),
                  ),
                ),
              if (_gravando)
                _painelGravacao()
              else
                _painelDigitacao(podeEnviarTexto),
            ],
          ),
        ),
      ),
    );
  }
}
