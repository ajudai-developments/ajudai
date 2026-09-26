import 'package:ajudai/core/routes/app_routes.dart';
import 'package:ajudai/core/ws/ws_message_stream.dart';
import 'package:ajudai/features/agendamento/agendamento_acoes.dart';
import 'package:ajudai/features/agendamento/widgets/dialogo_cancelar_agendamento.dart';
import 'package:ajudai/features/avaliacao/avaliar_agendamento_args.dart';
import 'package:ajudai/features/conversas/conversas_repository.dart';
import 'package:flutter/material.dart';
import 'package:shared/shared.dart';

import '../../core/errors/erro_mapper.dart';
import '../../core/session/sessao.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/error_banner.dart';
import '../../core/widgets/user_avatar.dart';
import 'agendamento_repository.dart';
import 'widgets/arquivos_anexados_grid.dart';
import 'widgets/status_badge.dart';
import 'widgets/timeline_agendamento_view.dart';

/// Tela de detalhes completos de um agendamento — serve tanto pra quem
/// é cliente quanto pra quem é prestador daquele agendamento; a própria
/// tela decide o que exibir como "a outra pessoa" com base em quem está
/// logado.
///
/// Não recebe o id via construtor — segue o padrão do resto do app de
/// ler direto de `ModalRoute.of(context)!.settings.arguments`.
class AgendamentoDetalhadoScreen extends StatefulWidget {
  const AgendamentoDetalhadoScreen({super.key});

  @override
  State<AgendamentoDetalhadoScreen> createState() =>
      _AgendamentoDetalhadoScreenState();
}

