import 'package:flutter/material.dart';

import '../../core/errors/erro_mapper.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/app_text_field.dart';
import '../../core/widgets/tela_formulario.dart';
import '../../core/ws/ws_message_stream.dart';
import '../denuncia/widgets/seletor_prova.dart';
import 'contestacao_repository.dart';

/// Contestação de um agendamento. Recebe `agendamentoId` (String) via
/// argumento da rota — mesmo padrão de avaliar_agendamento_screen.
class ContestarAgendamentoScreen extends StatefulWidget {
  const ContestarAgendamentoScreen({super.key});

  @override
  State<ContestarAgendamentoScreen> createState() =>
      _ContestarAgendamentoScreenState();
}

class _ContestarAgendamentoScreenState
    extends State<ContestarAgendamentoScreen> {
  final _repository = ContestacaoRepository();
  final _descricaoController = TextEditingController();

  late String _agendamentoId;
  bool _argumentosCarregados = false;

  List<ItemProva> _provas = [];
  bool _enviando = false;
  String? _erro;
  String? _erroDescricao;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_argumentosCarregados) return;
    _argumentosCarregados = true;
    _agendamentoId = ModalRoute.of(context)!.settings.arguments as String;
  }

  @override
  void dispose() {
    _descricaoController.dispose();
    super.dispose();
  }

  Future<void> _enviar() async {
    final descricao = _descricaoController.text.trim();
    if (descricao.isEmpty) {
      setState(() => _erroDescricao = 'Descreva o que aconteceu.');
      return;
    }

    setState(() {
      _enviando = true;
      _erro = null;
      _erroDescricao = null;
    });

    try {
      await _repository.criarContestacao(
        agendamentoId: _agendamentoId,
        descricao: descricao,
        arquivos: _provas.map((p) => p.arquivo).toList(),
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Contestação enviada. Nossa equipe vai analisar.'),
        ),
      );
      Navigator.of(context).pop();
    } on WsErroException catch (e) {
      if (mounted) {
        setState(
          () => _erro = ErroMapper.paraMensagem(
            e.codigo,
            mensagemServidor: e.mensagem,
          ),
        );
      }
    } on WsTimeoutException {
      if (mounted) {
        setState(
          () =>
              _erro = 'Não foi possível conectar ao servidor. Tente novamente.',
        );
      }
    } finally {
      if (mounted) setState(() => _enviando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return TelaFormulario(
      titulo: 'Contestar agendamento',
      subtitulo: 'Conte o que não saiu como combinado',
      rotuloBotao: 'Enviar contestação',
      enviando: _enviando,
      onEnviar: _enviar,
      erro: _erro,
      children: [
        const AvisoInformativo(
          texto:
              'Nossa equipe vai analisar o caso. Você acompanha o andamento '
              'em Perfil > Minhas contestações.',
        ),
        const SizedBox(height: 24),
        Text('O que aconteceu?', style: AppTextStyles.titulo),
        const SizedBox(height: 12),
        AppTextField(
          label: 'Descrição',
          hint: 'Explique com detalhes o que não saiu como combinado',
          controller: _descricaoController,
          erro: _erroDescricao,
          maxLines: 6,
          minLines: 4,
          keyboardType: TextInputType.multiline,
          textCapitalization: TextCapitalization.sentences,
          onChanged: (_) {
            if (_erroDescricao != null) setState(() => _erroDescricao = null);
          },
        ),
        const SizedBox(height: 24),
        SeletorProvas(
          valor: _provas,
          onChanged: (v) => setState(() => _provas = v),
        ),
      ],
    );
  }
}
