import 'package:ajudai/core/widgets/cabecalho_simples.dart';
import 'package:ajudai/core/widgets/tipo_denuncia_label.dart';
import 'package:flutter/material.dart';
import 'package:shared/shared.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/secao_card.dart';
import '../../core/widgets/status_chip.dart';
import '../../core/widgets/status_timeline.dart';
import 'denuncia_repository.dart';

/// Detalhe de uma denúncia aberta pelo usuário logado — mesmo padrão de
/// [ContestacaoDetalheScreen]: recebe o item inteiro via argumento da
/// rota e "acompanhar" acontece via pull-to-refresh, que rebusca a lista
/// e atualiza só este item (não existe endpoint de detalhe dedicado).
class DenunciaDetalheScreen extends StatefulWidget {
  const DenunciaDetalheScreen({super.key});

  @override
  State<DenunciaDetalheScreen> createState() => _DenunciaDetalheScreenState();
}

class _DenunciaDetalheScreenState extends State<DenunciaDetalheScreen> {
  final _repository = DenunciaRepository();

  late DenunciaComUrls _item;
  bool _argumentosCarregados = false;
  bool _atualizando = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_argumentosCarregados) return;
    _argumentosCarregados = true;
    _item = ModalRoute.of(context)!.settings.arguments as DenunciaComUrls;
  }

  Future<void> _atualizar() async {
    setState(() => _atualizando = true);
    try {
      final lista = await _repository.listarMinhasDenuncias();
      final atualizado = lista.where((d) => d.denuncia.id == _item.denuncia.id);
      if (atualizado.isNotEmpty && mounted) {
        setState(() => _item = atualizado.first);
      }
    } catch (_) {
      // Idem contestação: falha silenciosa, mantém os últimos dados.
    } finally {
      if (mounted) setState(() => _atualizando = false);
    }
  }

  String _formatarData(DateTime data) =>
      '${data.day.toString().padLeft(2, '0')}/'
      '${data.month.toString().padLeft(2, '0')}/${data.year}';

  @override
  Widget build(BuildContext context) {
    final d = _item.denuncia;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          CabecalhoSimples(
            titulo: 'Denúncia',
            subtitulo: 'Contra ${d.usuarioNome}',
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
                      StatusChip(valor: d.status.valor),
                    ],
                  ),
                  const SizedBox(height: 16),
                  SecaoCard(child: StatusTimeline(status: d.status.valor)),
                  const SizedBox(height: 24),

                  Text('Motivo', style: AppTextStyles.titulo),
                  const SizedBox(height: 12),
                  SecaoCard(
                    child: LinhaInfo(
                      label: 'Tipo',
                      valor: labelTipoDenuncia(d.tipo),
                    ),
                  ),
                  const SizedBox(height: 24),

                  Text('Sua descrição', style: AppTextStyles.titulo),
                  const SizedBox(height: 12),
                  SecaoCard(
                    child: Text(d.descricao, style: AppTextStyles.corpo),
                  ),

                  if (d.arquivos.isNotEmpty) ...[
                    const SizedBox(height: 24),
                    Text('Anexos', style: AppTextStyles.titulo),
                    const SizedBox(height: 12),
                    GradeAnexos(arquivos: d.arquivos, urls: _item.urlsArquivos),
                  ],

                  const SizedBox(height: 24),
                  Text('Resposta da equipe', style: AppTextStyles.titulo),
                  const SizedBox(height: 12),
                  if (d.respostaAdmin != null)
                    SecaoCard(
                      corFundo: AppColors.successSoft,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(d.respostaAdmin!, style: AppTextStyles.corpo),
                          if (d.respondidoEm != null) ...[
                            const SizedBox(height: 8),
                            Text(
                              'Respondido em ${_formatarData(d.respondidoEm!)}',
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
                      'Enviada em ${_formatarData(d.denunciadoEm)}',
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
