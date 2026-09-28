import 'package:flutter/material.dart';
import 'package:shared/shared.dart';

import '../../core/errors/erro_mapper.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/app_text_field.dart';
import '../../core/widgets/tela_formulario.dart';
import '../../core/widgets/tipo_denuncia_label.dart';
import '../../core/ws/ws_message_stream.dart';
import 'denuncia_repository.dart';
import 'denunciar_usuario_args.dart';
import 'widgets/seletor_prova.dart';

/// Denúncia de um usuário. Recebe `DenunciarUsuarioArgs` (usuarioId +
/// nomeUsuario, só pra exibição) via argumento da rota.
class DenunciarUsuarioScreen extends StatefulWidget {
  const DenunciarUsuarioScreen({super.key});

  @override
  State<DenunciarUsuarioScreen> createState() => _DenunciarUsuarioScreenState();
}

class _DenunciarUsuarioScreenState extends State<DenunciarUsuarioScreen> {
  final _repository = DenunciaRepository();
  final _descricaoController = TextEditingController();

  late DenunciarUsuarioArgs _args;
  bool _argumentosCarregados = false;

  TipoDenuncia? _tipo;
  List<ItemProva> _provas = [];
  bool _enviando = false;
  String? _erro;
  String? _erroTipo;
  String? _erroDescricao;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_argumentosCarregados) return;
    _argumentosCarregados = true;
    _args = ModalRoute.of(context)!.settings.arguments as DenunciarUsuarioArgs;
  }

  @override
  void dispose() {
    _descricaoController.dispose();
    super.dispose();
  }

  Future<void> _enviar() async {
    final descricao = _descricaoController.text.trim();

    setState(() {
      _erroTipo = _tipo == null ? 'Selecione o motivo da denúncia.' : null;
      _erroDescricao = descricao.isEmpty ? 'Descreva o que aconteceu.' : null;
    });
    if (_tipo == null || descricao.isEmpty) return;

    setState(() {
      _enviando = true;
      _erro = null;
    });

    try {
      await _repository.criarDenuncia(
        usuarioId: _args.usuarioId,
        tipoDenuncia: _tipo!,
        descricao: descricao,
        arquivos: _provas.map((p) => p.arquivo).toList(),
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Denúncia enviada. Nossa equipe vai analisar.'),
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
      titulo: 'Denunciar usuário',
      subtitulo: _args.nomeUsuario,
      rotuloBotao: 'Enviar denúncia',
      enviando: _enviando,
      onEnviar: _enviar,
      erro: _erro,
      children: [
        const AvisoInformativo(
          icone: Icons.shield_outlined,
          texto:
              'Sua denúncia é analisada pela nossa equipe. Você acompanha o '
              'andamento em Perfil > Minhas denúncias.',
        ),
        const SizedBox(height: 24),
        Text('Qual foi o motivo?', style: AppTextStyles.titulo),
        const SizedBox(height: 12),
        _SeletorMotivo(
          valor: _tipo,
          erro: _erroTipo,
          onChanged: (v) => setState(() {
            _tipo = v;
            _erroTipo = null;
          }),
        ),
        const SizedBox(height: 24),
        Text('O que aconteceu?', style: AppTextStyles.titulo),
        const SizedBox(height: 12),
        AppTextField(
          label: 'Descrição',
          hint: 'Conte com detalhes o que aconteceu com ${_args.nomeUsuario}',
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

/// Motivos da denúncia como chips selecionáveis (uma escolha só) — mais
/// rápido de tocar do que abrir um dropdown, e todas as opções ficam
/// visíveis de uma vez.
class _SeletorMotivo extends StatelessWidget {
  final TipoDenuncia? valor;
  final String? erro;
  final ValueChanged<TipoDenuncia> onChanged;

  const _SeletorMotivo({
    required this.valor,
    required this.erro,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final tipo in TipoDenuncia.values)
              _ChipMotivo(
                rotulo: labelTipoDenuncia(tipo),
                selecionado: tipo == valor,
                onTap: () => onChanged(tipo),
              ),
          ],
        ),
        if (erro != null) ...[
          const SizedBox(height: 8),
          Text(
            erro!,
            style: AppTextStyles.legenda.copyWith(color: AppColors.error),
          ),
        ],
      ],
    );
  }
}

class _ChipMotivo extends StatelessWidget {
  final String rotulo;
  final bool selecionado;
  final VoidCallback onTap;

  const _ChipMotivo({
    required this.rotulo,
    required this.selecionado,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(999),
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
          decoration: BoxDecoration(
            color: selecionado ? AppColors.primarySoft : AppColors.surface,
            borderRadius: BorderRadius.circular(999),
            border: Border.all(
              color: selecionado ? AppColors.primary : AppColors.outline,
              width: selecionado ? 1.5 : 1,
            ),
          ),
          child: Text(
            rotulo,
            style: AppTextStyles.corpo.copyWith(
              fontSize: 13,
              fontWeight: selecionado ? FontWeight.w700 : FontWeight.w500,
              color: selecionado ? AppColors.primary : AppColors.textoNormal,
            ),
          ),
        ),
      ),
    );
  }
}