class _AgendamentoDetalhadoScreenState
    extends State<AgendamentoDetalhadoScreen> {
  final _repository = AgendamentoRepository();
  final _conversasRepository = ConversasRepository();

  bool _executandoAcao = false;
  bool _enviandoParaChat = false;

  late String _agendamentoId;
  bool _carregado = false;

  bool _carregando = true;
  String? _erro;
  AgendamentoDetalhadoComUrls? _dados;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_carregado) {
      _carregado = true;
      _agendamentoId = ModalRoute.of(context)!.settings.arguments as String;
      _carregar();
    }
  }

  Future<void> _carregar() async {
    setState(() {
      _carregando = true;
      _erro = null;
    });

    try {
      final dados = await _repository.buscarAgendamentoDetalhado(
        _agendamentoId,
      );
      setState(() => _dados = dados);
    } on WsErroException catch (e) {
      setState(
        () => _erro = ErroMapper.paraMensagem(
          e.codigo,
          mensagemServidor: e.mensagem,
        ),
      );
    } on WsTimeoutException {
      setState(() => _erro = 'Não foi possível carregar o agendamento.');
    } finally {
      if (mounted) setState(() => _carregando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Detalhes do agendamento')),
      body: SafeArea(child: _buildBody()),
    );
  }

  Widget _buildBody() {
    if (_carregando) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_erro != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ErrorBanner(mensagem: _erro),
              TextButton.icon(
                onPressed: _carregar,
                icon: const Icon(Icons.refresh),
                label: const Text('Tentar novamente'),
              ),
            ],
          ),
        ),
      );
    }

    final dados = _dados;
    if (dados == null) return const SizedBox.shrink();

    final agendamento = dados.agendamento;
    final meuId = Sessao.instance.usuario!.id;
    final souCliente = agendamento.souCliente(meuId);

    return RefreshIndicator(
      onRefresh: _carregar,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildHeader(agendamento, souCliente: souCliente),
          const SizedBox(height: 16),
          _buildContraparte(agendamento, souCliente: souCliente),
          const SizedBox(height: 16),
          _buildAcoes(agendamento, souCliente: souCliente),
          const SizedBox(height: 16),
          _buildSecao(
            titulo: 'Endereço',
            icone: Icons.location_on_outlined,
            child: _buildEndereco(agendamento),
          ),
          if (agendamento.solicitacaoPrecoPendente != null) ...[
            const SizedBox(height: 16),
            _buildSolicitacaoPreco(agendamento.solicitacaoPrecoPendente!),
          ],
          if (dados.contestacaoComUrls != null) ...[
            const SizedBox(height: 16),
            _buildContestacao(dados.contestacaoComUrls!),
          ],
          if (agendamento.avaliacaoFeitaPorMim != null ||
              agendamento.avaliacaoRecebidaPorMim != null) ...[
            const SizedBox(height: 16),
            _buildAvaliacoes(agendamento),
          ],
          const SizedBox(height: 16),
          _buildSecao(
            titulo: 'Linha do tempo',
            icone: Icons.history,
            child: TimelineAgendamentoView(itens: agendamento.timeline),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(AgendamentoDetalhado a, {required bool souCliente}) {
    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(a.servicoNome, style: AppTextStyles.titulo),
                    const SizedBox(height: 2),
                    Text(
                      a.categoriaNome,
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              StatusBadge(status: a.status),
            ],
          ),
          const SizedBox(height: 12),
          Divider(height: 1, color: Colors.black.withValues(alpha: 0.06)),
          const SizedBox(height: 12),
          _linhaInfo(
            Icons.calendar_today_outlined,
            _formatarPeriodo(a.horaInicio, a.horaFim),
          ),
          const SizedBox(height: 8),
          _linhaInfo(Icons.attach_money, _formatarValor(a.valor)),
          if (souCliente && a.servicoOferecidoDescricao.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(a.servicoOferecidoDescricao, style: AppTextStyles.corpo),
          ],
        ],
      ),
    );
  }

  Future<void> _abrirConversaCom(String usuarioId) async {
    setState(() => _enviandoParaChat = true);
    try {
      final conversaId = await _conversasRepository.criarConversa(usuarioId);
      final conversas = await _conversasRepository.listarConversas();
      final conversa = conversas.firstWhere((c) => c.conversaId == conversaId);

      if (!mounted) return;
      await Navigator.of(
        context,
      ).pushNamed(AppRoutes.conversa, arguments: conversa);
    } on WsErroException catch (e) {
      _mostrarErroAcao(
        ErroMapper.paraMensagem(e.codigo, mensagemServidor: e.mensagem),
      );
    } on WsTimeoutException {
      _mostrarErroAcao('Não foi possível abrir a conversa.');
    } finally {
      if (mounted) setState(() => _enviandoParaChat = false);
    }
  }

  Widget _buildContraparte(AgendamentoDetalhado a, {required bool souCliente}) {
    final nome = souCliente ? a.prestadorNome : a.clienteNome;
    final avatarUrl = souCliente ? a.prestadorAvatarUrl : a.clienteAvatarUrl;
    final verificado = souCliente ? a.prestadorVerificado : a.clienteVerificado;
    final telefone = souCliente ? a.prestadorTelefone : a.clienteTelefone;
    final papel = souCliente ? 'Prestador' : 'Cliente';
    final idOutro = souCliente ? a.prestadorId : a.clienteId;

    return GestureDetector(
      onTap: () => Navigator.of(
        context,
      ).pushNamed(AppRoutes.perfilPublico, arguments: idOutro),
      child: _Card(
        child: Row(
          children: [
            UserAvatar(avatarUrl: avatarUrl, radius: 24),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          nome,
                          style: const TextStyle(fontWeight: FontWeight.w600),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (verificado) ...[
                        const SizedBox(width: 4),
                        Icon(
                          Icons.verified,
                          size: 16,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ],
                    ],
                  ),
                  Text(
                    papel,
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                  ),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.chat_bubble_outline_rounded),
              tooltip: 'Enviar mensagem',
              onPressed: _enviandoParaChat
                  ? null
                  : () => _abrirConversaCom(idOutro),
            ),
            if (telefone != null)
              IconButton(
                icon: const Icon(Icons.call_outlined),
                onPressed: () {},
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildEndereco(AgendamentoDetalhado a) {
    final linha1 =
        '${a.enderecoLogradouro}, ${a.enderecoNumero}'
        '${a.enderecoComplemento != null ? ' - ${a.enderecoComplemento}' : ''}';
    final linha2 =
        '${a.enderecoBairro}, ${a.enderecoCidade} - ${a.enderecoEstado}';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(linha1, style: AppTextStyles.corpo),
        const SizedBox(height: 2),
        Text(
          linha2,
          style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
        ),
        const SizedBox(height: 2),
        Text(
          'CEP ${a.enderecoCep}',
          style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
        ),
      ],
    );
  }

  Widget _buildSolicitacaoPreco(SolicitacaoPrecoResumo sp) {
    return _buildSecao(
      titulo: 'Solicitação de alteração de preço',
      icone: Icons.price_change_outlined,
      corDestaque: Colors.orange,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                _formatarValor(sp.valorAnterior),
                style: TextStyle(
                  decoration: TextDecoration.lineThrough,
                  color: Colors.grey.shade500,
                ),
              ),
              const SizedBox(width: 8),
              const Icon(Icons.arrow_forward, size: 14),
              const SizedBox(width: 8),
              Text(
                _formatarValor(sp.valorNovo),
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(sp.motivo, style: AppTextStyles.corpo),
        ],
      ),
    );
  }

  Widget _buildContestacao(ContestacaoComUrls c) {
    final ct = c.contestacao;
    return _buildSecao(
      titulo: 'Contestação',
      icone: Icons.report_problem_outlined,
      corDestaque: Colors.red,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Aberta por ${ct.contestadorNome}',
            style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
          ),
          const SizedBox(height: 8),
          Text(ct.descricao, style: AppTextStyles.corpo),
          if (ct.arquivos.isNotEmpty) ...[
            const SizedBox(height: 12),
            ArquivosAnexadosGrid(arquivos: ct.arquivos, urls: c.urlsArquivos),
          ],
          if (ct.respostaAdmin != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Resposta do suporte',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(ct.respostaAdmin!, style: AppTextStyles.corpo),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildAvaliacoes(AgendamentoDetalhado a) {
    return _buildSecao(
      titulo: 'Avaliações',
      icone: Icons.star_outline,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (a.avaliacaoFeitaPorMim != null) ...[
            Text(
              'Sua avaliação',
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
            ),
            const SizedBox(height: 4),
            _EstrelasNotaUnica(nota: a.avaliacaoFeitaPorMim!.avaliacao),
            if (a.avaliacaoFeitaPorMim!.mensagem != null) ...[
              const SizedBox(height: 4),
              Text(
                a.avaliacaoFeitaPorMim!.mensagem!,
                style: AppTextStyles.corpo,
              ),
            ],
          ],
          if (a.avaliacaoFeitaPorMim != null &&
              a.avaliacaoRecebidaPorMim != null)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Divider(height: 1),
            ),
          if (a.avaliacaoRecebidaPorMim != null) ...[
            Text(
              'Avaliação recebida',
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
            ),
            const SizedBox(height: 4),
            _EstrelasNotaUnica(nota: a.avaliacaoRecebidaPorMim!.avaliacao),
            if (a.avaliacaoRecebidaPorMim!.mensagem != null) ...[
              const SizedBox(height: 4),
              Text(
                a.avaliacaoRecebidaPorMim!.mensagem!,
                style: AppTextStyles.corpo,
              ),
            ],
          ],
        ],
      ),
    );
  }

  Widget _buildAcoes(AgendamentoDetalhado a, {required bool souCliente}) {
    final acoes = AcoesAgendamento.calcular(
      status: a.status,
      horaInicio: a.horaInicio,
      horaFim: a.horaFim,
      comoPrestador: !souCliente,
      jaAvaliado: a.avaliacaoFeitaPorMim != null,
    );

    final temAlgo =
        acoes.temAcaoPrincipal || acoes.podeCancelar || acoes.instrucao != null;
    if (!temAlgo) return const SizedBox.shrink();

    final scheme = Theme.of(context).colorScheme;

    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (acoes.instrucao != null)
            Text(acoes.instrucao!, style: AppTextStyles.corpo),
          if (acoes.temAcaoPrincipal || acoes.podeCancelar) ...[
            if (acoes.instrucao != null) const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                if (acoes.podeRecusar)
                  OutlinedButton(
                    onPressed: _executandoAcao
                        ? null
                        : () => _executarAcao(
                            () => _repository.responderAgendamento(
                              agendamentoId: _agendamentoId,
                              aceitar: false,
                            ),
                          ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: scheme.error,
                    ),
                    child: const Text('Recusar'),
                  ),
                if (acoes.podeAceitar)
                  FilledButton(
                    onPressed: _executandoAcao
                        ? null
                        : () => _executarAcao(
                            () => _repository.responderAgendamento(
                              agendamentoId: _agendamentoId,
                              aceitar: true,
                            ),
                          ),
                    child: const Text('Aceitar'),
                  ),
                if (acoes.podeIniciar)
                  FilledButton.icon(
                    onPressed: _executandoAcao
                        ? null
                        : () => _executarAcao(
                            () =>
                                _repository.iniciarAgendamento(_agendamentoId),
                          ),
                    icon: const Icon(Icons.play_arrow_rounded, size: 18),
                    label: const Text('Iniciar atendimento'),
                  ),
                if (acoes.podeConcluir)
                  FilledButton.icon(
                    onPressed: _executandoAcao
                        ? null
                        : () => _executarAcao(
                            () =>
                                _repository.concluirAgendamento(_agendamentoId),
                          ),
                    icon: const Icon(Icons.task_alt_rounded, size: 18),
                    label: const Text('Concluir atendimento'),
                  ),
                if (acoes.podeConfirmarConclusao)
                  FilledButton.icon(
                    onPressed: _executandoAcao ? null : _confirmarConclusao,
                    icon: const Icon(
                      Icons.check_circle_outline_rounded,
                      size: 18,
                    ),
                    label: const Text('Confirmar conclusão'),
                  ),
                if (acoes.podeAvaliar)
                  OutlinedButton.icon(
                    onPressed: _executandoAcao ? null : _irParaAvaliacao,
                    icon: const Icon(Icons.star_border_rounded, size: 18),
                    label: const Text('Avaliar'),
                  ),
                if (acoes.podeCancelar)
                  TextButton(
                    onPressed: _executandoAcao ? null : _cancelar,
                    style: TextButton.styleFrom(foregroundColor: scheme.error),
                    child: const Text('Cancelar'),
                  ),
                if (_executandoAcao)
                  const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _executarAcao(Future<dynamic> Function() chamada) async {
    setState(() => _executandoAcao = true);
    try {
      await chamada();
      await _carregar();
    } on WsErroException catch (e) {
      _mostrarErroAcao(
        ErroMapper.paraMensagem(e.codigo, mensagemServidor: e.mensagem),
      );
    } on WsTimeoutException {
      _mostrarErroAcao(
        'Não foi possível conectar ao servidor. Tente novamente.',
      );
    } finally {
      if (mounted) setState(() => _executandoAcao = false);
    }
  }

  void _mostrarErroAcao(String mensagem) {
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(mensagem)));
  }

  Future<void> _cancelar() async {
    final motivo = await mostrarDialogoCancelarAgendamento(context);
    if (motivo == null) return;
    await _executarAcao(
      () => _repository.cancelarAgendamento(
        agendamentoId: _agendamentoId,
        motivo: motivo,
      ),
    );
  }

  Future<void> _confirmarConclusao() async {
    setState(() => _executandoAcao = true);
    try {
      await _repository.confirmarConclusaoAgendamento(_agendamentoId);
    } on WsErroException catch (e) {
      if (mounted) setState(() => _executandoAcao = false);
      _mostrarErroAcao(
        ErroMapper.paraMensagem(e.codigo, mensagemServidor: e.mensagem),
      );
      return;
    } on WsTimeoutException {
      if (mounted) setState(() => _executandoAcao = false);
      _mostrarErroAcao(
        'Não foi possível conectar ao servidor. Tente novamente.',
      );
      return;
    }
    if (mounted) setState(() => _executandoAcao = false);
    if (!mounted) return;

    await Navigator.of(
      context,
    ).pushNamed(AppRoutes.avaliarAgendamento, arguments: _argsAvaliacao());
    if (mounted) _carregar();
  }

  AvaliarAgendamentoArgs _argsAvaliacao() {
    final a = _dados!.agendamento;
    final souCliente = a.souCliente(Sessao.instance.usuario!.id);
    return AvaliarAgendamentoArgs(
      agendamentoId: _agendamentoId,
      avaliadoId: souCliente ? a.prestadorId : a.clienteId,
      nomeContraparte: souCliente ? a.prestadorNome : a.clienteNome,
      avatarContraparte: souCliente ? a.prestadorAvatarUrl : a.clienteAvatarUrl,
      nomeServico: a.servicoNome,
      papelContraparte: souCliente ? 'Prestador' : 'Cliente',
      avaliarServico: souCliente,
    );
  }

  Future<void> _irParaAvaliacao() async {
    await Navigator.of(
      context,
    ).pushNamed(AppRoutes.avaliarAgendamento, arguments: _argsAvaliacao());
    if (mounted) _carregar();
  }

  Widget _buildSecao({
    required String titulo,
    required IconData icone,
    required Widget child,
    Color? corDestaque,
  }) {
    final cor = corDestaque ?? Theme.of(context).colorScheme.primary;
    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icone, size: 18, color: cor),
              const SizedBox(width: 8),
              Text(
                titulo,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }

  Widget _linhaInfo(IconData icone, String texto) {
    return Row(
      children: [
        Icon(icone, size: 16, color: Colors.grey.shade600),
        const SizedBox(width: 6),
        Text(texto, style: AppTextStyles.corpo),
      ],
    );
  }
}

