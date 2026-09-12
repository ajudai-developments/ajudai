import 'package:flutter/material.dart';
import 'package:shared/shared.dart';

import '../../core/errors/erro_mapper.dart';
import '../../core/session/sessao.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/app_text_field.dart';
import '../../core/widgets/error_banner.dart';
import '../../core/ws/ws_message_stream.dart';
import 'usuario_repository.dart';

/// Edição do perfil do próprio usuário: nome e telefone.
///
/// CPF não é editável aqui — não existe campo pra isso em
/// AtualizarPerfilRequestDto (faz sentido, CPF não deveria mudar depois
/// de verificado). E-mail também não, já que nem aparece em `Usuario`
/// (fica só na auth do Supabase).
class EditarPerfilScreen extends StatefulWidget {
  const EditarPerfilScreen({super.key});

  @override
  State<EditarPerfilScreen> createState() => _EditarPerfilScreenState();
}

class _EditarPerfilScreenState extends State<EditarPerfilScreen> {
  final _usuarioRepository = UsuarioRepository();

  late final TextEditingController _nomeController;
  late final TextEditingController _telefoneController;

  bool _salvando = false;
  String? _erroGeral;
  String? _erroTelefone;

  @override
  void initState() {
    super.initState();
    final usuario = Sessao.instance.usuario;
    _nomeController = TextEditingController(text: usuario?.nome ?? '');
    _telefoneController = TextEditingController(text: usuario?.telefone ?? '');
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _telefoneController.dispose();
    super.dispose();
  }

  Future<void> _salvar() async {
    final nome = _nomeController.text.trim();
    final telefone = _telefoneController.text.trim();

    setState(() => _erroTelefone = null);

    if (telefone.isNotEmpty && !TelefoneValidator.isValido(telefone)) {
      setState(() => _erroTelefone = 'Telefone inválido.');
      return;
    }

    setState(() {
      _salvando = true;
      _erroGeral = null;
    });

    try {
      await _usuarioRepository.atualizarPerfil(
        nome: nome.isEmpty ? null : nome,
        telefone: telefone.isEmpty ? null : telefone,
      );

      if (!mounted) return;
      Navigator.of(context).pop();
    } on WsErroException catch (e) {
      setState(() {
        _erroGeral = ErroMapper.paraMensagem(e.codigo, mensagemServidor: e.mensagem);
      });
    } on WsTimeoutException {
      setState(() {
        _erroGeral = 'Não foi possível conectar ao servidor. Tente novamente.';
      });
    } finally {
      if (mounted) setState(() => _salvando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Editar perfil')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ErrorBanner(mensagem: _erroGeral),
              AppTextField(label: 'Nome', controller: _nomeController),
              const SizedBox(height: 16),
              AppTextField(
                label: 'Telefone',
                controller: _telefoneController,
                keyboardType: TextInputType.phone,
                erro: _erroTelefone,
              ),
              const SizedBox(height: 8),
              Text(
                'CPF e e-mail não podem ser alterados.',
                style: AppTextStyles.legenda,
              ),
              const SizedBox(height: 24),
              AppButton(label: 'Salvar', loading: _salvando, onPressed: _salvar),
            ],
          ),
        ),
      ),
    );
  }
}