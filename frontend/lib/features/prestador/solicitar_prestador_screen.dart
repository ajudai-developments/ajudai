import 'dart:convert';
import 'dart:typed_data';

import 'package:ajudai/core/layout/responsivo.dart';
import 'package:ajudai/core/routes/app_routes.dart';
import 'package:ajudai/core/widgets/tela_adaptativa.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared/shared.dart';

import '../../core/errors/erro_mapper.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/error_banner.dart';
import '../../core/widgets/secao_card.dart';
import '../../core/ws/ws_message_stream.dart';
import 'prestador_repository.dart';

/// Tela de solicitação para virar prestador.
///
/// Mesmo padrão das demais telas: título grande, cartões de seção e botão
/// de confirmar fixo no rodapé. De cima pra baixo:
/// 1. apresentação (o que é ser prestador + vantagens);
/// 2. "Como funciona" em 3 passos;
/// 3. envio do documento (com prévia da foto escolhida);
/// 4. os dois termos de consentimento.
///
/// O botão só habilita com documento enviado e os dois termos aceitos.
class SolicitarPrestadorScreen extends StatefulWidget {
  const SolicitarPrestadorScreen({super.key});

  @override
  State<SolicitarPrestadorScreen> createState() =>
      _SolicitarPrestadorScreenState();
}

class _SolicitarPrestadorScreenState extends State<SolicitarPrestadorScreen> {
  static const _limiteBytes = 10 * 1024 * 1024;

  final _prestadorRepository = PrestadorRepository();
  final _imagePicker = ImagePicker();

  bool _aceitaResponsabilidade = false;
  bool _aceitaPoliticaSuspensao = false;
  ArquivoUpload? _documentoSelecionado;

  // Só pra mostrar a miniatura — o envio usa o base64 do ArquivoUpload.
  Uint8List? _previaDocumento;
  int _tamanhoDocumento = 0;

  bool _selecionandoDocumento = false;
  bool _enviando = false;
  String? _erro;

  bool get _podeConfirmar =>
      _documentoSelecionado != null &&
      _aceitaResponsabilidade &&
      _aceitaPoliticaSuspensao;

  Future<void> _solicitar() async {
    final documento = _documentoSelecionado;
    if (documento == null) {
      setState(() => _erro = 'Envie a foto do documento para continuar.');
      return;
    }

    setState(() {
      _enviando = true;
      _erro = null;
    });

    try {
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
        backgroundColor: AppColors.surface,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        builder: (context) => const _OrigemDocumentoSheet(),
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
        setState(() => _erro = 'Não foi possível ler a imagem selecionada.');
        return;
      }

      if (bytes.length > _limiteBytes) {
        setState(() => _erro = 'O documento deve ter no máximo 10 MB.');
        return;
      }

      final partes = arquivo.name.split('.');
      final extensao = partes.length > 1 ? partes.last.toLowerCase() : 'jpg';

      setState(() {
        _previaDocumento = bytes;
        _tamanhoDocumento = bytes.length;
        _documentoSelecionado = ArquivoUpload(
          nomeOriginal: arquivo.name,
          extensao: extensao.isEmpty ? 'jpg' : extensao,
          bytesBase64: base64Encode(bytes),
        );
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _erro = 'Não foi possível abrir a câmera ou galeria.');
    } finally {
      if (mounted) setState(() => _selecionandoDocumento = false);
    }
  }

