import 'package:flutter/material.dart';

import '../../core/errors/erro_mapper.dart';
import '../../core/routes/app_routes.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/cabecalho_simples.dart';
import '../../core/widgets/error_banner.dart';
import '../../core/widgets/secao_card.dart';
import '../../core/widgets/user_avatar.dart';
import '../../core/ws/ws_message_stream.dart';
import '../denuncia/denunciar_usuario_args.dart';
import 'avaliacao_repository.dart';
import 'avaliar_agendamento_args.dart';
import 'widgets/rating_input.dart';

/// Tela única do fluxo de avaliação (sempre OPCIONAL).
///
/// Layout, de cima pra baixo:
/// 1. Cabeçalho vermelho arredondado (CabecalhoSimples).
/// 2. Card do serviço (só quando quem avalia é o CLIENTE): estrelas +
///    comentário opcional, que só aparece depois de escolher a nota.
/// 3. Card da pessoa (prestador/cliente): avatar, estrelas + comentário.
/// 4. "Algo deu errado?": contestar serviço / denunciar pessoa.
/// 5. Rodapé fixo: botão principal + "Pular por agora".
///
/// Dá pra enviar só uma das notas. "Pular" envia tudo como pulado, sem
/// nota e sem comentário, independentemente do que foi preenchido.
class AvaliarAgendamentoScreen extends StatefulWidget {
  const AvaliarAgendamentoScreen({super.key});

  @override
  State<AvaliarAgendamentoScreen> createState() =>
      _AvaliarAgendamentoScreenState();
}

class _AvaliarAgendamentoScreenState extends State<AvaliarAgendamentoScreen> {
  final _avaliacaoRepository = AvaliacaoRepository();
  final _mensagemServicoController = TextEditingController();
  final _mensagemPessoaController = TextEditingController();

  late AvaliarAgendamentoArgs _args;
  bool _argumentosCarregados = false;

