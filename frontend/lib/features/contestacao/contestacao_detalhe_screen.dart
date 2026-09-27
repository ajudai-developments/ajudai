import 'package:ajudai/core/widgets/cabbecalho_simples.dart';
import 'package:flutter/material.dart';
import 'package:shared/shared.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/secao_card.dart';
import '../../core/widgets/status_chip.dart';
import '../../core/widgets/status_timeline.dart';
import 'contestacao_repository.dart';

/// Detalhe de uma contestação aberta pelo usuário logado — mostra o
/// andamento (linha do tempo), os dados do agendamento contestado, a
/// descrição enviada, anexos e a resposta da equipe (quando houver).
///
/// Recebe o [ContestacaoComUrls] inteiro via argumento da rota — a
/// listagem já traz todos os campos que esta tela precisa, então não é
/// feita nenhuma busca ao abrir. Puxar pra atualizar (RefreshIndicator)
/// busca a lista de novo e substitui só este item, o que permite
/// "acompanhar" uma mudança de status sem existir endpoint de detalhe
/// dedicado no backend.
class ContestacaoDetalheScreen extends StatefulWidget {
  const ContestacaoDetalheScreen({super.key});

  @override
  State<ContestacaoDetalheScreen> createState() =>
      _ContestacaoDetalheScreenState();
}

class _ContestacaoDetalheScreenState extends State<ContestacaoDetalheScreen> {
  final _repository = ContestacaoRepository();

  late ContestacaoComUrls _item;
  bool _argumentosCarregados = false;
  bool _atualizando = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_argumentosCarregados) return;
    _argumentosCarregados = true;
    _item = ModalRoute.of(context)!.settings.arguments as ContestacaoComUrls;
  }

  Future<void> _atualizar() async {
    setState(() => _atualizando = true);
    try {
      final lista = await _repository.listarMinhasContestacoes();
      final atualizado = lista.where(
        (c) => c.contestacao.id == _item.contestacao.id,
      );
      if (atualizado.isNotEmpty && mounted) {
        setState(() => _item = atualizado.first);
      }
    } catch (_) {
      // Falha silenciosa: o usuário continua vendo os últimos dados
      // carregados, não há erro bloqueante a mostrar aqui.
    } finally {
      if (mounted) setState(() => _atualizando = false);
    }
  }

  String _formatarData(DateTime data) =>
      '${data.day.toString().padLeft(2, '0')}/'
      '${data.month.toString().padLeft(2, '0')}/${data.year}';

  String _formatarHora(DateTime data) =>
      '${data.hour.toString().padLeft(2, '0')}:'
      '${data.minute.toString().padLeft(2, '0')}';

  String _formatarValor(double valor) =>
      'R\$ ${valor.toStringAsFixed(2).replaceAll('.', ',')}';

  @override
  Widget build(BuildContext context) {
    final c = _item.contestacao;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          CabecalhoSimples(
            titulo: 'Contestação',
            subtitulo: 'Sobre o agendamento com ${c.contestadoNome}',
          ),
          Expanded(
            child: RefreshIndicator(
              color: AppColors.primary,
              onRefresh: _atualizar,
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
                children: [
                  if (_atualizando)
                    const Padding(
                      padding: EdgeInsets.only(bottom: 12),
                      child: Center(
                        child: SizedBox(
                          height: 16,
                          width: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Andamento', style: AppTextStyles.titulo),
                      StatusChip(valor: c.status.valor),
                    ],
                  ),
                  const SizedBox(height: 16),
                  SecaoCard(child: StatusTimeline(status: c.status.valor)),
                  const SizedBox(height: 24),

                  Text('Sobre o agendamento', style: AppTextStyles.titulo),
                  const SizedBox(height: 12),
                  SecaoCard(
                    child: Column(
                      children: [
                        LinhaInfo(
                          label: 'Data',
                          valor: _formatarData(c.horaInicio),
                        ),
                        const Divider(height: 20, color: AppColors.outline),
                        LinhaInfo(
                          label: 'Horário',
                          valor:
                              '${_formatarHora(c.horaInicio)} — ${_formatarHora(c.horaFim)}',
                        ),
                        const Divider(height: 20, color: AppColors.outline),
                        LinhaInfo(
                          label: 'Valor',
                          valor: _formatarValor(c.valor),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  Text('Sua descrição', style: AppTextStyles.titulo),
                  const SizedBox(height: 12),
                  SecaoCard(
                    child: Text(c.descricao, style: AppTextStyles.corpo),
                  ),

                  if (c.arquivos.isNotEmpty) ...[
                    const SizedBox(height: 24),
                    Text('Anexos', style: AppTextStyles.titulo),
                    const SizedBox(height: 12),
                    GradeAnexos(arquivos: c.arquivos, urls: _item.urlsArquivos),
                  ],

                  const SizedBox(height: 24),
                  Text('Resposta da equipe', style: AppTextStyles.titulo),
                  const SizedBox(height: 12),
                  if (c.respostaAdmin != null)
                    SecaoCard(
                      corFundo: AppColors.successSoft,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(c.respostaAdmin!, style: AppTextStyles.corpo),
                          if (c.respondidoEm != null) ...[
                            const SizedBox(height: 8),
                            Text(
                              'Respondido em ${_formatarData(c.respondidoEm!)}',
                              style: AppTextStyles.legenda,
                            ),
                          ],
                        ],
                      ),
                    )
                  else
                    SecaoCard(
                      child: Row(
                        children: [
                          const Icon(
                            Icons.hourglass_empty_rounded,
                            color: AppColors.textoSecundario,
                            size: 20,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'Ainda sem resposta. Assim que nossa equipe '
                              'analisar, você verá a atualização aqui.',
                              style: AppTextStyles.corpo,
                            ),
                          ),
                        ],
                      ),
                    ),

                  const SizedBox(height: 24),
                  Center(
                    child: Text(
                      'Aberta em ${_formatarData(c.criadoEm)}',
                      style: AppTextStyles.legenda,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
