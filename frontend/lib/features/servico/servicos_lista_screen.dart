import 'package:flutter/material.dart';
import 'package:shared/shared.dart';

import '../../core/routes/app_routes.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/async_list_view.dart';
import 'servico_repository.dart';

/// Lista os TIPOS de serviço (catálogo) de uma categoria — ex: dentro
/// de "Faxina", os tipos poderiam ser "Faxina residencial", "Faxina
/// comercial", etc. Cada tipo pode ter vários prestadores oferecendo.
///
/// Recebe a `Categoria` inteira via argumento da rota (não só o id),
/// já que categorias_screen tem esse objeto em mãos — evita uma segunda
/// chamada só pra saber o nome da categoria pro título da AppBar.
///
/// Ao tocar num tipo, o próximo passo seria ver as OFERTAS desse tipo
/// (prestadores oferecendo, com valor/avaliação — isso é o que
/// ServicoCard já foi desenhado pra mostrar). Isso ainda não está
/// implementado: o backend não tem o DTO de `listarServicosOferecidos`
/// pronto ainda (ver TODO em servico_repository.dart), então por
/// enquanto a navegação cai no fallback "Em construção" do app.dart.
class ServicosListaScreen extends StatelessWidget {
  const ServicosListaScreen({super.key});

  void _abrirOfertasDoTipo(BuildContext context, Servico servico) {
    Navigator.of(
      context,
    ).pushNamed(AppRoutes.servicosLista, arguments: servico);
  }

  @override
  Widget build(BuildContext context) {
    final categoria = ModalRoute.of(context)!.settings.arguments as Categoria;
    final servicoRepository = ServicoRepository();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: Text(categoria.nome)),
      body: AsyncListView<Servico>(
        carregar: () =>
            servicoRepository.listarServicos(categoriaId: categoria.id),
        mensagemVazio:
            'Nenhum tipo de serviço disponível nessa categoria ainda.',
        builder: (context, servicos) => Column(
          children: [
            for (final servico in servicos)
              Card(
                child: ListTile(
                  title: Text(servico.nome, style: AppTextStyles.corpo),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => _abrirOfertasDoTipo(context, servico),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
