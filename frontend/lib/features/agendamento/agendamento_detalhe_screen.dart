import 'package:flutter/material.dart';
import 'package:shared/shared.dart';

import '../../core/errors/erro_mapper.dart';
import '../../core/routes/app_routes.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/error_banner.dart';
import '../../core/ws/ws_message_stream.dart';
import '../servico/servico_repository.dart';
import 'agendamento_detalhe_args.dart';
import 'agendamento_repository.dart';
import 'widgets/status_badge.dart';

/// Detalhe de um agendamento — mostra dados e as ações disponíveis,
/// que dependem do `status` atual E de quem está olhando.
///
/// Recebe um `AgendamentoDetalheArgs` (agendamentoId + comoCliente) via
/// argumento da rota — o papel vem de fora (de qual tela de listagem a
/// pessoa veio), não é mais descoberto comparando ids depois de buscar,
/// porque agora existem dois endpoints diferentes
/// (`obterAgendamentoCliente`/`Prestador`) e é preciso saber qual
/// chamar ANTES de ter os dados.
class AgendamentoDetalheScreen extends StatefulWidget {
  const AgendamentoDetalheScreen({super.key});

  @override
  State<AgendamentoDetalheScreen> createState() =>
      _AgendamentoDetalheScreenState();
}

class _AgendamentoDetalheScreenState extends State<AgendamentoDetalheScreen> {
  final _agendamentoRepository = AgendamentoRepository();
  final _servicoRepository = ServicoRepository();

  late AgendamentoDetalheArgs _args;
  bool _argumentosCarregados = false;

  bool _carregando = true;
  String? _erro;
  Agendamento? _agendamento;
  String? _nomeContraparte;
  String? _nomeServico;

