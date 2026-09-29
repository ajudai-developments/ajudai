import 'package:ajudai/core/routes/app_routes.dart';
import 'package:ajudai/core/theme/app_colors.dart';
import 'package:ajudai/core/theme/app_text_styles.dart';
import 'package:ajudai/core/widgets/abas_chips_web.dart';
import 'package:ajudai/core/widgets/app_button.dart';
import 'package:ajudai/core/widgets/app_text_field.dart';
import 'package:ajudai/core/widgets/error_banner.dart';
import 'package:ajudai/core/widgets/mestre_detalhe.dart';
import 'package:ajudai/core/widgets/secao_card.dart';
import 'package:ajudai/core/widgets/shell_admin.dart';
import 'package:ajudai/core/widgets/status_chip.dart';
import 'package:ajudai/core/widgets/status_timeline.dart';
import 'package:ajudai/features/admin/widgets/admin_widgets.dart';
import 'package:flutter/material.dart';
import 'package:shared/shared.dart';

import 'admin_repository.dart';

class AdminContestacoesScreen extends StatefulWidget {
  const AdminContestacoesScreen({super.key});

  @override
  State<AdminContestacoesScreen> createState() =>
      _AdminContestacoesScreenState();
}

class _AdminContestacoesScreenState extends State<AdminContestacoesScreen> {
  static const _abas = [
    'Abertas',
    'Em análise',
    'Resolvidas',
    'Rejeitadas',
    'Todas',
  ];
  static const _filtros = <StatusContestacao?>[
    StatusContestacao.aberta,
    StatusContestacao.emAnalise,
    StatusContestacao.resolvida,
    StatusContestacao.rejeitada,
    null,
  ];

  final _repo = AdminRepository();
  int _aba = 0;

  @override
  Widget build(BuildContext context) {
    return ShellAdmin(
      titulo: 'Contestações',
      rotaAtual: AppRoutes.adminContestacoes,
      child: MestreDetalhe<ContestacaoComUrls>(
        key: ValueKey(_aba),
        carregar: () => _repo.listarContestacoes(_filtros[_aba]),
        idDe: (item) => item.contestacao.id,
        aoAbrir: (item) async {
          if (item.contestacao.status != StatusContestacao.aberta) {
            return item;
          }
          final novo = await _repo.marcarContestacaoEmAnalise(
            item.contestacao.id,
          );
          return item.comStatus(novo);
        },
        mensagemVazio: 'Nenhuma contestação nesta categoria.',
        filtros: AbasChipsWeb(
          abas: _abas,
          selecionada: _aba,
          onChanged: (i) => setState(() => _aba = i),
        ),
        itemBuilder: (context, item) {
          final c = item.contestacao;
          return Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${c.contestadorNome} → ${c.contestadoNome}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.corpo.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppColors.textoTitulo,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      formatarDataHora(c.criadoEm),
                      style: AppTextStyles.legenda,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              StatusChip(valor: c.status.valor),
            ],
          );
        },
        detalheBuilder: (context, item, recarregar) =>
            _DetalheContestacao(item: item, aoAtualizar: recarregar),
      ),
    );
  }
}

class _DetalheContestacao extends StatefulWidget {
  final ContestacaoComUrls item;
  final Future<void> Function() aoAtualizar;

  const _DetalheContestacao({required this.item, required this.aoAtualizar});

  @override
  State<_DetalheContestacao> createState() => _DetalheContestacaoState();
}

class _DetalheContestacaoState extends State<_DetalheContestacao> {
  static const _statusPossiveis = [
    StatusContestacao.emAnalise,
    StatusContestacao.resolvida,
    StatusContestacao.rejeitada,
  ];
  static const _statusFinais = [
    StatusAgendamento.concluido,
    StatusAgendamento.naoConcluido,
    StatusAgendamento.cancelado,
  ];

  final _repo = AdminRepository();
  final _resposta = TextEditingController();
  StatusContestacao _status = StatusContestacao.resolvida;
  StatusAgendamento _statusFinal = StatusAgendamento.concluido;
  bool _enviando = false;
  String? _erro;
  String? _erroResposta;

  ContestacaoComDetalhes get _c => widget.item.contestacao;
  bool get _emAberto =>
      _c.status == StatusContestacao.aberta ||
      _c.status == StatusContestacao.emAnalise;

  @override
  void dispose() {
    _resposta.dispose();
    super.dispose();
  }

  String _labelStatus(StatusContestacao s) {
    switch (s) {
      case StatusContestacao.aberta:
        return 'Aberta';
      case StatusContestacao.emAnalise:
        return 'Em análise';
      case StatusContestacao.resolvida:
        return 'Resolvida (a favor de quem contestou)';
      case StatusContestacao.rejeitada:
        return 'Rejeitada';
    }
  }

