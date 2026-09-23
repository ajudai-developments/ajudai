import 'package:flutter/material.dart';
import 'package:shared/shared.dart';

import '../../core/errors/erro_mapper.dart';
import '../../core/routes/app_routes.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/error_banner.dart';
import '../../core/widgets/rating_display.dart';
import '../../core/widgets/user_avatar.dart';
import '../../core/ws/ws_message_stream.dart';
import '../servico/servico_repository.dart';
import '../agendamento/criar_agendamento_args.dart';
import 'widgets/comentarios_list.dart';
import 'widgets/selos_list.dart';

/// Perfil público de um prestador — visualização somente leitura.
///
/// LIMITAÇÃO DE BACKEND (documentada, não é um bug daqui): não existe
/// endpoint pra "obter perfil de um usuário" de forma genérica — só
/// `obterServicoOferecido`, que devolve o perfil do prestador NO
/// CONTEXTO de UM serviço oferecido específico (média de avaliação,
/// selos e comentários são os do prestador; mas a lista de "serviços
/// oferecidos" que aparece aqui é só ESSE UM serviço, não todos os que
/// o prestador oferece).
///
/// Por isso esta tela recebe um `servicoOferecidoId` (String) via
/// argumento da rota — não um `usuarioId` solto, que não teria como ser
/// usado pra buscar nada hoje. Cobre o caso real mais comum (tocar no
/// nome do prestador a partir de um serviço específico), mas:
/// - Não existe perfil de CLIENTE (quem só comenta, sem ser prestador)
///   — não há nenhum endpoint que devolva dados de um usuário nesse caso.
/// - Não lista todos os serviços do prestador, só o de origem.
///
/// Quando o backend ganhar um endpoint de perfil de verdade, esta tela
/// deve passar a receber `usuarioId` e este TODO inteiro pode sair.
class PerfilPublicoScreen extends StatefulWidget {
  const PerfilPublicoScreen({super.key});

  @override
  State<PerfilPublicoScreen> createState() => _PerfilPublicoScreenState();
}

class _PerfilPublicoScreenState extends State<PerfilPublicoScreen> {
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

  void _abrirServico() {
    Navigator.of(context).pushNamed(
      AppRoutes.servicoDetalhe,
      arguments: _servicoOferecidoId,
    );
  }

  @override
  Widget build(BuildContext context) {
    final dados = _dados;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: Text(dados?.prestador.nome ?? 'Perfil')),
      body: RefreshIndicator(
        onRefresh: _carregar,
        child: _carregando
            ? const Center(child: CircularProgressIndicator())
            : ListView(
                padding: const EdgeInsets.all(24),
                children: [
                  ErrorBanner(mensagem: _erro),
                  if (dados != null) ..._buildConteudo(dados),
                ],
              ),
      ),
    );
  }

  List<Widget> _buildConteudo(ObterServicoOferecidoResponseDto dados) {
    return [
      Center(
        child: UserAvatar(
          avatarUrl: dados.prestador.avatarUrl,
          radius: 40,
        ),
      ),
      const SizedBox(height: 12),
      Text(dados.prestador.nome, style: AppTextStyles.titulo, textAlign: TextAlign.center),
      if (dados.prestador.verificado) ...[
        const SizedBox(height: 4),
        const Center(
          child: Chip(
            avatar: Icon(Icons.verified, size: 16, color: Colors.white),
            label: Text('Verificado', style: TextStyle(color: Colors.white)),
            backgroundColor: AppColors.success,
          ),
        ),
      ],
      const SizedBox(height: 8),
      Center(
        child: RatingDisplay(
          media: dados.mediaAvaliacao,
          quantidadeAvaliacoes: dados.quantidadeAvaliacoes,
        ),
      ),
      const SizedBox(height: 24),
      if (dados.selos.isNotEmpty) ...[
        Text('Selos', style: AppTextStyles.titulo),
        const SizedBox(height: 8),
        SelosList(selos: dados.selos),
        const SizedBox(height: 24),
      ],
      Text('Serviço', style: AppTextStyles.titulo),
      const SizedBox(height: 4),
      // TODO: quando existir endpoint de "listar serviços por
      // prestador", trocar este card único por uma lista de
      // ServicoCard com todos os serviços que ele oferece.
      Card(
        child: ListTile(
          onTap: _abrirServico,
          title: Text(dados.servico.nome),
          subtitle: Text('R\$ ${dados.servicoOferecido.valor.toStringAsFixed(2)}'),
          trailing: TextButton(
            onPressed: () => Navigator.of(context).pushNamed(
              AppRoutes.criarAgendamento,
              arguments: CriarAgendamentoArgs(
                servicoOferecidoId: _servicoOferecidoId,
                prestadorId: dados.prestador.id,
              ),
            ),
            child: const Text('Agendar'),
          ),
        ),
      ),
      const SizedBox(height: 24),
      Text('Comentários', style: AppTextStyles.titulo),
      const SizedBox(height: 8),
      ComentariosList(comentarios: dados.comentarios),
      // TODO: agenda de disponibilidade (dias/horários livres do
      // prestador) — combinado que fica pra depois, sem backend ainda.
    ];
  }
}