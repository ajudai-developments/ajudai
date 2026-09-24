import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared/shared.dart';

import '../../core/errors/erro_mapper.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/error_banner.dart';
import '../../core/ws/ws_message_stream.dart';
import 'prestador_repository.dart';

/// Tela de solicitação para virar prestador.
///
class SolicitarPrestadorScreen extends StatefulWidget {
  const SolicitarPrestadorScreen({super.key});

  @override
  State<SolicitarPrestadorScreen> createState() =>
      _SolicitarPrestadorScreenState();
}

class _SolicitarPrestadorScreenState extends State<SolicitarPrestadorScreen> {
  final _prestadorRepository = PrestadorRepository();
  final _imagePicker = ImagePicker();

  bool _aceitaResponsabilidade = false;
  bool _aceitaPoliticaSuspensao = false;
  ArquivoUpload? _documentoSelecionado;

  bool _selecionandoDocumento = false;
  bool _enviando = false;
  String? _erro;

  bool get _podeConfirmar =>
      _documentoSelecionado != null &&
      _aceitaResponsabilidade &&
      _aceitaPoliticaSuspensao;

  Future<void> _solicitar() async {
    setState(() {
      _enviando = true;
      _erro = null;
    });

    try {
      final documento = _documentoSelecionado;
      if (documento == null) {
        setState(() {
          _erro = 'Envie a foto do documento para continuar.';
        });
        return;
      }

      await _prestadorRepository.solicitarPrestador(documento: documento);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Solicitação enviada! Vamos analisar em breve.'),
        ),
      );
      Navigator.of(context).pop();
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

  Future<void> _selecionarDocumento() async {
    setState(() {
      _selecionandoDocumento = true;
      _erro = null;
    });

    try {
      final origem = await showModalBottomSheet<ImageSource>(
        context: context,
        builder: (context) => SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.photo_camera_outlined),
                title: const Text('Tirar foto'),
                onTap: () => Navigator.of(context).pop(ImageSource.camera),
              ),
              ListTile(
                leading: const Icon(Icons.photo_library_outlined),
                title: const Text('Escolher da galeria'),
                onTap: () => Navigator.of(context).pop(ImageSource.gallery),
              ),
            ],
          ),
        ),
      );

      if (origem == null || !mounted) return;

      final arquivo = await _imagePicker.pickImage(
        source: origem,
        imageQuality: 85,
      );

      if (arquivo == null || !mounted) return;

      final bytes = await arquivo.readAsBytes();
      if (!mounted) return;

      if (bytes.isEmpty) {
        setState(() {
          _erro = 'Não foi possível ler a imagem selecionada.';
        });
        return;
      }

      if (bytes.length > 10 * 1024 * 1024) {
        setState(() {
          _erro = 'O documento deve ter no máximo 10 MB.';
        });
        return;
      }

      final partes = arquivo.name.split('.');
      final extensao = partes.length > 1 ? partes.last.toLowerCase() : 'jpg';

      setState(() {
        _documentoSelecionado = ArquivoUpload(
          nomeOriginal: arquivo.name,
          extensao: extensao.isEmpty ? 'jpg' : extensao,
          bytesBase64: base64Encode(bytes),
        );
      });
    } finally {
      if (mounted) setState(() => _selecionandoDocumento = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Quero ser prestador')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ErrorBanner(mensagem: _erro),
              Text(
                'Virar prestador',
                style: AppTextStyles.titulo,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                'Ao solicitar, sua conta passa por uma análise antes de '
                'poder oferecer serviços na plataforma. Você será avisado '
                'quando a análise terminar.',
                style: AppTextStyles.corpo,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              OutlinedButton.icon(
                onPressed: _enviando || _selecionandoDocumento
                    ? null
                    : _selecionarDocumento,
                icon: _selecionandoDocumento
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.upload_file_outlined),
                label: Text(
                  _documentoSelecionado == null
                      ? 'Enviar documento para análise'
                      : 'Trocar documento',
                ),
              ),
              if (_documentoSelecionado != null) ...[
                const SizedBox(height: 12),
                Text(
                  'Documento selecionado: ${_documentoSelecionado!.nomeOriginal}',
                  style: AppTextStyles.legenda,
                  textAlign: TextAlign.center,
                ),
              ],
              const SizedBox(height: 16),
              _consentimento(
                valor: _aceitaResponsabilidade,
                onChanged: (v) =>
                    setState(() => _aceitaResponsabilidade = v ?? false),
                texto:
                    'Entendo que sou responsabilizado por quaisquer danos '
                    'causados às propriedades dos clientes.',
              ),
              _consentimento(
                valor: _aceitaPoliticaSuspensao,
                onChanged: (v) =>
                    setState(() => _aceitaPoliticaSuspensao = v ?? false),
                texto:
                    'Entendo que, no caso de violação das diretrizes do '
                    'aplicativo, fico sujeito a ter o cargo de prestador '
                    'suspenso ou, no pior dos casos, ser banido da '
                    'plataforma Ajudaí.',
              ),
              const SizedBox(height: 24),
              AppButton(
                label: 'Confirmar solicitação',
                loading: _enviando,
                onPressed: _podeConfirmar && !_selecionandoDocumento
                    ? _solicitar
                    : null,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _consentimento({
    required bool valor,
    required ValueChanged<bool?> onChanged,
    required String texto,
  }) {
    return CheckboxListTile(
      value: valor,
      onChanged: onChanged,
      controlAffinity: ListTileControlAffinity.leading,
      contentPadding: EdgeInsets.zero,
      title: Text(texto, style: AppTextStyles.corpo),
    );
  }
}
