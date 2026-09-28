import 'package:ajudai/core/layout/responsivo.dart';
import 'package:ajudai/core/session/permissoes.dart';
import 'package:ajudai/core/session/sessao.dart';
import 'package:ajudai/core/widgets/login_necessario_dialog.dart';
import 'package:ajudai/core/widgets/tela_adaptativa.dart';
import 'package:ajudai/core/widgets/user_avatar.dart';
import 'package:ajudai/features/servico/widgets/comentarios_servico_list.dart';
import 'package:flutter/material.dart';
import 'package:shared/shared.dart';

import '../../core/errors/erro_mapper.dart';
import '../../core/ws/ws_message_stream.dart';
import '../../core/routes/app_routes.dart';
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

  static final _decoracaoCard = BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(14),
    border: Border.all(color: const Color(0xFFEDEDED)),
  );

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
    if (!LoginNecessarioDialog.exigir(
      context,
      mensagem: 'Entre na sua conta para agendar este serviço.',
    )) {
      return;
    }

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
    final web = context.usaLayoutWeb;

    return TelaAdaptativa(
      titulo: dados?.servico.nome ?? 'Serviço',
      rotaAtual: AppRoutes.categorias,
      rodapeMobile: dados == null
          ? null
          : SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: _acaoAgendar(),
              ),
            ),
      child: _carregando
          ? const Center(child: CircularProgressIndicator())
          : web
          ? _corpoWeb(dados)
          : _corpoMobile(dados),
    );
  }

  Widget _acaoAgendar() {
    final pode = Sessao.instance.permissoes.pode(Capacidade.criarAgendamento);

    if (pode) {
      return SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: _agendar,
          child: const Text('Agendar'),
        ),
      );
    }

    return Text(
      'Utilize o app do ajudaí para criar um agendamento com este prestador',
      style: AppTextStyles.corpo,
    );
  }

  Widget _corpoMobile(ObterServicoOferecidoResponseDto? dados) {
    return ConteudoCentralizado(
      larguraMax: 720, // tablet nativo
      child: RefreshIndicator(
        onRefresh: _carregar,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            ErrorBanner(mensagem: _erro),
            if (dados != null) ...[
              _cabecalho(dados, comPreco: true),
              const SizedBox(height: 16),
              ..._blocosPrincipais(dados),
              const SizedBox(height: 80), // espaço pro botão fixo
            ],
          ],
        ),
      ),
    );
  }

  Widget _corpoWeb(ObterServicoOferecidoResponseDto? dados) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(32),
      child: ConteudoCentralizado(
        larguraMax: 1100,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ErrorBanner(mensagem: _erro),
            if (dados != null)
              context.ehDesktop
                  ? Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(child: _colunaPrincipalWeb(dados)),
                        const SizedBox(width: 32),
                        SizedBox(width: 340, child: _cardLateral(dados)),
                      ],
                    )
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _cardLateral(dados),
                        const SizedBox(height: 24),
                        _colunaPrincipalWeb(dados),
                      ],
                    ),
          ],
        ),
      ),
    );
  }

  Widget _colunaPrincipalWeb(ObterServicoOferecidoResponseDto dados) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _cabecalho(dados, comPreco: false),
        const SizedBox(height: 24),
        ..._blocosPrincipais(dados),
      ],
    );
  }

  Widget _cardLateral(ObterServicoOferecidoResponseDto dados) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: _decoracaoCard,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'R\$ ${dados.servicoOferecido.valor.toStringAsFixed(2)}',
            style: AppTextStyles.titulo,
          ),
          const SizedBox(height: 4),
          Text('Valor do serviço', style: AppTextStyles.legenda),
          const SizedBox(height: 16),
          _acaoAgendar(),
        ],
      ),
    );
  }

  // ---------- blocos reaproveitados nos dois layouts ----------

  Widget _cabecalho(
    ObterServicoOferecidoResponseDto dados, {
    required bool comPreco,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(dados.servico.nome, style: AppTextStyles.titulo),
        Text(dados.categoria.nome, style: AppTextStyles.legenda),
        if (comPreco) ...[
          const SizedBox(height: 8),
          Text(
            'R\$ ${dados.servicoOferecido.valor.toStringAsFixed(2)}',
            style: AppTextStyles.titulo,
          ),
        ],
      ],
    );
  }

  List<Widget> _blocosPrincipais(ObterServicoOferecidoResponseDto dados) {
    return [
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
                  const SizedBox(height: 2),
                  RatingDisplay(
                    media: dados.mediaAvaliacaoServico,
                    quantidadeAvaliacoes: dados.quantidadeAvaliacoesServico,
                  ),
                  Text(
                    'Avaliação deste serviço',
                    style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
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
    ];
  }
}
