import 'package:ajudai/core/layout/responsivo.dart';
import 'package:ajudai/core/routes/app_routes.dart';
import 'package:ajudai/core/widgets/tela_adaptativa.dart';
import 'package:flutter/material.dart';
import 'package:shared/shared.dart';

import '../../core/errors/erro_mapper.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/app_text_field.dart';
import '../../core/widgets/error_banner.dart';
import '../../core/ws/ws_message_stream.dart';
import '../prestador/prestador_repository.dart';

class EditarServicoScreen extends StatefulWidget {
  final ServicoOferecidoResumo servico;

  const EditarServicoScreen({required this.servico, super.key});

  @override
  State<EditarServicoScreen> createState() => _EditarServicoScreenState();
}

class _EditarServicoScreenState extends State<EditarServicoScreen> {
  final _prestadorRepository = PrestadorRepository();
  late final TextEditingController _tituloController;
  late final TextEditingController _descricaoController;
  late final TextEditingController _valorController;

  final bool _disponivel = true;
  bool _salvando = false;
  String? _erro;

  @override
  void initState() {
    super.initState();
    _tituloController = TextEditingController(text: widget.servico.servicoNome);
    _descricaoController = TextEditingController(
      text: widget.servico.descricao,
    );
    _valorController = TextEditingController(
      text: widget.servico.valor.toStringAsFixed(2).replaceAll('.', ','),
    );
  }

  @override
  void dispose() {
    _tituloController.dispose();
    _descricaoController.dispose();
    _valorController.dispose();
    super.dispose();
  }

  Future<void> _salvar() async {
    final descricao = _descricaoController.text.trim();
    final valor = double.tryParse(
      _valorController.text.trim().replaceAll(',', '.'),
    );

    if (descricao.isEmpty) {
      setState(() => _erro = 'Informe uma descrição para o serviço.');
      return;
    }
    if (valor == null || valor < 0) {
      setState(() => _erro = 'Informe um preço válido.');
      return;
    }

    setState(() {
      _salvando = true;
      _erro = null;
    });

    try {
      await _prestadorRepository.editarServicoOferecido(
        servicoOferecidoId: widget.servico.servicoOferecidoId,
        descricao: descricao,
        valor: valor,
      );

      if (!_disponivel) {
        await _prestadorRepository.desativarServicoOferecido(
          servicoOferecidoId: widget.servico.servicoOferecidoId,
        );
      }

      if (!mounted) return;
      Navigator.of(context).pop(true);
    } on WsErroException catch (e) {
      setState(() {
        _erro = ErroMapper.paraMensagem(e.codigo, mensagemServidor: e.mensagem);
      });
    } on WsTimeoutException {
      setState(() => _erro = 'Não foi possível conectar ao servidor.');
    } finally {
      if (mounted) setState(() => _salvando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final web = context.usaLayoutWeb;

    final formulario = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ErrorBanner(mensagem: _erro),
        Text('Informações do serviço', style: AppTextStyles.titulo),
        const SizedBox(height: 16),
        AppTextField(
          label: 'Título',
          controller: _tituloController,
          readOnly: true,
        ),
        const SizedBox(height: 8),
        Text(
          'O título é definido pelo tipo de serviço do catálogo.',
          style: AppTextStyles.legenda,
        ),
        const SizedBox(height: 20),
        AppTextField(label: 'Descrição', controller: _descricaoController),
        const SizedBox(height: 16),
        AppTextField(
          label: 'Preço (R\$)',
          controller: _valorController,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
        ),
        const SizedBox(height: 20),
        AppButton(
          label: 'Salvar alterações',
          loading: _salvando,
          onPressed: _salvar,
        ),
      ],
    );

    return TelaAdaptativa(
      titulo: 'Editar serviço',
      rotaAtual: AppRoutes.meusServicosOferecidos,
      child: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(web ? 32 : 24),
          child: ConteudoCentralizado(
            larguraMax: 640,
            child: web
                ? Container(
                    padding: const EdgeInsets.all(28),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: const Color(0xFFEDEDED)),
                    ),
                    child: formulario,
                  )
                : formulario,
          ),
        ),
      ),
    );
  }
}