  int _notaServico = 0;
  int _notaPessoa = 0;
  bool _enviando = false;
  String? _erro;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_argumentosCarregados) return;
    _argumentosCarregados = true;
    _args =
        ModalRoute.of(context)!.settings.arguments as AvaliarAgendamentoArgs;
  }

  @override
  void dispose() {
    _mensagemServicoController.dispose();
    _mensagemPessoaController.dispose();
    super.dispose();
  }

  bool get _nadaPreenchido => _notaServico == 0 && _notaPessoa == 0;

  Future<void> _enviar({bool pular = false}) async {
    FocusScope.of(context).unfocus();
    setState(() {
      _enviando = true;
      _erro = null;
    });

    final notaServico = pular ? 0 : _notaServico;
    final notaPessoa = pular ? 0 : _notaPessoa;

    try {
      if (_args.avaliarServico) {
        final mensagem = _mensagemServicoController.text.trim();
        await _avaliacaoRepository.avaliarAgendamento(
          agendamentoId: _args.agendamentoId,
          avaliadoId: _args.avaliadoId,
          avaliacao: notaServico > 0 ? notaServico.toDouble() : null,
          pulado: notaServico == 0,
          mensagem: (pular || mensagem.isEmpty) ? null : mensagem,
        );
      }

      final mensagemPessoa = _mensagemPessoaController.text.trim();
      await _avaliacaoRepository.avaliarUsuario(
        agendamentoId: _args.agendamentoId,
        avaliacao: notaPessoa > 0 ? notaPessoa.toDouble() : null,
        pulado: notaPessoa == 0,
        mensagem: (pular || mensagemPessoa.isEmpty) ? null : mensagemPessoa,
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            (pular || _nadaPreenchido)
                ? 'Avaliação pulada.'
                : 'Avaliação enviada. Obrigado!',
          ),
        ),
      );
      Navigator.of(context).pop();
    } on WsErroException catch (e) {
      if (!mounted) return;
      setState(() {
        _erro = ErroMapper.paraMensagem(e.codigo, mensagemServidor: e.mensagem);
      });
    } on WsTimeoutException {
      if (!mounted) return;
      setState(() {
        _erro = 'Não foi possível conectar ao servidor. Tente novamente.';
      });
    } finally {
      if (mounted) setState(() => _enviando = false);
    }
  }

  Future<void> _contestar() async {
    await Navigator.of(
      context,
    ).pushNamed(AppRoutes.contestarAgendamento, arguments: _args.agendamentoId);
  }

  Future<void> _denunciar() async {
    await Navigator.of(context).pushNamed(
      AppRoutes.denunciarUsuario,
      arguments: DenunciarUsuarioArgs(
        usuarioId: _args.avaliadoId,
        nomeUsuario: _args.nomeContraparte,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          CabecalhoSimples(
            titulo: 'Avaliar',
            subtitulo: _args.avaliarServico
                ? _args.nomeServico
                : 'Atendimento com ${_args.nomeContraparte}',
          ),
          Expanded(
            child: GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTap: () => FocusScope.of(context).unfocus(),
              child: SingleChildScrollView(
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    ErrorBanner(mensagem: _erro),
                    if (_args.avaliarServico) ...[
                      _CartaoAvaliacao(
                        topo: const _IconeServico(),
                        titulo: _args.nomeServico,
                        pergunta: 'Como foi o serviço?',
                        nota: _notaServico,
                        onNota: (v) => setState(() => _notaServico = v),
                        controller: _mensagemServicoController,
                        hintComentario: 'Conte como foi (opcional)',
                      ),
                      const SizedBox(height: 16),
                    ],
                    _CartaoAvaliacao(
                      topo: Container(
                        padding: const EdgeInsets.all(3),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppColors.primarySoft,
                            width: 3,
                          ),
                        ),
                        child: UserAvatar(
                          avatarUrl: _args.avatarContraparte,
                          radius: 32,
                        ),
                      ),
                      titulo: _args.nomeContraparte,
                      subtituloTitulo: _args.papelContraparte,
                      pergunta: 'Como foi com ${_args.nomeContraparte}?',
                      nota: _notaPessoa,
                      onNota: (v) => setState(() => _notaPessoa = v),
                      controller: _mensagemPessoaController,
                      hintComentario: 'Deixe um comentário (opcional)',
                    ),
                    const SizedBox(height: 24),
                    Text('Algo deu errado?', style: AppTextStyles.titulo),
                    const SizedBox(height: 12),
                    SecaoCard(
                      child: Column(
                        children: [
                          if (_args.avaliarServico) ...[
                            _AcaoProblema(
                              icone: Icons.gavel_rounded,
                              cor: AppColors.warning,
                              titulo: 'Contestar o serviço',
                              subtitulo: 'O serviço não foi como combinado',
                              onTap: _enviando ? null : _contestar,
                            ),
                            const Divider(height: 24, color: AppColors.outline),
                          ],
                          _AcaoProblema(
                            icone: Icons.flag_rounded,
                            cor: AppColors.error,
                            titulo: 'Denunciar ${_args.nomeContraparte}',
                            subtitulo: 'Relatar um problema com a pessoa',
                            onTap: _enviando ? null : _denunciar,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          _RodapeAcoes(
            enviando: _enviando,
            nadaPreenchido: _nadaPreenchido,
            onEnviar: () => _enviar(),
            onPular: () => _enviar(pular: true),
          ),
        ],
      ),
    );
  }
}

/// Card de avaliação (serviço ou pessoa): elemento de topo, título,
/// pergunta, estrelas com rótulo e comentário que aparece após a nota.
class _CartaoAvaliacao extends StatelessWidget {
  final Widget topo;
  final String titulo;
  final String? subtituloTitulo;
  final String pergunta;
  final int nota;
  final ValueChanged<int> onNota;
  final TextEditingController controller;
  final String hintComentario;

  const _CartaoAvaliacao({
    required this.topo,
    required this.titulo,
    this.subtituloTitulo,
    required this.pergunta,
    required this.nota,
    required this.onNota,
    required this.controller,
    required this.hintComentario,
  });

  OutlineInputBorder _borda(Color cor, {double largura = 1}) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: BorderSide(color: cor, width: largura),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SecaoCard(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(
          children: [
            topo,
            const SizedBox(height: 12),
            Text(
              titulo,
              style: AppTextStyles.titulo,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            if (subtituloTitulo != null) ...[
              const SizedBox(height: 2),
              Text(subtituloTitulo!, style: AppTextStyles.legenda),
            ],
            const SizedBox(height: 16),
            Text(
              pergunta,
              style: AppTextStyles.corpo,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            RatingInput(valor: nota, onChanged: onNota),
            AnimatedSize(
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeOut,
              alignment: Alignment.topCenter,
              child: nota == 0
                  ? const SizedBox(width: double.infinity)
                  : Padding(
                      padding: const EdgeInsets.only(top: 16),
                      child: TextField(
                        controller: controller,
                        maxLines: 3,
                        minLines: 3,
                        maxLength: 300,
                        textCapitalization: TextCapitalization.sentences,
                        cursorColor: AppColors.primary,
                        style: AppTextStyles.corpo.copyWith(
                          color: AppColors.textoTitulo,
                        ),
                        decoration: InputDecoration(
                          hintText: hintComentario,
                          hintStyle: AppTextStyles.corpo.copyWith(
                            color: AppColors.textoSecundario,
                          ),
                          filled: true,
                          fillColor: AppColors.surfaceAlt,
                          contentPadding: const EdgeInsets.all(16),
                          counterStyle: AppTextStyles.legenda,
                          border: _borda(Colors.transparent),
                          enabledBorder: _borda(Colors.transparent),
                          focusedBorder: _borda(
                            AppColors.primary,
                            largura: 1.5,
                          ),
                        ),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _IconeServico extends StatelessWidget {
  const _IconeServico();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 64,
      height: 64,
      decoration: const BoxDecoration(
        color: AppColors.primarySoft,
        shape: BoxShape.circle,
      ),
      child: const Icon(
        Icons.handyman_rounded,
        color: AppColors.primary,
        size: 30,
      ),
    );
  }
}

/// Linha clicável de ação secundária (contestar / denunciar).
class _AcaoProblema extends StatelessWidget {
  final IconData icone;
  final Color cor;
  final String titulo;
  final String subtitulo;
  final VoidCallback? onTap;

  const _AcaoProblema({
    required this.icone,
    required this.cor,
    required this.titulo,
    required this.subtitulo,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: cor.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(icone, color: cor, size: 20),
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
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
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
    );
  }
}

/// Rodapé fixo com a ação principal e o "pular".
class _RodapeAcoes extends StatelessWidget {
  final bool enviando;
  final bool nadaPreenchido;
  final VoidCallback onEnviar;
  final VoidCallback onPular;

  const _RodapeAcoes({
    required this.enviando,
    required this.nadaPreenchido,
    required this.onEnviar,
    required this.onPular,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.outline)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AppButton(
                label: 'Enviar avaliação',
                loading: enviando,
                onPressed: nadaPreenchido ? null : onEnviar,
              ),
              TextButton(
                onPressed: enviando ? null : onPular,
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.textoSecundario,
                ),
                child: const Text('Pular por agora'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
