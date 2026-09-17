import 'package:flutter/material.dart';
import 'package:shared/shared.dart';

import '../../core/routes/app_routes.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/async_list_view.dart';
import '../../core/widgets/servico_card.dart';
import 'servico_repository.dart';

/// Lista as OFERTAS (prestadores + valor + avaliação) de uma categoria
/// inteira — não passa por uma etapa de "tipo de serviço"; o request de
/// ofertas já filtra direto por categoria.
///
/// Recebe a `Categoria` inteira via argumento da rota (não só o id),
/// já que categorias_screen tem esse objeto em mãos — evita uma segunda
/// chamada só pra saber o nome da categoria pro título da AppBar.
class ServicosListaScreen extends StatelessWidget {
  const ServicosListaScreen({super.key});

  void _abrirDetalhe(BuildContext context, ServicoOferecidoPreview servico) {
    Navigator.of(context).pushNamed(
      AppRoutes.servicoDetalhe,
      arguments: servico.servicoOferecidoId,
    );
  }

  void _abrirAgendamento(
    BuildContext context,
    ServicoOferecidoPreview servico,
  ) {
    Navigator.of(context).pushNamed(
      AppRoutes.criarAgendamento,
      arguments: servico.servicoOferecidoId,
    );
  }

  @override
  Widget build(BuildContext context) {
    final categoria = ModalRoute.of(context)!.settings.arguments as Categoria;
    final servicoRepository = ServicoRepository();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: Text(categoria.nome)),
      body: AsyncListView<ServicoOferecidoPreview>(
        carregar: () => servicoRepository.listarServicosOferecidos(
          categoriaId: categoria.id,
        ),
        mensagemVazio: 'Nenhum serviço disponível nessa categoria ainda.',
        builder: (context, servicos) => Column(
          children: [
            for (final servico in servicos)
              ServicoCard(
                servico: servico,
                onTapDetalhe: () => _abrirDetalhe(context, servico),
                onTapAgendar: () => _abrirAgendamento(context, servico),
              ),
          ],
        ),
      ),
    );
  }
}
