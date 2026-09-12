import 'package:flutter/material.dart';

import '../../core/routes/app_routes.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/async_list_view.dart';
import '../servico/servico_repository.dart';
import 'prestador_repository.dart';
import 'servico_oferecido_com_detalhes.dart';

/// Lista os serviços que o prestador logado oferece.
///
/// Sem edição/remoção (não existe endpoint pra isso ainda) — toque no
/// card só abre o detalhe público do serviço (mesma tela que um
/// cliente veria), útil pra conferir como está aparecendo.
class MeusServicosOferecidosScreen extends StatelessWidget {
  const MeusServicosOferecidosScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final prestadorRepository = PrestadorRepository();
    final servicoRepository = ServicoRepository();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Meus serviços oferecidos')),
      body: AsyncListView<ServicoOferecidoComDetalhes>(
        carregar: () async {
          final servicos = await prestadorRepository.listarMeusServicosOferecidos();
          return carregarServicosOferecidosComDetalhes(servicos, servicoRepository);
        },
        mensagemVazio: 'Você ainda não tem serviços cadastrados.',
        builder: (context, itens) => Column(
          children: [
            for (final item in itens)
              Card(
                child: ListTile(
                  onTap: () => Navigator.of(context).pushNamed(
                    AppRoutes.servicoDetalhe,
                    arguments: item.servicoOferecido.id,
                  ),
                  title: Text(item.nomeServico, style: AppTextStyles.titulo),
                  subtitle: Text(
                    '${item.nomeCategoria}\n${item.servicoOferecido.descricao}',
                    style: AppTextStyles.corpo,
                  ),
                  isThreeLine: true,
                  trailing: Text(
                    'R\$ ${item.servicoOferecido.valor.toStringAsFixed(2)}',
                    style: AppTextStyles.corpo,
                  ),
                ),
              ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.of(context).pushNamed(AppRoutes.formServicoOferecido),
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add),
        label: const Text('Adicionar serviço'),
      ),
    );
  }
}