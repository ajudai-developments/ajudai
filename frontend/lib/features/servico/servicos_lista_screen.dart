import 'package:ajudai/core/layout/responsivo.dart';
import 'package:ajudai/core/theme/app_text_styles.dart';
import 'package:ajudai/core/widgets/grade_adaptativa.dart';
import 'package:flutter/material.dart';
import 'package:shared/shared.dart';

import '../../core/routes/app_routes.dart';
import '../../core/widgets/async_list_view.dart';
import '../../core/widgets/servico_card.dart';
import '../../core/widgets/tela_adaptativa.dart';
import '../agendamento/criar_agendamento_args.dart';
import 'servico_repository.dart';

/// (mantenha o comentário de documentação original aqui)
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

    return TelaAdaptativa(
      titulo: titulo,
      rotaAtual: AppRoutes.categorias, // mantém "Serviços" ativo na sidebar
      child: AsyncListView<ServicoOferecidoPreview>(
        carregar: carregar,
        mensagemVazio: mensagemVazio,
        builder: (context, servicos) {
          final cards = [
            for (final servico in servicos)
              ServicoCard(
                servico: servico,
                onTapDetalhe: () => _abrirDetalhe(context, servico),
                onTapAgendar: () => _abrirAgendamento(context, servico),
              ),
          ];

          // Mobile: igual ao original.
          if (!context.usaLayoutWeb) {
            return ConteudoCentralizado(
              larguraMax: 720, // evita esticar em tablet nativo
              child: Column(children: cards),
            );
          }

          return ConteudoCentralizado(
            larguraMax: 1200,
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    servicos.length == 1
                        ? '1 prestador disponível'
                        : '${servicos.length} prestadores disponíveis',
                    style: AppTextStyles.legenda,
                  ),
                  const SizedBox(height: 16),
                  GradeAdaptativa(children: cards),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
