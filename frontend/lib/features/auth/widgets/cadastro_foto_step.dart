import 'dart:convert';
import 'dart:typed_data';

import 'package:ajudai/core/layout/responsivo.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/errors/erro_mapper.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/error_banner.dart';
import '../../../core/ws/ws_message_stream.dart';
import '../../usuario/usuario_repository.dart';

/// Passo 3 do cadastro: foto de perfil (opcional).
///
/// O usuário escolhe uma foto (câmera ou galeria), vê o preview e toca em
/// "Concluir" pra enviar via [UsuarioRepository.atualizarAvatar]. "Agora
/// não" pula o passo. Nos dois casos chama [onConcluir] no final.
class CadastroFotoStep extends StatefulWidget {
  final VoidCallback onConcluir;

  const CadastroFotoStep({super.key, required this.onConcluir});

  @override
  State<CadastroFotoStep> createState() => _CadastroFotoStepState();
}

class _CadastroFotoStepState extends State<CadastroFotoStep> {
  final _usuarioRepository = UsuarioRepository();
  final _imagePicker = ImagePicker();

  Uint8List? _bytes;
  String _extensao = 'jpg';
  bool _enviando = false;
  String? _erro;

  Future<void> _escolher(ImageSource origem) async {
    setState(() => _erro = null);

    final XFile? arquivo;
    try {
      arquivo = await _imagePicker.pickImage(
        source: origem,
        imageQuality: 85,
        maxWidth: 1024,
        maxHeight: 1024,
      );
    } catch (_) {
      if (!mounted) return;
      setState(() => _erro = 'Não foi possível abrir a câmera ou galeria.');
      return;
    }

    if (arquivo == null) return;

    final bytes = await arquivo.readAsBytes();
    if (!mounted) return;

    if (bytes.isEmpty) {
      setState(() => _erro = 'Não foi possível ler a imagem selecionada.');
      return;
    }

    final nome = arquivo.name;
    final extensao = nome.contains('.')
        ? nome.split('.').last.toLowerCase()
        : '';

    setState(() {
      _bytes = bytes;
      _extensao = extensao.isEmpty ? 'jpg' : extensao;
    });
  }

  Future<void> _mostrarOpcoes() async {
    if (kIsWeb) {
      await _escolher(ImageSource.gallery);
      return;
    }
    final origem = await showModalBottomSheet<ImageSource>(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: AppColors.outline,
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
              ListTile(
                leading: const Icon(
                  Icons.photo_camera_outlined,
                  color: AppColors.primary,
                ),
                title: const Text('Tirar foto'),
                onTap: () => Navigator.of(context).pop(ImageSource.camera),
              ),
              ListTile(
                leading: const Icon(
                  Icons.photo_library_outlined,
                  color: AppColors.primary,
                ),
                title: const Text('Escolher da galeria'),
                onTap: () => Navigator.of(context).pop(ImageSource.gallery),
              ),
            ],
          ),
        ),
      ),
    );

    if (origem != null) await _escolher(origem);
  }

  Future<void> _concluir() async {
    final bytes = _bytes;
    if (bytes == null) return;

    setState(() {
      _enviando = true;
      _erro = null;
    });

    try {
      await _usuarioRepository.atualizarAvatar(
        imagemBase64: base64Encode(bytes),
        extensao: _extensao,
      );

      if (!mounted) return;
      widget.onConcluir();
    } on WsErroException catch (e) {
      setState(() {
        _erro = ErroMapper.paraMensagem(e.codigo, mensagemServidor: e.mensagem);
      });
    } on WsTimeoutException {
      setState(() {
        _erro = 'Não foi possível conectar ao servidor. Tente novamente.';
      });
    } finally {
      if (mounted) setState(() => _enviando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final temFoto = _bytes != null;

    final corpo = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(height: 16),
        ErrorBanner(mensagem: _erro),
        const SizedBox(height: 8),
        _PreviewFoto(bytes: _bytes, onTap: _enviando ? null : _mostrarOpcoes),
        const SizedBox(height: 28),
        Text(
          'Adicione uma foto',
          textAlign: TextAlign.center,
          style: AppTextStyles.display.copyWith(fontSize: 24),
        ),
        const SizedBox(height: 10),
        Text(
          'Uma foto ajuda clientes e prestadores a se reconhecerem '
          'e passa mais confiança.',
          textAlign: TextAlign.center,
          style: AppTextStyles.corpo,
        ),
      ],
    );

    final acoes = <Widget>[
      if (temFoto) ...[
        AppButton(label: 'Concluir', loading: _enviando, onPressed: _concluir),
        const SizedBox(height: 10),
        AppOutlinedButton(
          label: 'Trocar foto',
          icone: Icons.photo_camera_outlined,
          onPressed: _enviando ? null : _mostrarOpcoes,
        ),
      ] else ...[
        AppButton(label: 'Escolher foto', onPressed: _mostrarOpcoes),
        const SizedBox(height: 8),
        TextButton(
          onPressed: widget.onConcluir,
          style: TextButton.styleFrom(
            foregroundColor: AppColors.textoSecundario,
          ),
          child: const Text('Agora não'),
        ),
      ],
    ];

    if (context.usaLayoutWeb) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [corpo, const SizedBox(height: 24), ...acoes],
      );
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(child: SingleChildScrollView(child: corpo)),
          const SizedBox(height: 16),
          ...acoes,
        ],
      ),
    );
  }
}

/// Avatar grande com o preview da foto escolhida e o selo de câmera.
class _PreviewFoto extends StatelessWidget {
  final Uint8List? bytes;
  final VoidCallback? onTap;

  const _PreviewFoto({required this.bytes, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final foto = bytes;

    return GestureDetector(
      onTap: onTap,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          CircleAvatar(
            radius: 72,
            backgroundColor: AppColors.surfaceAlt,
            backgroundImage: foto != null ? MemoryImage(foto) : null,
            child: foto == null
                ? const Icon(
                    Icons.person_rounded,
                    size: 72,
                    color: AppColors.textoSecundario,
                  )
                : null,
          ),
          Positioned(
            right: 0,
            bottom: 0,
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 3),
              ),
              child: const Icon(
                Icons.photo_camera_rounded,
                size: 20,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
