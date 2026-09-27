import 'package:ajudai/core/widgets/cabecalho_com_abas.dart';
import 'package:flutter/material.dart';
import 'package:shared/shared.dart';

import '../../core/routes/app_routes.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/async_list_view.dart';
import 'prestador_repository.dart';

/// Lista os serviços que o prestador logado oferece — somente
/// visualização (nome, categoria, descrição, valor e a avaliação
/// específica daquela oferta). Duas abas: Ativos e Desativados.
///
/// Editar e (des)ativar um serviço são ações de outra tela
/// (EditarServicoScreen) — esta aqui é só pra o prestador conferir o
/// que tem cadastrado.
class MeusServicosOferecidosScreen extends StatefulWidget {
  const MeusServicosOferecidosScreen({super.key});

  @override
  State<MeusServicosOferecidosScreen> createState() =>
      _MeusServicosOferecidosScreenState();
}

class _MeusServicosOferecidosScreenState
    extends State<MeusServicosOferecidosScreen> {
  final _prestadorRepository = PrestadorRepository();
  int _aba = 0;
  int _reloadTick = 0;

  /// Abas já abertas ao menos uma vez — a de Desativados só monta (e só
  /// dispara request) na primeira vez que o usuário clica nela.
  final Set<int> _abasVisitadas = {0};

  void _onTrocarAba(int i) {
    setState(() {
      _aba = i;
      _abasVisitadas.add(i);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          CabecalhoComAbas(
            titulo: 'Meus serviços',
            subtitulo: 'Acompanhe e gerencie o que você oferece',
            abas: const ['Ativos', 'Desativados'],
            abaSelecionada: _aba,
            onTrocarAba: _onTrocarAba,
            // mostrarBotaoVoltar fica true (padrão) — essa tela é empilhada normal.
          ),
          Expanded(
            child: IndexedStack(
              index: _aba,
              sizing: StackFit.expand,
              children: [
                _abasVisitadas.contains(0)
                    ? AsyncListView<ServicoOferecidoDoPrestador>(
                        key: ValueKey('ativos-$_reloadTick'),
                        carregar:
                            _prestadorRepository.listarMeusServicosOferecidos,
                        mensagemVazio:
                            'Você ainda não tem serviços cadastrados.',
                        builder: (context, itens) => _ListaServicos(
                          itens: itens,
                          onVoltarComAlteracao: () =>
                              setState(() => _reloadTick++),
                        ),
                      )
                    : const SizedBox.shrink(),
                _abasVisitadas.contains(1)
                    ? AsyncListView<ServicoOferecidoDoPrestador>(
                        key: ValueKey('desativados-$_reloadTick'),
                        carregar: _prestadorRepository
                            .listarMeusServicosOferecidosDesativados,
                        mensagemVazio: 'Nenhum serviço desativado.',
                        builder: (context, itens) => _ListaServicos(
                          itens: itens,
                          onVoltarComAlteracao: () =>
                              setState(() => _reloadTick++),
                        ),
                      )
                    : const SizedBox.shrink(),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final resultado = await Navigator.of(
            context,
          ).pushNamed(AppRoutes.formServicoOferecido);
          if (resultado == true && mounted) {
            setState(() => _reloadTick++);
          }
        },
        icon: const Icon(Icons.add_rounded),
        label: const Text('Adicionar serviço'),
      ),
    );
  }
}

class _ListaServicos extends StatelessWidget {
  final List<ServicoOferecidoDoPrestador> itens;
  final VoidCallback onVoltarComAlteracao;

  const _ListaServicos({
    required this.itens,
    required this.onVoltarComAlteracao,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (final item in itens) ...[
          _CartaoServicoOferecido(
            item: item,
            onTap: () async {
              final alterou = await Navigator.of(context).pushNamed(
                AppRoutes.servicoOferecidoDetalhe,
                arguments: item.servicoOferecidoId,
              );
              if (alterou == true) onVoltarComAlteracao();
            },
          ),
          const SizedBox(height: 12),
        ],
      ],
    );
  }
}

class _CartaoServicoOferecido extends StatelessWidget {
  final ServicoOferecidoDoPrestador item;
  final VoidCallback onTap;
  const _CartaoServicoOferecido({required this.item, required this.onTap});

  String _formatarValor(double valor) =>
      'R\$ ${valor.toStringAsFixed(2).replaceAll('.', ',')}';

  IconData _iconeParaCategoria(String categoria) {
    switch (categoria.trim().toLowerCase()) {
      case 'limpeza':
        return Icons.cleaning_services_rounded;
      case 'elétrica':
        return Icons.electrical_services_rounded;
      case 'hidráulica':
        return Icons.plumbing_rounded;
      case 'beleza e estética':
        return Icons.content_cut_rounded;
      case 'reformas e construção':
        return Icons.handyman_rounded;
      case 'jardinagem':
        return Icons.yard_rounded;
      case 'tecnologia':
        return Icons.devices_rounded;
      case 'aulas particulares':
        return Icons.menu_book_rounded;
      case 'pet care':
        return Icons.pets_rounded;
      case 'eventos':
        return Icons.celebration_rounded;
      default:
        return Icons.miscellaneous_services_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.outline),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppColors.primarySoft,
                    borderRadius: BorderRadius.circular(13),
                  ),
                  child: Icon(
                    _iconeParaCategoria(item.categoriaNome),
                    color: AppColors.primary,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.servicoNome,
                        style: AppTextStyles.titulo,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(item.categoriaNome, style: AppTextStyles.legenda),
                    ],
                  ),
                ),
                if (!item.ativo) const _ChipDesativado(),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              item.descricao,
              style: AppTextStyles.corpo,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 14),
            const Divider(height: 1, color: AppColors.outline),
            const SizedBox(height: 12),
            Row(
              children: [
                _AvaliacaoBadge(
                  media: item.mediaAvaliacaoServico,
                  quantidade: item.quantidadeAvaliacoesServico,
                ),
                const Spacer(),
                Text(_formatarValor(item.valor), style: AppTextStyles.preco),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ChipDesativado extends StatelessWidget {
  const _ChipDesativado();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.surfaceAlt,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        'Desativado',
        style: AppTextStyles.label.copyWith(
          color: AppColors.textoSecundario,
          fontSize: 11,
        ),
      ),
    );
  }
}

class _AvaliacaoBadge extends StatelessWidget {
  final double? media;
  final int quantidade;
  const _AvaliacaoBadge({required this.media, required this.quantidade});

  @override
  Widget build(BuildContext context) {
    if (media == null || quantidade == 0) {
      return Text('Sem avaliações', style: AppTextStyles.legenda);
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.avaliacao.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.star_rounded, size: 15, color: AppColors.avaliacao),
          const SizedBox(width: 4),
          Text(media!.toStringAsFixed(1), style: AppTextStyles.label),
          const SizedBox(width: 3),
          Text('($quantidade)', style: AppTextStyles.legenda),
        ],
      ),
    );
  }
}
