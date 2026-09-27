import 'package:flutter/material.dart';
import 'package:shared/shared.dart';

import '../../core/errors/erro_mapper.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/app_text_field.dart';
import '../../core/widgets/error_banner.dart';
import '../../core/ws/ws_message_stream.dart';
import '../servico/widgets/comentarios_servico_list.dart';
import 'prestador_repository.dart';

/// Tela de detalhe + gerenciamento de UM serviço oferecido, do ponto de
/// vista do prestador: quantos pedidos ele já gerou, quanto faturou e
/// como está sendo avaliado — além de editar descrição/valor e
/// ativar/desativar a oferta.
///
/// Substitui a antiga EditarServicoScreen. Recebe o
/// `servicoOferecidoId` (String) via argumento da rota — mesmo padrão
/// de ServicoDetalheScreen (a versão "pra contratar").
class ServicoOferecidoDetalheScreen extends StatefulWidget {
  const ServicoOferecidoDetalheScreen({super.key});

  @override
  State<ServicoOferecidoDetalheScreen> createState() =>
      _ServicoOferecidoDetalheScreenState();
}

class _ServicoOferecidoDetalheScreenState
    extends State<ServicoOferecidoDetalheScreen> {
  final _prestadorRepository = PrestadorRepository();

  late String _servicoOferecidoId;
  bool _argumentosCarregados = false;

  bool _carregando = true;
  String? _erroCarregamento;
  ServicoOferecidoDetalhePrestador? _dados;

  TextEditingController? _descricaoController;
  TextEditingController? _valorController;

  bool _salvando = false;
  bool _alterandoStatus = false;
  String? _erroAcao;

  /// `true` se alguma alteração foi salva enquanto o usuário estava
  /// nesta tela — usado pra avisar a tela anterior (a listagem) que ela
  /// precisa recarregar ao voltar, mesmo padrão do FAB de
  /// MeusServicosOferecidosScreen.
  bool _algoMudou = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_argumentosCarregados) return;
    _argumentosCarregados = true;

    _servicoOferecidoId = ModalRoute.of(context)!.settings.arguments as String;
    _carregar();
  }

  @override
  void dispose() {
    _descricaoController?.dispose();
    _valorController?.dispose();
    super.dispose();
  }

  Future<void> _carregar() async {
    setState(() {
      _carregando = true;
      _erroCarregamento = null;
    });

    try {
      final dados = await _prestadorRepository.obterDetalheServicoOferecido(
        servicoOferecidoId: _servicoOferecidoId,
      );

      _descricaoController?.dispose();
      _valorController?.dispose();
      _descricaoController = TextEditingController(text: dados.descricao);
      _valorController = TextEditingController(
        text: dados.valor.toStringAsFixed(2).replaceAll('.', ','),
      );

      setState(() => _dados = dados);
    } on WsErroException catch (e) {
      setState(() {
        _erroCarregamento = ErroMapper.paraMensagem(
          e.codigo,
          mensagemServidor: e.mensagem,
        );
      });
    } on WsTimeoutException {
      setState(() {
        _erroCarregamento = 'Não foi possível conectar ao servidor.';
      });
    } finally {
      if (mounted) setState(() => _carregando = false);
    }
  }

  Future<void> _salvarEdicao() async {
    final descricao = _descricaoController!.text.trim();
    final valor = double.tryParse(
      _valorController!.text.trim().replaceAll(',', '.'),
    );

    if (descricao.isEmpty) {
      setState(() => _erroAcao = 'Informe uma descrição para o serviço.');
      return;
    }
    if (valor == null || valor < 0) {
      setState(() => _erroAcao = 'Informe um preço válido.');
      return;
    }

    setState(() {
      _salvando = true;
      _erroAcao = null;
    });

    try {
      await _prestadorRepository.editarServicoOferecido(
        servicoOferecidoId: _servicoOferecidoId,
        descricao: descricao,
        valor: valor,
      );
      _algoMudou = true;

      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Alterações salvas.')));
      }
      await _carregar();
    } on WsErroException catch (e) {
      setState(() {
        _erroAcao = ErroMapper.paraMensagem(
          e.codigo,
          mensagemServidor: e.mensagem,
        );
      });
    } on WsTimeoutException {
      setState(() => _erroAcao = 'Não foi possível conectar ao servidor.');
    } finally {
      if (mounted) setState(() => _salvando = false);
    }
  }

  Future<void> _alternarStatus() async {
    final dados = _dados;
    if (dados == null) return;

    setState(() {
      _alterandoStatus = true;
      _erroAcao = null;
    });

    try {
      if (dados.ativo) {
        await _prestadorRepository.desativarServicoOferecido(
          servicoOferecidoId: _servicoOferecidoId,
        );
      } else {
        await _prestadorRepository.ativarServicoOferecido(
          servicoOferecidoId: _servicoOferecidoId,
        );
      }
      _algoMudou = true;
      await _carregar();
    } on WsErroException catch (e) {
      setState(() {
        _erroAcao = ErroMapper.paraMensagem(
          e.codigo,
          mensagemServidor: e.mensagem,
        );
      });
    } on WsTimeoutException {
      setState(() => _erroAcao = 'Não foi possível conectar ao servidor.');
    } finally {
      if (mounted) setState(() => _alterandoStatus = false);
    }
  }

  String _formatarValor(double valor) =>
      'R\$ ${valor.toStringAsFixed(2).replaceAll('.', ',')}';

  @override
  Widget build(BuildContext context) {
    final dados = _dados;

    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, result) {
        // Se a rota já não trata o pop com um valor próprio, garante que
        // quem chamou (a listagem) saiba se precisa recarregar.
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: Text(dados?.servicoNome ?? 'Serviço'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_rounded),
            onPressed: () => Navigator.of(context).pop(_algoMudou),
          ),
        ),
        body: _carregando
            ? const Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              )
            : RefreshIndicator(
                color: AppColors.primary,
                onRefresh: _carregar,
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 40),
                  children: [
                    ErrorBanner(mensagem: _erroCarregamento ?? _erroAcao),
                    if (dados != null) ..._conteudo(dados),
                  ],
                ),
              ),
      ),
    );
  }

  List<Widget> _conteudo(ServicoOferecidoDetalhePrestador dados) {
    final est = dados.estatisticas;

    return [
      Row(
        children: [
          Expanded(
            child: Text(dados.categoriaNome, style: AppTextStyles.legenda),
          ),
          _ChipStatus(ativo: dados.ativo),
        ],
      ),
      const SizedBox(height: 16),

      // Grade de estatísticas.
      Row(
        children: [
          Expanded(
            child: _CartaoEstatistica(
              label: 'Em andamento',
              valor: '${est.agendamentosEmAndamento}',
              icone: Icons.hourglass_top_rounded,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _CartaoEstatistica(
              label: 'Concluídos',
              valor: '${est.agendamentosConcluidos}',
              icone: Icons.check_circle_outline_rounded,
            ),
          ),
        ],
      ),
      const SizedBox(height: 12),
      Row(
        children: [
          Expanded(
            child: _CartaoEstatistica(
              label: 'Faturamento',
              valor: _formatarValor(est.faturamentoTotal),
              icone: Icons.payments_outlined,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _CartaoEstatistica(
              label: 'Avaliação',
              valor: est.mediaAvaliacao != null
                  ? '${est.mediaAvaliacao!.toStringAsFixed(1)} (${est.quantidadeAvaliacoes})'
                  : 'Sem notas',
              icone: Icons.star_rounded,
              corIcone: AppColors.avaliacao,
            ),
          ),
        ],
      ),
      if (est.agendamentosCancelados > 0) ...[
        const SizedBox(height: 8),
        Text(
          '${est.agendamentosCancelados} agendamento${est.agendamentosCancelados == 1 ? '' : 's'} cancelado${est.agendamentosCancelados == 1 ? '' : 's'} ou recusado${est.agendamentosCancelados == 1 ? '' : 's'}',
          style: AppTextStyles.legenda,
        ),
      ],

      const SizedBox(height: 28),
      Text('Editar oferta', style: AppTextStyles.titulo),
      const SizedBox(height: 12),
      AppTextField(label: 'Descrição', controller: _descricaoController!),
      const SizedBox(height: 12),
      AppTextField(
        label: 'Valor (R\$)',
        controller: _valorController!,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
      ),
      const SizedBox(height: 12),
      AppButton(
        label: 'Salvar alterações',
        loading: _salvando,
        onPressed: _salvarEdicao,
      ),
      const SizedBox(height: 8),
      SizedBox(
        width: double.infinity,
        child: OutlinedButton(
          onPressed: _alterandoStatus ? null : _alternarStatus,
          style: OutlinedButton.styleFrom(
            foregroundColor: dados.ativo ? AppColors.error : AppColors.success,
            side: BorderSide(
              color: dados.ativo ? AppColors.error : AppColors.success,
            ),
          ),
          child: _alterandoStatus
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(dados.ativo ? 'Desativar serviço' : 'Reativar serviço'),
        ),
      ),

      const SizedBox(height: 28),
      Text(
        est.quantidadeAvaliacoes > 0
            ? 'Comentários (${est.quantidadeAvaliacoes})'
            : 'Comentários',
        style: AppTextStyles.titulo,
      ),
      const SizedBox(height: 8),
      ComentariosServicoList(comentarios: dados.comentarios),
    ];
  }
}

class _CartaoEstatistica extends StatelessWidget {
  final String label;
  final String valor;
  final IconData icone;
  final Color? corIcone;

  const _CartaoEstatistica({
    required this.label,
    required this.valor,
    required this.icone,
    this.corIcone,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.outline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icone, size: 20, color: corIcone ?? AppColors.primary),
          const SizedBox(height: 10),
          Text(
            valor,
            style: AppTextStyles.titulo,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          Text(label, style: AppTextStyles.legenda),
        ],
      ),
    );
  }
}

class _ChipStatus extends StatelessWidget {
  final bool ativo;
  const _ChipStatus({required this.ativo});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: ativo ? AppColors.successSoft : AppColors.surfaceAlt,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        ativo ? 'Ativo' : 'Desativado',
        style: AppTextStyles.label.copyWith(
          color: ativo ? AppColors.success : AppColors.textoSecundario,
          fontSize: 11,
        ),
      ),
    );
  }
}
