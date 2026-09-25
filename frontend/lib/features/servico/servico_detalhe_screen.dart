import 'package:ajudai/core/widgets/user_avatar.dart';
import 'package:ajudai/features/servico/widgets/comentarios_servico_list.dart';
import 'package:flutter/material.dart';
import 'package:shared/shared.dart';

import '../../core/errors/erro_mapper.dart';
import '../../core/ws/ws_message_stream.dart';
import '../../core/routes/app_routes.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/error_banner.dart';
import '../../core/widgets/rating_display.dart';
import '../perfil/widgets/selos_list.dart';
import '../agendamento/criar_agendamento_args.dart';
import 'servico_repository.dart';

/// Detalhe completo de um serviço oferecido: dados do serviço, do
/// prestador, selos conquistados e comentários de quem já avaliou.
///
/// Recebe o `servicoOferecidoId` (String) via argumento da rota.
///
/// Não usa AsyncListView porque essa tela carrega UM objeto
/// (ObterServicoOferecidoResponseDto), não uma lista.
class ServicoDetalheScreen extends StatefulWidget {
  const ServicoDetalheScreen({super.key});

  @override
  State<ServicoDetalheScreen> createState() => _ServicoDetalheScreenState();
}

class _ServicoDetalheScreenState extends State<ServicoDetalheScreen> {
  final _servicoRepository = ServicoRepository();

  late String _servicoOferecidoId;
  bool _argumentosCarregados = false;

  bool _carregando = true;
  String? _erro;
  ObterServicoOferecidoResponseDto? _dados;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_argumentosCarregados) return;
    _argumentosCarregados = true;

    _servicoOferecidoId = ModalRoute.of(context)!.settings.arguments as String;
    _carregar();
  }

  Future<void> _carregar() async {
    setState(() {
      _carregando = true;
      _erro = null;
    });

    try {
      final dados = await _servicoRepository.obterServicoOferecido(
        servicoOferecidoId: _servicoOferecidoId,
      );
      setState(() => _dados = dados);
    } on WsErroException catch (e) {
      setState(() {
        _erro = ErroMapper.paraMensagem(e.codigo, mensagemServidor: e.mensagem);
      });
    } on WsTimeoutException {
      setState(() {
        _erro = 'Não foi possível conectar ao servidor. Tente novamente.';
      });
    } finally {
      if (mounted) setState(() => _carregando = false);
    }
  }

  void _abrirPerfilPrestador() {
    Navigator.of(
      context,
    ).pushNamed(AppRoutes.perfilPublico, arguments: _dados!.prestador.id);
  }

  void _agendar() {
    Navigator.of(context).pushNamed(
      AppRoutes.criarAgendamento,
      arguments: CriarAgendamentoArgs(
        servicoOferecidoId: _servicoOferecidoId,
        prestadorId: _dados!.prestador.id,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final dados = _dados;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: Text(dados?.servico.nome ?? 'Serviço')),
      body: RefreshIndicator(
        onRefresh: _carregar,
        child: _carregando
            ? const Center(child: CircularProgressIndicator())
            : ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  ErrorBanner(mensagem: _erro),
                  if (dados != null) ..._buildConteudo(dados),
                ],
              ),
      ),
      bottomNavigationBar: dados == null
          ? null
          : SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: ElevatedButton(
                  onPressed: _agendar,
                  child: const Text('Agendar'),
                ),
              ),
            ),
    );
  }

  List<Widget> _buildConteudo(ObterServicoOferecidoResponseDto dados) {
    return [
      Text(dados.servico.nome, style: AppTextStyles.titulo),
      Text(dados.categoria.nome, style: AppTextStyles.legenda),
      const SizedBox(height: 8),
      Text(
        'R\$ ${dados.servicoOferecido.valor.toStringAsFixed(2)}',
        style: AppTextStyles.titulo,
      ),
      const SizedBox(height: 16),
      InkWell(
        onTap: _abrirPerfilPrestador,
        child: Row(
          children: [
            UserAvatar(avatarUrl: dados.prestador.avatarUrl, radius: 24),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(dados.prestador.nome, style: AppTextStyles.corpo),
                  RatingDisplay(
                    media: dados.mediaAvaliacao,
                    quantidadeAvaliacoes: dados.quantidadeAvaliacoes,
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right),
          ],
        ),
      ),
      const SizedBox(height: 16),
      Text('Descrição', style: AppTextStyles.titulo),
      const SizedBox(height: 4),
      Text(dados.servicoOferecido.descricao, style: AppTextStyles.corpo),
      if (dados.selos.isNotEmpty) ...[
        const SizedBox(height: 16),
        Text('Selos', style: AppTextStyles.titulo),
        const SizedBox(height: 8),
        SelosList(selos: dados.selos),
      ],
      const SizedBox(height: 16),
      Text('Comentários', style: AppTextStyles.titulo),
      const SizedBox(height: 8),
      ComentariosServicoList(comentarios: dados.comentariosServico),
      const SizedBox(height: 80), // espaço pro botão fixo de agendar
    ];
  }
}
