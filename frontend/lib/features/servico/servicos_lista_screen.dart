import 'package:flutter/material.dart';
import 'package:shared/shared.dart';

import '../../core/routes/app_routes.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/async_list_view.dart';
import '../../core/widgets/servico_card.dart';
import '../agendamento/criar_agendamento_args.dart';
import 'servico_repository.dart';

/// Lista as OFERTAS (prestadores + valor + avaliação) de uma categoria
/// inteira OU de um serviço específico — a tela é a mesma, só muda a
/// origem dos dados. O argumento da rota decide:
///
/// - [Categoria] (vindo de categorias_screen / Home): lista as ofertas da
///   categoria inteira, sem passar por uma etapa de "tipo de serviço".
/// - [ServicoRecente] (vindo dos "Serviços recentes" da Home): lista os
///   prestadores que oferecem aquele serviço específico.
///
/// Recebe o objeto inteiro (não só o id), já que quem navega tem ele em
/// mãos — evita uma segunda chamada só pra saber o nome pro título.
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
      arguments: CriarAgendamentoArgs(
        servicoOferecidoId: servico.servicoOferecidoId,
        prestadorId: servico.prestadorId,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)!.settings.arguments;
    final servicoRepository = ServicoRepository();

    final String titulo;
    final String mensagemVazio;
    final Future<List<ServicoOferecidoPreview>> Function() carregar;

    if (args is Categoria) {
      titulo = args.nome;
      mensagemVazio = 'Nenhum serviço disponível nessa categoria ainda.';
      carregar = () =>
          servicoRepository.listarServicosOferecidos(categoriaId: args.id);
    } else if (args is ServicoRecente) {
      titulo = args.servicoNome;
      mensagemVazio = 'Nenhum prestador disponível para esse serviço agora.';
      carregar = () => servicoRepository.listarServicosOferecidosPorServicoId(
        servicoId: args.servicoId,
      );
    } else {
      throw ArgumentError(
        'ServicosListaScreen espera uma Categoria ou um ServicoRecente '
        'como argumento da rota, mas recebeu ${args.runtimeType}.',
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: Text(titulo)),
      body: AsyncListView<ServicoOferecidoPreview>(
        carregar: carregar,
        mensagemVazio: mensagemVazio,
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
