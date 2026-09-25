import 'package:ajudai/features/servico/widgets/comentarios_servico_list.dart';
import 'package:flutter/material.dart';
import 'package:shared/shared.dart';

import '../../../core/errors/erro_mapper.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/error_banner.dart';
import '../../../core/ws/ws_message_stream.dart';
import '../../agendamento/criar_agendamento_args.dart';
import '../../servico/servico_repository.dart';
import 'selos_list.dart';

/// Abre o detalhe de um serviço oferecido dentro de um bottom sheet.
///
/// Usado a partir do perfil público do prestador — evita navegar pra uma
/// tela de detalhe que também mostra dados do prestador, o que criaria
/// um loop de navegação (perfil → detalhe → perfil de novo).
///
/// Aqui NÃO mostramos nome/avatar/nota do prestador (já visíveis na
/// tela de trás); só o que é específico do serviço em si: descrição,
/// avaliação e comentários daquele serviço, e um atalho pra agendar.
Future<void> abrirModalDetalheServico({
  required BuildContext context,
  required String servicoOferecidoId,
  required String prestadorId,
}) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => _ModalDetalheServico(
      servicoOferecidoId: servicoOferecidoId,
      prestadorId: prestadorId,
    ),
  );
}

class _ModalDetalheServico extends StatefulWidget {
  final String servicoOferecidoId;
  final String prestadorId;

  const _ModalDetalheServico({
    required this.servicoOferecidoId,
    required this.prestadorId,
  });

  @override
  State<_ModalDetalheServico> createState() => _ModalDetalheServicoState();
}

class _ModalDetalheServicoState extends State<_ModalDetalheServico> {
  final _repository = ServicoRepository();

  bool _carregando = true;
  String? _erro;
  ObterServicoOferecidoResponseDto? _dados;

  @override
  void initState() {
    super.initState();
    _carregar();
  }

  Future<void> _carregar() async {
    setState(() {
      _carregando = true;
      _erro = null;
    });

    try {
      final dados = await _repository.obterServicoOferecido(
        servicoOferecidoId: widget.servicoOferecidoId,
      );
      if (!mounted) return;
      setState(() => _dados = dados);
    } on WsErroException catch (e) {
      if (!mounted) return;
      setState(() {
        _erro = ErroMapper.paraMensagem(e.codigo, mensagemServidor: e.mensagem);
      });
    } on WsTimeoutException {
      if (!mounted) return;
      setState(() => _erro = 'Não foi possível carregar o serviço.');
    } finally {
      if (mounted) setState(() => _carregando = false);
    }
  }

  void _agendar() {
    Navigator.of(context).pop(); // fecha o modal
    Navigator.of(context).pushNamed(
      AppRoutes.criarAgendamento,
      arguments: CriarAgendamentoArgs(
        servicoOferecidoId: widget.servicoOferecidoId,
        prestadorId: widget.prestadorId,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.75,
      minChildSize: 0.4,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              const SizedBox(height: 10),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFFE0E0E0),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Expanded(
                child: _carregando
                    ? const Center(child: CircularProgressIndicator())
                    : ListView(
                        controller: scrollController,
                        padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
                        children: [
                          ErrorBanner(mensagem: _erro),
                          if (_dados != null) ..._buildConteudo(_dados!),
                        ],
                      ),
              ),
              if (_dados != null)
                SafeArea(
                  top: false,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
                    child: SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        style: FilledButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: _agendar,
                        child: const Text('Agendar este serviço'),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  List<Widget> _buildConteudo(ObterServicoOferecidoResponseDto dados) {
    return [
      Text(dados.servico.nome, style: AppTextStyles.titulo),
      const SizedBox(height: 4),
      Text(
        dados.categoria.nome,
        style: const TextStyle(fontSize: 13, color: Colors.black45),
      ),
      const SizedBox(height: 10),
      Row(
        children: [
          Text(
            'R\$ ${dados.servicoOferecido.valor.toStringAsFixed(2)}',
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
          const Spacer(),
          if (dados.mediaAvaliacao != null) ...[
            const Icon(Icons.star, size: 16, color: Colors.amber),
            const SizedBox(width: 4),
            Text(
              dados.mediaAvaliacao!.toStringAsFixed(1),
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(width: 4),
            Text(
              '(${dados.quantidadeAvaliacoes})',
              style: const TextStyle(fontSize: 12.5, color: Colors.black45),
            ),
          ],
        ],
      ),
      if (dados.servicoOferecido.descricao.isNotEmpty) ...[
        const SizedBox(height: 16),
        Text(
          dados.servicoOferecido.descricao,
          style: TextStyle(color: Colors.black.withValues(alpha: 0.75)),
        ),
      ],
      if (dados.selos.isNotEmpty) ...[
        const SizedBox(height: 20),
        Text('Selos do prestador', style: AppTextStyles.titulo),
        const SizedBox(height: 8),
        SelosList(selos: dados.selos),
      ],
      const SizedBox(height: 24),
      Text('Comentários sobre este serviço', style: AppTextStyles.titulo),
      const SizedBox(height: 10),
      ComentariosServicoList(comentarios: dados.comentariosServico),
    ];
  }
}