  bool _executandoAcao = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_argumentosCarregados) return;
    _argumentosCarregados = true;

    _args =
        ModalRoute.of(context)!.settings.arguments as AgendamentoDetalheArgs;
    _carregar();
  }

  bool get _souCliente => _args.comoCliente;
  bool get _souPrestador => !_args.comoCliente;

  Future<void> _carregar() async {
    setState(() {
      _carregando = true;
      _erro = null;
    });

    try {
      final Agendamento agendamento;
      final String nomeContraparte;

      if (_args.comoCliente) {
        final detalhado = await _agendamentoRepository.obterAgendamentoCliente(
          _args.agendamentoId,
        );
        agendamento = detalhado.agendamento;
        nomeContraparte = detalhado.prestadorNome;
      } else {
        final detalhado = await _agendamentoRepository
            .obterAgendamentoPrestador(_args.agendamentoId);
        agendamento = detalhado.agendamento;
        nomeContraparte = detalhado.clienteNome;
      }

      String nomeServico;
      try {
        final servico = await _servicoRepository.obterServicoOferecido(
          servicoOferecidoId: agendamento.servicoOferecidoId,
        );
        nomeServico = servico.servico.nome;
      } catch (_) {
        nomeServico = 'Serviço indisponível';
      }

      setState(() {
        _agendamento = agendamento;
        _nomeContraparte = nomeContraparte;
        _nomeServico = nomeServico;
      });
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

  Future<void> _executar(Future<Agendamento> Function() acao) async {
    setState(() {
      _executandoAcao = true;
      _erro = null;
    });

    try {
      final atualizado = await acao();
      setState(() => _agendamento = atualizado);
    } on WsErroException catch (e) {
      setState(() {
        _erro = ErroMapper.paraMensagem(e.codigo, mensagemServidor: e.mensagem);
      });
    } on WsTimeoutException {
      setState(() {
        _erro = 'Não foi possível conectar ao servidor. Tente novamente.';
      });
    } finally {
      if (mounted) setState(() => _executandoAcao = false);
    }
  }

  Future<void> _cancelar() async {
    final motivo = await _pedirMotivo();
    if (motivo == null || motivo.trim().isEmpty) return;

    await _executar(
      () => _agendamentoRepository.cancelarAgendamento(
        agendamentoId: _args.agendamentoId,
        motivo: motivo.trim(),
      ),
    );
  }

  Future<String?> _pedirMotivo() {
    final controller = TextEditingController();
    return showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancelar agendamento'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(
            labelText: 'Motivo do cancelamento',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Voltar'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(controller.text),
            child: const Text('Confirmar'),
          ),
        ],
      ),
    );
  }

  String _formatarData(DateTime utc) {
    final local = utc.toLocal();
    final dia = local.day.toString().padLeft(2, '0');
    final mes = local.month.toString().padLeft(2, '0');
    final hora = local.hour.toString().padLeft(2, '0');
    final minuto = local.minute.toString().padLeft(2, '0');
    return '$dia/$mes às $hora:$minuto';
  }

  @override
  Widget build(BuildContext context) {
    final agendamento = _agendamento;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Agendamento')),
      body: RefreshIndicator(
        onRefresh: _carregar,
        child: _carregando
            ? const Center(child: CircularProgressIndicator())
            : ListView(
                padding: const EdgeInsets.all(24),
                children: [
                  ErrorBanner(mensagem: _erro),
                  if (agendamento != null) ..._buildConteudo(agendamento),
                ],
              ),
      ),
    );
  }

  List<Widget> _buildConteudo(Agendamento agendamento) {
    return [
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(_nomeServico ?? 'Serviço', style: AppTextStyles.titulo),
          ),
          StatusBadge(status: agendamento.status),
        ],
      ),
      const SizedBox(height: 4),
      Text('com $_nomeContraparte', style: AppTextStyles.corpo),
      const SizedBox(height: 16),
      _linha('Data e horário', _formatarData(agendamento.horaInicio)),
      _linha(
        'Endereço',
        '${agendamento.enderecoLogradouro}, ${agendamento.enderecoNumero} - '
            '${agendamento.enderecoBairro}, ${agendamento.enderecoCidade}/'
            '${agendamento.enderecoEstado}',
      ),
      _linha('Valor', 'R\$ ${agendamento.valor.toStringAsFixed(2)}'),
      const SizedBox(height: 24),
      ..._buildAcoes(agendamento),
    ];
  }

  Widget _linha(String label, String valor) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(label, style: AppTextStyles.legenda),
          ),
          Expanded(child: Text(valor, style: AppTextStyles.corpo)),
        ],
      ),
    );
  }

  /// Ações visíveis dependendo do status atual e de quem está olhando.
  /// Nenhuma checagem aqui é "a fonte da verdade" — o backend valida de
  /// novo antes de aplicar qualquer transição; isso só evita mostrar
  /// botões que dariam erro na certa.
  List<Widget> _buildAcoes(Agendamento agendamento) {
    final botoes = <Widget>[];

    if (_souPrestador && agendamento.status == StatusAgendamento.pendente) {
      botoes.addAll([
        AppButton(
          label: 'Aceitar',
          loading: _executandoAcao,
          onPressed: () => _executar(
            () => _agendamentoRepository.responderAgendamento(
              agendamentoId: _args.agendamentoId,
              aceitar: true,
            ),
          ),
        ),
        const SizedBox(height: 8),
        OutlinedButton(
          onPressed: _executandoAcao
              ? null
              : () => _executar(
                  () => _agendamentoRepository.responderAgendamento(
                    agendamentoId: _args.agendamentoId,
                    aceitar: false,
                  ),
                ),
          child: const Text('Recusar'),
        ),
      ]);
    }

    if (_souPrestador && agendamento.status == StatusAgendamento.aceito) {
      botoes.add(
        AppButton(
          label: 'Iniciar atendimento',
          loading: _executandoAcao,
          onPressed: () => _executar(
            () =>
                _agendamentoRepository.iniciarAgendamento(_args.agendamentoId),
          ),
        ),
      );
    }

    if (_souPrestador && agendamento.status == StatusAgendamento.emAndamento) {
      botoes.add(
        AppButton(
          label: 'Concluir atendimento',
          loading: _executandoAcao,
          onPressed: () => _executar(
            () =>
                _agendamentoRepository.concluirAgendamento(_args.agendamentoId),
          ),
        ),
      );
    }

    if (_souCliente &&
        agendamento.status == StatusAgendamento.aguardandoConfirmacao) {
      botoes.add(
        AppButton(
          label: 'Confirmar conclusão',
          loading: _executandoAcao,
          onPressed: () => _executar(
            () => _agendamentoRepository.confirmarConclusaoAgendamento(
              _args.agendamentoId,
            ),
          ),
        ),
      );
    }

    // Cancelar: cliente pode cancelar em pendente ou aceito. Prestador só
    // a partir de aceito — em pendente ele já tem "Recusar" (uma linha
    // acima), que cobre o mesmo caso de "declinar o pedido"; oferecer os
    // dois botões ali seria redundante.
    final podeCancelar =
        (_souCliente &&
            (agendamento.status == StatusAgendamento.pendente ||
                agendamento.status == StatusAgendamento.aceito)) ||
        (_souPrestador && agendamento.status == StatusAgendamento.aceito);

    if (podeCancelar) {
      if (botoes.isNotEmpty) botoes.add(const SizedBox(height: 8));
      botoes.add(
        TextButton(
          onPressed: _executandoAcao ? null : _cancelar,
          child: const Text('Cancelar agendamento'),
        ),
      );
    }

    if (_souCliente && agendamento.status == StatusAgendamento.concluido) {
      botoes.add(
        AppButton(
          label: 'Avaliar',
          onPressed: () => Navigator.of(context).pushNamed(
            AppRoutes.avaliarAgendamento,
            arguments: _args.agendamentoId,
          ),
        ),
      );
    }

    return botoes;
  }
}