  Widget _botaoConfirmar() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (!_podeConfirmar)
          const Padding(
            padding: EdgeInsets.only(bottom: 10),
            child: Text(
              'Envie o documento e aceite os dois termos para continuar.',
              style: AppTextStyles.legenda,
              textAlign: TextAlign.center,
            ),
          ),
        AppButton(
          label: 'Confirmar solicitação',
          loading: _enviando,
          onPressed: _podeConfirmar && !_selecionandoDocumento
              ? _solicitar
              : null,
        ),
      ],
    );
  }

  Widget _rodapeMobile() {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.outline)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
          child: _botaoConfirmar(),
        ),
      ),
    );
  }

  List<Widget> _filhos(bool ocupado) => [
    ErrorBanner(mensagem: _erro),

    // Apresentação
    Container(
      width: 56,
      height: 56,
      decoration: const BoxDecoration(
        color: AppColors.primarySoft,
        shape: BoxShape.circle,
      ),
      child: const Icon(
        Icons.workspace_premium_rounded,
        color: AppColors.primary,
        size: 28,
      ),
    ),
    const SizedBox(height: 16),
    const Text('Ofereça seus serviços no Ajudaí', style: AppTextStyles.display),
    const SizedBox(height: 6),
    const Text(
      'Sua conta passa por uma análise antes de poder oferecer '
      'serviços na plataforma. Você será avisado quando terminar.',
      style: AppTextStyles.corpo,
    ),
    const SizedBox(height: 20),

    const SecaoCard(
      child: Column(
        children: [
          _Beneficio(
            icone: Icons.event_available_rounded,
            texto: 'Receba pedidos de agendamento de clientes',
          ),
          SizedBox(height: 14),
          _Beneficio(
            icone: Icons.payments_outlined,
            texto: 'Defina o valor de cada serviço que você oferece',
          ),
          SizedBox(height: 14),
          _Beneficio(
            icone: Icons.star_rounded,
            texto: 'Ganhe avaliações, selos e destaque no perfil',
          ),
        ],
      ),
    ),
    const SizedBox(height: 24),

    // Como funciona
    const Text('Como funciona', style: AppTextStyles.titulo),
    const SizedBox(height: 12),
    const SecaoCard(
      child: Column(
        children: [
          _Passo(
            numero: 1,
            titulo: 'Envie seu documento',
            subtitulo: 'Uma foto nítida, para confirmarmos quem você é',
          ),
          _Passo(
            numero: 2,
            titulo: 'Análise da equipe',
            subtitulo: 'Verificamos as informações enviadas',
          ),
          _Passo(
            numero: 3,
            titulo: 'Comece a oferecer serviços',
            subtitulo: 'Você é avisado quando for aprovado',
            ultimo: true,
          ),
        ],
      ),
    ),
    const SizedBox(height: 24),

    // Documento
    const Text('Seu documento', style: AppTextStyles.titulo),
    const SizedBox(height: 12),
    _CartaoDocumento(
      documento: _documentoSelecionado,
      previa: _previaDocumento,
      tamanhoBytes: _tamanhoDocumento,
      carregando: _selecionandoDocumento,
      desabilitado: ocupado,
      onTap: _selecionarDocumento,
    ),
    const SizedBox(height: 24),

    // Termos
    const Text('Antes de continuar', style: AppTextStyles.titulo),
    const SizedBox(height: 12),
    _Consentimento(
      valor: _aceitaResponsabilidade,
      onChanged: (v) => setState(() => _aceitaResponsabilidade = v),
      texto:
          'Entendo que sou responsabilizado por quaisquer danos '
          'causados às propriedades dos clientes.',
    ),
    const SizedBox(height: 10),
    _Consentimento(
      valor: _aceitaPoliticaSuspensao,
      onChanged: (v) => setState(() => _aceitaPoliticaSuspensao = v),
      texto:
          'Entendo que, no caso de violação das diretrizes do '
          'aplicativo, fico sujeito a ter o cargo de prestador '
          'suspenso ou, no pior dos casos, ser banido da '
          'plataforma Ajudaí.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final web = context.usaLayoutWeb;
    final ocupado = _enviando || _selecionandoDocumento;

    return TelaAdaptativa(
      titulo: 'Quero ser prestador',
      rotaAtual: AppRoutes.meuPerfil,
      appBarMobile: AppBar(
        backgroundColor: AppColors.background,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleSpacing: 0,
        title: const Text('Quero ser prestador', style: AppTextStyles.titulo),
      ),
      rodapeMobile: web ? null : _rodapeMobile(),
      child: SafeArea(
        child: ConteudoCentralizado(
          larguraMax: 720,
          child: SingleChildScrollView(
            padding: web
                ? const EdgeInsets.fromLTRB(32, 24, 32, 40)
                : const EdgeInsets.fromLTRB(20, 8, 20, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ..._filhos(ocupado),
                if (web) ...[const SizedBox(height: 28), _botaoConfirmar()],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Uma vantagem de ser prestador: ícone em círculo suave + texto.
class _Beneficio extends StatelessWidget {
  final IconData icone;
  final String texto;

  const _Beneficio({required this.icone, required this.texto});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: const BoxDecoration(
            color: AppColors.primarySoft,
            shape: BoxShape.circle,
          ),
          child: Icon(icone, color: AppColors.primary, size: 18),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            texto,
            style: AppTextStyles.corpo.copyWith(color: AppColors.textoTitulo),
          ),
        ),
      ],
    );
  }
}

/// Passo numerado do "Como funciona", com a linha vertical ligando ao
/// próximo.
class _Passo extends StatelessWidget {
  final int numero;
  final String titulo;
  final String subtitulo;
  final bool ultimo;

  const _Passo({
    required this.numero,
    required this.titulo,
    required this.subtitulo,
    this.ultimo = false,
  });

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            width: 28,
            child: Column(
              children: [
                Container(
                  width: 28,
                  height: 28,
                  alignment: Alignment.center,
                  decoration: const BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    '$numero',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                if (!ultimo)
                  Expanded(
                    child: Container(width: 2, color: AppColors.outline),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: ultimo ? 0 : 18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    titulo,
                    style: AppTextStyles.corpo.copyWith(
                      color: AppColors.textoTitulo,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(subtitulo, style: AppTextStyles.legenda),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Área de envio do documento: vazia (convite pra enviar) ou com a
/// miniatura da foto escolhida, nome, tamanho e ação de trocar.
class _CartaoDocumento extends StatelessWidget {
  final ArquivoUpload? documento;
  final Uint8List? previa;
  final int tamanhoBytes;
  final bool carregando;
  final bool desabilitado;
  final VoidCallback onTap;

  const _CartaoDocumento({
    required this.documento,
    required this.previa,
    required this.tamanhoBytes,
    required this.carregando,
    required this.desabilitado,
    required this.onTap,
  });

  String _formatarTamanho(int bytes) {
    if (bytes < 1024 * 1024) return '${(bytes / 1024).round()} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1).replaceAll('.', ',')} MB';
  }

  @override
  Widget build(BuildContext context) {
    final enviado = documento != null;

    return InkWell(
      onTap: desabilitado ? null : onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: enviado ? AppColors.successSoft : AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: enviado ? AppColors.success : AppColors.outline,
            width: enviado ? 1.5 : 1,
          ),
        ),
        child: enviado ? _conteudoEnviado() : _conteudoVazio(),
      ),
    );
  }

  Widget _conteudoVazio() {
    return Column(
      children: [
        Container(
          width: 52,
          height: 52,
          decoration: const BoxDecoration(
            color: AppColors.primarySoft,
            shape: BoxShape.circle,
          ),
          child: carregando
              ? const Padding(
                  padding: EdgeInsets.all(15),
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppColors.primary,
                  ),
                )
              : const Icon(
                  Icons.upload_file_rounded,
                  color: AppColors.primary,
                  size: 26,
                ),
        ),
        const SizedBox(height: 12),
        Text(
          'Enviar documento para análise',
          style: AppTextStyles.corpo.copyWith(
            color: AppColors.textoTitulo,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 2),
        const Text(
          'Tire uma foto ou escolha da galeria (máx. 10 MB)',
          style: AppTextStyles.legenda,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _conteudoEnviado() {
    return Row(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: SizedBox(
            width: 56,
            height: 56,
            child: previa == null
                ? const ColoredBox(color: AppColors.surfaceAlt)
                : Image.memory(previa!, fit: BoxFit.cover, cacheWidth: 200),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(
                    Icons.check_circle_rounded,
                    color: AppColors.success,
                    size: 16,
                  ),
                  SizedBox(width: 4),
                  Text(
                    'Documento anexado',
                    style: TextStyle(
                      color: AppColors.success,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                documento!.nomeOriginal,
                style: AppTextStyles.corpo.copyWith(
                  color: AppColors.textoTitulo,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                _formatarTamanho(tamanhoBytes),
                style: AppTextStyles.legenda,
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        const Text(
          'Trocar',
          style: TextStyle(
            color: AppColors.primary,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

/// Checkbox de consentimento em formato de cartão tocável — a borda e o
/// fundo mudam quando aceito.
class _Consentimento extends StatelessWidget {
  final bool valor;
  final ValueChanged<bool> onChanged;
  final String texto;

  const _Consentimento({
    required this.valor,
    required this.onChanged,
    required this.texto,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => onChanged(!valor),
      borderRadius: BorderRadius.circular(14),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: valor ? AppColors.primarySoft : AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: valor ? AppColors.primary : AppColors.outline,
            width: valor ? 1.5 : 1,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 24,
              height: 24,
              child: Checkbox(
                value: valor,
                onChanged: (v) => onChanged(v ?? false),
                activeColor: AppColors.primary,
                visualDensity: VisualDensity.compact,
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(child: Text(texto, style: AppTextStyles.corpo)),
          ],
        ),
      ),
    );
  }
}

/// Bottom sheet de origem do documento (câmera ou galeria), no mesmo
/// visual do LoginNecessarioDialog.
class _OrigemDocumentoSheet extends StatelessWidget {
  const _OrigemDocumentoSheet();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.outline,
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text('Enviar documento', style: AppTextStyles.titulo),
            const SizedBox(height: 12),
            _OpcaoOrigem(
              icone: Icons.photo_camera_rounded,
              titulo: 'Tirar foto',
              subtitulo: 'Use a câmera do aparelho',
              onTap: () => Navigator.of(context).pop(ImageSource.camera),
            ),
            const Divider(height: 1, color: AppColors.outline),
            _OpcaoOrigem(
              icone: Icons.photo_library_rounded,
              titulo: 'Escolher da galeria',
              subtitulo: 'Selecione uma foto já salva',
              onTap: () => Navigator.of(context).pop(ImageSource.gallery),
            ),
          ],
        ),
      ),
    );
  }
}

class _OpcaoOrigem extends StatelessWidget {
  final IconData icone;
  final String titulo;
  final String subtitulo;
  final VoidCallback onTap;

  const _OpcaoOrigem({
    required this.icone,
    required this.titulo,
    required this.subtitulo,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(icone, color: AppColors.primary, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    titulo,
                    style: AppTextStyles.corpo.copyWith(
                      color: AppColors.textoTitulo,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(subtitulo, style: AppTextStyles.legenda),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right_rounded,
              color: AppColors.textoSecundario,
            ),
          ],
        ),
      ),
    );
  }
}
