import 'package:ajudai/core/routes/app_routes.dart';
import 'package:ajudai/core/theme/app_colors.dart';
import 'package:ajudai/core/theme/app_text_styles.dart';
import 'package:ajudai/core/widgets/abas_chips_web.dart';
import 'package:ajudai/core/widgets/app_button.dart';
import 'package:ajudai/core/widgets/error_banner.dart';
import 'package:ajudai/core/widgets/mestre_detalhe.dart';
import 'package:ajudai/core/widgets/secao_card.dart';
import 'package:ajudai/core/widgets/shell_admin.dart';
import 'package:flutter/material.dart';
import 'package:shared/shared.dart';

import 'admin_repository.dart';
import 'package:ajudai/features/admin/widgets/admin_widgets.dart';

Color _corStatus(StatusVerificacao s) {
  switch (s) {
    case StatusVerificacao.pendente:
      return AppColors.warning;
    case StatusVerificacao.aprovado:
      return AppColors.success;
    case StatusVerificacao.rejeitado:
      return AppColors.error;
  }
}

String _labelStatus(StatusVerificacao s) {
  switch (s) {
    case StatusVerificacao.pendente:
      return 'Pendente';
    case StatusVerificacao.aprovado:
      return 'Aprovada';
    case StatusVerificacao.rejeitado:
      return 'Rejeitada';
  }
}

class AdminVerificacoesScreen extends StatefulWidget {
  const AdminVerificacoesScreen({super.key});

  @override
  State<AdminVerificacoesScreen> createState() =>
      _AdminVerificacoesScreenState();
}

class _AdminVerificacoesScreenState extends State<AdminVerificacoesScreen> {
  static const _abas = ['Pendentes', 'Aprovadas', 'Rejeitadas', 'Todas'];
  static const _filtros = <StatusVerificacao?>[
    StatusVerificacao.pendente,
    StatusVerificacao.aprovado,
    StatusVerificacao.rejeitado,
    null,
  ];

  final _repo = AdminRepository();
  int _aba = 0;

  @override
  Widget build(BuildContext context) {
    return ShellAdmin(
      titulo: 'Verificações de prestadores',
      rotaAtual: AppRoutes.verificacoes,
      child: MestreDetalhe<VerificacaoComUrls>(
        key: ValueKey(_aba),
        carregar: () => _repo.listarVerificacoes(_filtros[_aba]),
        idDe: (v) => v.verificacao.id,
        mensagemVazio: 'Nenhuma verificação nesta categoria.',
        filtros: AbasChipsWeb(
          abas: _abas,
          selecionada: _aba,
          onChanged: (i) => setState(() => _aba = i),
        ),
        itemBuilder: (context, item) {
          final v = item.verificacao;
          return Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      v.usuarioNome,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.corpo.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppColors.textoTitulo,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      formatarDataHora(v.solicitadoEm),
                      style: AppTextStyles.legenda,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              ChipAdmin(
                label: _labelStatus(v.status),
                cor: _corStatus(v.status),
              ),
            ],
          );
        },
        detalheBuilder: (context, item, recarregar) =>
            _DetalheVerificacao(item: item, aoAtualizar: recarregar),
      ),
    );
  }
}

class _DetalheVerificacao extends StatefulWidget {
  final VerificacaoComUrls item;
  final Future<void> Function() aoAtualizar;

  const _DetalheVerificacao({required this.item, required this.aoAtualizar});

  @override
  State<_DetalheVerificacao> createState() => _DetalheVerificacaoState();
}

class _DetalheVerificacaoState extends State<_DetalheVerificacao> {
  final _repo = AdminRepository();
  bool _enviando = false;
  String? _erro;

  VerificacaoComDetalhes get _v => widget.item.verificacao;

  Future<void> _executar(
    Future<void> Function() acao,
    String mensagemSucesso,
  ) async {
    final messenger = ScaffoldMessenger.of(context);
    setState(() {
      _enviando = true;
      _erro = null;
    });
    try {
      await acao();
      messenger.showSnackBar(SnackBar(content: Text(mensagemSucesso)));
      await widget.aoAtualizar();
    } catch (e) {
      if (mounted) setState(() => _erro = mensagemDeErroWs(e));
    } finally {
      if (mounted) setState(() => _enviando = false);
    }
  }

  Future<void> _aprovar() =>
      _executar(() => _repo.aprovarPrestador(_v.id), 'Prestador aprovado.');

  Future<void> _rejeitar() async {
    final motivo = await pedirTexto(
      context,
      titulo: 'Rejeitar solicitação',
      rotulo: 'Motivo (o prestador verá esta mensagem)',
      confirmar: 'Rejeitar',
    );
    if (motivo == null) return;
    await _executar(
      () => _repo.rejeitarPrestador(verificacaoId: _v.id, motivo: motivo),
      'Solicitação rejeitada.',
    );
  }

  @override
  Widget build(BuildContext context) {
    final v = _v;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CabecalhoDetalhe(
          titulo: v.usuarioNome,
          subtitulo:
              'Solicitou verificação em ${formatarDataHora(v.solicitadoEm)}',
          trailing: ChipAdmin(
            label: _labelStatus(v.status),
            cor: _corStatus(v.status),
          ),
        ),
        SecaoAdmin(
          titulo: 'Dados do solicitante',
          child: BlocoInfo(
            linhas: [
              MapEntry('Nome', v.usuarioNome),
              MapEntry('CPF', v.usuarioCpf),
              MapEntry('Telefone', v.usuarioTelefone ?? '—'),
            ],
          ),
        ),
        SecaoAdmin(
          titulo: 'Documentos enviados (${v.arquivos.length})',
          child: v.arquivos.isEmpty
              ? const Text(
                  'Nenhum documento anexado.',
                  style: AppTextStyles.corpo,
                )
              : GradeAnexos(
                  arquivos: v.arquivos,
                  urls: widget.item.urlsArquivos,
                ),
        ),
        if (v.status == StatusVerificacao.pendente)
          SecaoAdmin(
            titulo: 'Decisão',
            child: SecaoCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ErrorBanner(mensagem: _erro),
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: [
                      SizedBox(
                        width: 220,
                        child: AppButton(
                          label: 'Aprovar prestador',
                          loading: _enviando,
                          onPressed: _aprovar,
                        ),
                      ),
                      SizedBox(
                        width: 180,
                        child: AppOutlinedButton(
                          label: 'Rejeitar',
                          onPressed: _enviando ? null : _rejeitar,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          )
        else if (v.status == StatusVerificacao.rejeitado &&
            v.motivoRejeicao != null)
          SecaoAdmin(
            titulo: 'Motivo da rejeição',
            child: SecaoCard(
              child: Text(v.motivoRejeicao!, style: AppTextStyles.corpo),
            ),
          )
        else if (v.alteradoEm != null)
          Text(
            'Aprovada em ${formatarDataHora(v.alteradoEm!)}',
            style: AppTextStyles.legenda,
          ),
      ],
    );
  }
}
