import 'package:flutter/material.dart';
import 'package:shared/shared.dart';

import '../../core/errors/erro_mapper.dart';
import '../../core/routes/app_routes.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/error_banner.dart';
import '../../core/ws/ws_message_stream.dart';
import 'agendamento_com_detalhes.dart';
import 'agendamento_repository.dart';
import 'widgets/status_badge.dart';

/// Detalhe de um agendamento — mostra dados e as ações disponíveis,
/// que dependem do `status` atual E de quem está olhando.
///
/// Recebe um `AgendamentoComDetalhes` via argumento da rota. O item já
/// traz o papel (cliente/prestador), o nome da contraparte e o nome do
/// serviço, então a tela NÃO busca nada ao abrir. Só vai ao servidor
/// quando o usuário executa uma ação ou faz pull-to-refresh.
///
/// Ao sair, devolve o item atualizado via `Navigator.pop(item)`, pra a
/// tela de listagem poder reagir se quiser.
class AgendamentoDetalheScreen extends StatefulWidget {
  const AgendamentoDetalheScreen({super.key});

  @override
  State<AgendamentoDetalheScreen> createState() =>
      _AgendamentoDetalheScreenState();
}

class _AgendamentoDetalheScreenState extends State<AgendamentoDetalheScreen> {
  final _agendamentoRepository = AgendamentoRepository();

  late AgendamentoComDetalhes _item;
  bool _inicializado = false;

  String? _erro;
  bool _executandoAcao = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_inicializado) return;
    _inicializado = true;
    _item =
        ModalRoute.of(context)!.settings.arguments as AgendamentoComDetalhes;
  }

  bool get _souCliente => _item.comoCliente;
  bool get _souPrestador => _item.comoPrestador;
  String get _agendamentoId => _item.agendamento.id;

  /// Executa uma ação que devolve o `Agendamento` atualizado e troca só
  /// essa parte do item (papel, nomes e serviço continuam os mesmos).
  Future<void> _executar(Future<Agendamento> Function() acao) async {
    setState(() {
      _executandoAcao = true;
      _erro = null;
    });
    try {
      final atualizado = await acao();
      if (!mounted) return;
      setState(() => _item = _item.copyWith(agendamento: atualizado));
    } on WsErroException catch (e) {
      if (!mounted) return;
      setState(
        () => _erro = ErroMapper.paraMensagem(
          e.codigo,
          mensagemServidor: e.mensagem,
        ),
      );
    } on WsTimeoutException {
      if (!mounted) return;
      setState(
        () => _erro = 'Não foi possível conectar ao servidor. Tente novamente.',
      );
    } finally {
      if (mounted) setState(() => _executandoAcao = false);
    }
  }

  /// Não existe "obter um agendamento" no repositório, então o refresh
  /// busca a lista do papel atual e procura o agendamento pelo id. Se
  /// não achar, mantém o que já está na tela.
  Future<Agendamento> _buscarAtualizado() async {
    final atual = _item.agendamento;

    if (_item.comoCliente) {
      final lista = await _agendamentoRepository.listarAgendamentosCliente();
      return lista
          .map((d) => d.agendamento)
          .firstWhere((a) => a.id == _agendamentoId, orElse: () => atual);
    }

    final lista = await _agendamentoRepository.listarAgendamentosPrestador();
    return lista
        .map((d) => d.agendamento)
        .firstWhere((a) => a.id == _agendamentoId, orElse: () => atual);
  }

  Future<void> _recarregar() => _executar(_buscarAtualizado);

  Future<void> _cancelar() async {
    final motivo = await _pedirMotivo();
    if (motivo == null || motivo.trim().isEmpty) return;

    await _executar(
      () => _agendamentoRepository.cancelarAgendamento(
        agendamentoId: _agendamentoId,
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
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) Navigator.of(context).pop(_item);
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(title: const Text('Agendamento')),
        body: RefreshIndicator(
          onRefresh: _recarregar,
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(24),
            children: [
              ErrorBanner(mensagem: _erro),
              ..._buildConteudo(_item),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _buildConteudo(AgendamentoComDetalhes item) {
    final agendamento = item.agendamento;

    return [
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(child: Text(item.nomeServico, style: AppTextStyles.titulo)),
          StatusBadge(status: agendamento.status),
        ],
      ),
      const SizedBox(height: 4),
      Text('com ${item.nomeContraparte}', style: AppTextStyles.corpo),
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
              agendamentoId: _agendamentoId,
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
                    agendamentoId: _agendamentoId,
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
            () => _agendamentoRepository.iniciarAgendamento(_agendamentoId),
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
            () => _agendamentoRepository.concluirAgendamento(_agendamentoId),
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
              _agendamentoId,
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
          onPressed: () => Navigator.of(
            context,
          ).pushNamed(AppRoutes.avaliarAgendamento, arguments: _agendamentoId),
        ),
      );
    }

    return botoes;
  }
}