class _Card extends StatelessWidget {
  final Widget child;
  const _Card({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.black.withValues(alpha: 0.06)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }
}

String _formatarPeriodo(DateTime inicio, DateTime fim) {
  final i = inicio.toLocal();
  final f = fim.toLocal();
  final dia = i.day.toString().padLeft(2, '0');
  final mes = i.month.toString().padLeft(2, '0');
  final horaI =
      '${i.hour.toString().padLeft(2, '0')}:${i.minute.toString().padLeft(2, '0')}';
  final horaF =
      '${f.hour.toString().padLeft(2, '0')}:${f.minute.toString().padLeft(2, '0')}';
  return '$dia/$mes/${i.year}, $horaI - $horaF';
}

String _formatarValor(double valor) {
  return 'R\$ ${valor.toStringAsFixed(2).replaceAll('.', ',')}';
}

/// Estrelas para exibir uma avaliação PONTUAL (0 a 5), diferente de
/// RatingDisplay (que é pra média agregada + contagem). Usado aqui pra
/// mostrar a nota de uma avaliação específica do agendamento.
class _EstrelasNotaUnica extends StatelessWidget {
  final double nota;
  final double tamanho;

  // ignore: unused_element_parameter
  const _EstrelasNotaUnica({required this.nota, this.tamanho = 16});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 1; i <= 5; i++)
          Icon(
            i <= nota
                ? Icons.star
                : (i - 0.5 <= nota ? Icons.star_half : Icons.star_border),
            size: tamanho,
            color: Colors.amber,
          ),
        const SizedBox(width: 6),
        Text(nota.toStringAsFixed(1), style: const TextStyle(fontSize: 13)),
      ],
    );
  }
}
