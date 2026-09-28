import 'package:ajudai/core/layout/responsivo.dart';
import 'package:ajudai/core/widgets/tela_adaptativa.dart';
import 'package:flutter/material.dart';
import 'package:shared/shared.dart';

import '../../core/routes/app_routes.dart';
import '../../core/session/sessao.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/async_list_view.dart';
import '../../core/widgets/cabecalho_simples.dart';
import '../../core/widgets/secao_card.dart';
import '../../core/widgets/status_timeline.dart';
import 'prestador_repository.dart';

/// Acompanhamento da solicitação para virar prestador.
///
/// Mostra a solicitação mais recente com a timeline (enviada -> em análise
/// -> aprovada/rejeitada), o motivo da rejeição quando houver e os
/// documentos enviados. Solicitações antigas (de tentativas anteriores
/// depois de uma rejeição) aparecem como histórico no fim.
class MinhaSolicitacaoPrestadorScreen extends StatefulWidget {
  const MinhaSolicitacaoPrestadorScreen({super.key});

  @override
  State<MinhaSolicitacaoPrestadorScreen> createState() =>
      _MinhaSolicitacaoPrestadorScreenState();
}

class _MinhaSolicitacaoPrestadorScreenState
    extends State<MinhaSolicitacaoPrestadorScreen> {
  final _prestadorRepository = PrestadorRepository();
  final _listaKey = GlobalKey<AsyncListViewState<VerificacaoComUrls>>();

  Future<void> _solicitarNovamente() async {
    await Navigator.of(context).pushNamed(AppRoutes.solicitarPrestador);
    if (mounted) _listaKey.currentState?.recarregar();
  }

  /// Traduz o status da verificação pros valores que a StatusTimeline
  /// entende. Pendente = já enviada e em análise.
  String _statusTimeline(StatusVerificacao status) {
    switch (status) {
      case StatusVerificacao.pendente:
        return 'em_analise';
      case StatusVerificacao.aprovado:
        return 'resolvida';
      case StatusVerificacao.rejeitado:
        return 'rejeitada';
    }
  }

  @override
  Widget build(BuildContext context) {
    final web = context.usaLayoutWeb;
    return TelaAdaptativa(
      titulo: 'Minha solicitação',
      rotaAtual: AppRoutes.meuPerfil,
      semAppBarMobile: true,
      child: Column(
        children: [
          if (!web)
            const CabecalhoSimples(
              titulo: 'Minha solicitação',
              subtitulo: 'Acompanhe a análise do seu cadastro',
            ),

          Expanded(
            child: ConteudoCentralizado(
              larguraMax: 760,
              child: AsyncListView<VerificacaoComUrls>(
                key: _listaKey,
                carregar: _prestadorRepository.listarMinhasVerificacoes,
                mensagemVazio: 'Você ainda não fez nenhuma solicitação.',
                builder: (context, itens) {
                  final atual = itens.first;
                  final anteriores = itens.skip(1).toList();
                  return _Conteudo(
                    atual: atual,
                    anteriores: anteriores,
                    statusTimeline: _statusTimeline(atual.verificacao.status),
                    podeSolicitarNovamente:
                        Sessao.instance.usuario?.statusPrestador ==
                        StatusPrestador.rejeitado,
                    onSolicitarNovamente: _solicitarNovamente,
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Conteudo extends StatelessWidget {
  final VerificacaoComUrls atual;
  final List<VerificacaoComUrls> anteriores;
  final String statusTimeline;
  final bool podeSolicitarNovamente;
  final VoidCallback onSolicitarNovamente;

  const _Conteudo({
    required this.atual,
    required this.anteriores,
    required this.statusTimeline,
    required this.podeSolicitarNovamente,
    required this.onSolicitarNovamente,
  });

  @override
  Widget build(BuildContext context) {
    final v = atual.verificacao;
    final motivo = v.motivoRejeicao?.trim();
    final temMotivo =
        v.status == StatusVerificacao.rejeitado &&
        motivo != null &&
        motivo.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SecaoCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Andamento', style: AppTextStyles.titulo),
              const SizedBox(height: 4),
              Text(
                'Enviada em ${_formatarData(v.solicitadoEm)}',
                style: AppTextStyles.legenda,
              ),
              const SizedBox(height: 16),
              StatusTimeline(
                status: statusTimeline,
                textos: TimelineTextos.verificacao,
              ),
              if (v.alteradoEm != null &&
                  v.status != StatusVerificacao.pendente) ...[
                const SizedBox(height: 4),
                Text(
                  'Analisada em ${_formatarData(v.alteradoEm!)}',
                  style: AppTextStyles.legenda,
                ),
              ],
            ],
          ),
        ),

        if (temMotivo) ...[
          const SizedBox(height: 12),
          SecaoCard(
            corFundo: AppColors.primarySoft,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.info_outline_rounded,
                      color: AppColors.primary,
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Text('Motivo da rejeição', style: AppTextStyles.titulo),
                  ],
                ),
                const SizedBox(height: 8),
                Text(motivo, style: AppTextStyles.corpo),
              ],
            ),
          ),
        ],

        if (v.arquivos.isNotEmpty) ...[
          const SizedBox(height: 20),
          Text('Documentos enviados', style: AppTextStyles.titulo),
          const SizedBox(height: 12),
          GradeAnexos(arquivos: v.arquivos, urls: atual.urlsArquivos),
        ],

        if (podeSolicitarNovamente) ...[
          const SizedBox(height: 24),
          AppButton(
            label: 'Solicitar novamente',
            onPressed: onSolicitarNovamente,
          ),
        ],

        if (anteriores.isNotEmpty) ...[
          const SizedBox(height: 28),
          Text('Solicitações anteriores', style: AppTextStyles.titulo),
          const SizedBox(height: 12),
          for (final a in anteriores) ...[
            _LinhaHistorico(item: a.verificacao),
            const SizedBox(height: 8),
          ],
        ],
      ],
    );
  }
}

class _LinhaHistorico extends StatelessWidget {
  final VerificacaoComDetalhes item;
  const _LinhaHistorico({required this.item});

  String get _label {
    switch (item.status) {
      case StatusVerificacao.pendente:
        return 'Em análise';
      case StatusVerificacao.aprovado:
        return 'Aprovada';
      case StatusVerificacao.rejeitado:
        return 'Rejeitada';
    }
  }

  @override
  Widget build(BuildContext context) {
    final motivo = item.motivoRejeicao?.trim();

    return SecaoCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  _formatarData(item.solicitadoEm),
                  style: AppTextStyles.corpo.copyWith(
                    color: AppColors.textoTitulo,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Text(_label, style: AppTextStyles.label),
            ],
          ),
          if (motivo != null && motivo.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(motivo, style: AppTextStyles.legenda),
          ],
        ],
      ),
    );
  }
}

String _formatarData(DateTime dt) {
  final l = dt.toLocal();
  String d2(int n) => n.toString().padLeft(2, '0');
  return '${d2(l.day)}/${d2(l.month)}/${l.year} às ${d2(l.hour)}:${d2(l.minute)}';
}
