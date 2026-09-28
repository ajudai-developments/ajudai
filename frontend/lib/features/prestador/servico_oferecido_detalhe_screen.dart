import 'package:ajudai/core/layout/responsivo.dart';
import 'package:ajudai/core/widgets/tela_adaptativa.dart';
import 'package:flutter/material.dart';
import 'package:shared/shared.dart';

import '../../core/errors/erro_mapper.dart';
import '../../core/routes/app_routes.dart';
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
/// Recebe o `servicoOferecidoId` (String) via argumento da rota — mesmo
/// padrão de ServicoDetalheScreen (a versão "pra contratar").
///
/// Layout: no mobile é uma coluna única; na web (tela larga) fica em duas
/// colunas — estatísticas + edição à esquerda, comentários à direita.
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
  /// nesta tela — devolvido no pop pra listagem saber que precisa
  /// recarregar.
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
    final web = context.usaLayoutWeb;

    // Qualquer forma de voltar (botão do AppBar, botão da topbar na web,
    // gesto/botão do sistema) cai aqui e devolve se algo mudou.
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) Navigator.of(context).pop(_algoMudou);
      },
      child: TelaAdaptativa(
        titulo: dados?.servicoNome ?? 'Serviço',
        rotaAtual: AppRoutes.meusServicosOferecidos,
        child: _carregando
            ? const Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              )
            : ConteudoCentralizado(
                larguraMax: 1100,
                child: RefreshIndicator(
                  color: AppColors.primary,
                  onRefresh: _carregar,
                  child: ListView(
                    padding: web
                        ? const EdgeInsets.fromLTRB(32, 24, 32, 40)
                        : const EdgeInsets.fromLTRB(20, 16, 20, 40),
                    children: [
                      ErrorBanner(mensagem: _erroCarregamento ?? _erroAcao),
                      if (dados != null) ..._conteudo(dados, web: web),
                    ],
                  ),
                ),
              ),
      ),
    );
  }

  List<Widget> _conteudo(
    ServicoOferecidoDetalhePrestador dados, {
    required bool web,
  }) {
    final cabecalho = Row(
      children: [
        Expanded(
          child: Text(dados.categoriaNome, style: AppTextStyles.legenda),
        ),
        _ChipStatus(ativo: dados.ativo),
      ],
    );

    final estatisticas = _blocoEstatisticas(dados);
    final edicao = _blocoEdicao(dados);
    final comentarios = _blocoComentarios(dados);

    if (!web) {
      return [
        cabecalho,
        const SizedBox(height: 16),
        estatisticas,
        const SizedBox(height: 28),
        edicao,
        const SizedBox(height: 28),
        comentarios,
      ];
    }

    return [
      cabecalho,
      const SizedBox(height: 16),
      Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [estatisticas, const SizedBox(height: 28), edicao],
            ),
          ),
          const SizedBox(width: 32),
          Expanded(flex: 2, child: comentarios),
        ],
      ),
    ];
  }

  Widget _blocoEstatisticas(ServicoOferecidoDetalhePrestador dados) {
    final est = dados.estatisticas;
    final cancelados = est.agendamentosCancelados;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
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
        if (cancelados > 0) ...[
          const SizedBox(height: 8),
          Text(
            '$cancelados agendamento${cancelados == 1 ? '' : 's'} '
            'cancelado${cancelados == 1 ? '' : 's'} '
            'ou recusado${cancelados == 1 ? '' : 's'}',
            style: AppTextStyles.legenda,
          ),
        ],
      ],
    );
  }

  Widget _blocoEdicao(ServicoOferecidoDetalhePrestador dados) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
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
              foregroundColor: dados.ativo
                  ? AppColors.error
                  : AppColors.success,
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
      ],
    );
  }

  Widget _blocoComentarios(ServicoOferecidoDetalhePrestador dados) {
    final qtd = dados.estatisticas.quantidadeAvaliacoes;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          qtd > 0 ? 'Comentários ($qtd)' : 'Comentários',
          style: AppTextStyles.titulo,
        ),
        const SizedBox(height: 8),
        ComentariosServicoList(comentarios: dados.comentarios),
      ],
    );
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