  Future<void> _enviar() async {
    final texto = _resposta.text.trim();
    if (texto.isEmpty) {
      setState(() => _erroResposta = 'Escreva uma resposta para as partes.');
      return;
    }

    final messenger = ScaffoldMessenger.of(context);
    setState(() {
      _enviando = true;
      _erro = null;
      _erroResposta = null;
    });
    try {
      await _repo.responderContestacao(
        contestacaoId: _c.id,
        status: _status,
        resposta: texto,
        statusAgendamentoFinal: _statusFinal,
      );
      messenger.showSnackBar(
        const SnackBar(content: Text('Contestação respondida.')),
      );
      await widget.aoAtualizar();
    } catch (e) {
      if (mounted) setState(() => _erro = mensagemDeErroWs(e));
    } finally {
      if (mounted) setState(() => _enviando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = _c;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CabecalhoDetalhe(
          titulo: '${c.contestadorNome} contestou ${c.contestadoNome}',
          subtitulo: 'Aberta em ${formatarDataHora(c.criadoEm)}',
          trailing: StatusChip(valor: c.status.valor),
        ),
        SecaoAdmin(
          titulo: 'Agendamento',
          child: BlocoInfo(
            linhas: [
              MapEntry(
                'Status atual',
                labelStatusAgendamento(c.agendamentoStatus),
              ),
              MapEntry('Início', formatarDataHora(c.horaInicio)),
              MapEntry('Fim', formatarDataHora(c.horaFim)),
              MapEntry('Valor', formatarValor(c.valor)),
              MapEntry('ID', c.agendamentoId),
            ],
          ),
        ),
        SecaoAdmin(
          titulo: 'Descrição',
          child: SecaoCard(
            child: Text(c.descricao, style: AppTextStyles.corpo),
          ),
        ),
        if (c.arquivos.isNotEmpty)
          SecaoAdmin(
            titulo: 'Anexos (${c.arquivos.length})',
            child: GradeAnexos(
              arquivos: c.arquivos,
              urls: widget.item.urlsArquivos,
            ),
          ),
        SecaoAdmin(
          titulo: 'Andamento',
          child: SecaoCard(child: StatusTimeline(status: c.status.valor)),
        ),
        if (_emAberto)
          SecaoAdmin(
            titulo: 'Responder contestação',
            child: SecaoCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  ErrorBanner(mensagem: _erro),
                  DropdownButtonFormField<StatusContestacao>(
                    initialValue: _status,
                    decoration: const InputDecoration(labelText: 'Decisão'),
                    items: [
                      for (final s in _statusPossiveis)
                        DropdownMenuItem(
                          value: s,
                          child: Text(_labelStatus(s)),
                        ),
                    ],
                    onChanged: _enviando
                        ? null
                        : (s) => setState(() => _status = s ?? _status),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<StatusAgendamento>(
                    initialValue: _statusFinal,
                    decoration: const InputDecoration(
                      labelText: 'Status final do agendamento',
                    ),
                    items: [
                      for (final s in _statusFinais)
                        DropdownMenuItem(
                          value: s,
                          child: Text(labelStatusAgendamento(s)),
                        ),
                    ],
                    onChanged: _enviando
                        ? null
                        : (s) =>
                              setState(() => _statusFinal = s ?? _statusFinal),
                  ),
                  const SizedBox(height: 16),
                  AppTextField(
                    label: 'Resposta para as partes',
                    controller: _resposta,
                    maxLines: 5,
                    minLines: 4,
                    erro: _erroResposta,
                    textCapitalization: TextCapitalization.sentences,
                  ),
                  const SizedBox(height: 20),
                  Align(
                    alignment: Alignment.centerRight,
                    child: SizedBox(
                      width: 220,
                      child: AppButton(
                        label: 'Enviar resposta',
                        loading: _enviando,
                        onPressed: _enviar,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          )
        else if (c.respostaAdmin != null)
          SecaoAdmin(
            titulo: 'Resposta da equipe',
            child: SecaoCard(
              corFundo: c.status == StatusContestacao.resolvida
                  ? AppColors.successSoft
                  : null,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(c.respostaAdmin!, style: AppTextStyles.corpo),
                  if (c.respondidoEm != null) ...[
                    const SizedBox(height: 10),
                    Text(
                      'Respondida em ${formatarDataHora(c.respondidoEm!)}',
                      style: AppTextStyles.legenda,
                    ),
                  ],
                ],
              ),
            ),
          ),
      ],
    );
  }
}
