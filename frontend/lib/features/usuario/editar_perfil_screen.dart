import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared/shared.dart';

import '../../core/errors/erro_mapper.dart';
import '../../core/session/sessao.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/app_text_field.dart';
import '../../core/widgets/error_banner.dart';
import '../../core/widgets/user_avatar.dart';
import '../../core/ws/ws_message_stream.dart';
import 'usuario_repository.dart';

/// Edição do perfil do próprio usuário: foto, nome e telefone.
///
/// CPF não é editável aqui — não existe campo pra isso em
/// AtualizarPerfilRequestDto (faz sentido, CPF não deveria mudar depois
/// de verificado). E-mail também não, já que nem aparece em `Usuario`
/// (fica só na auth do Supabase).
///
/// Mesmo padrão das telas de endereço: título grande, campos com ícone e
/// botão de salvar fixo no rodapé — habilitado só quando algo mudou.
class EditarPerfilScreen extends StatefulWidget {
  const EditarPerfilScreen({super.key});

  @override
  State<EditarPerfilScreen> createState() => _EditarPerfilScreenState();
}

class _EditarPerfilScreenState extends State<EditarPerfilScreen> {
  final _usuarioRepository = UsuarioRepository();
  final _imagePicker = ImagePicker();

  late final TextEditingController _nomeController;
  late final TextEditingController _telefoneController;

  // Valores de partida, pra saber se o usuário mudou alguma coisa.
  late final String _nomeInicial;
  late final String _telefoneInicial;

  bool _salvando = false;
  bool _salvandoAvatar = false;
  String? _erroGeral;
  String? _erroTelefone;

  bool get _houveMudanca =>
      _nomeController.text.trim() != _nomeInicial ||
      _telefoneController.text.trim() != _telefoneInicial;

  @override
  void initState() {
    super.initState();
    final usuario = Sessao.instance.usuario;
    _nomeInicial = (usuario?.nome ?? '').trim();
    _telefoneInicial = (usuario?.telefone ?? '').trim();

    _nomeController = TextEditingController(text: _nomeInicial);
    _telefoneController = TextEditingController(text: _telefoneInicial);

    _nomeController.addListener(() => setState(() {}));
    _telefoneController.addListener(() {
      setState(() => _erroTelefone = null);
    });
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
        _erroGeral = ErroMapper.paraMensagem(
          e.codigo,
          mensagemServidor: e.mensagem,
        );
      });
    } on WsTimeoutException {
      setState(() {
        _erroGeral = 'Não foi possível conectar ao servidor. Tente novamente.';
      });
    } finally {
      if (mounted) setState(() => _salvando = false);
    }
  }

  Future<void> _atualizarFoto() async {
    setState(() => _erroGeral = null);

    final XFile? arquivo;
    try {
      arquivo = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );
    } catch (_) {
      if (!mounted) return;
      setState(() => _erroGeral = 'Não foi possível abrir a galeria.');
      return;
    }

    if (arquivo == null) return;

    final bytes = await arquivo.readAsBytes();
    if (bytes.isEmpty) {
      if (!mounted) return;
      setState(() {
        _erroGeral = 'Não foi possível ler a imagem selecionada.';
      });
      return;
    }

    final nomeArquivo = arquivo.name;
    final extensao = nomeArquivo.contains('.')
        ? nomeArquivo.split('.').last.toLowerCase()
        : '';
    final extensaoFinal = extensao.isEmpty ? 'jpg' : extensao;

    setState(() => _salvandoAvatar = true);

    try {
      await _usuarioRepository.atualizarAvatar(
        imagemBase64: base64Encode(bytes),
        extensao: extensaoFinal,
      );

      if (!mounted) return;
      setState(() {});
    } on WsErroException catch (e) {
      setState(() {
        _erroGeral = ErroMapper.paraMensagem(
          e.codigo,
          mensagemServidor: e.mensagem,
        );
      });
    } on WsTimeoutException {
      setState(() {
        _erroGeral = 'Não foi possível conectar ao servidor. Tente novamente.';
      });
    } finally {
      if (mounted) setState(() => _salvandoAvatar = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final ocupado = _salvando || _salvandoAvatar;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleSpacing: 0,
        title: const Text('Editar perfil', style: AppTextStyles.titulo),
      ),
      body: SafeArea(
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => FocusScope.of(context).unfocus(),
          child: SingleChildScrollView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ErrorBanner(mensagem: _erroGeral),

                // Foto
                Center(
                  child: _AvatarEditavel(
                    avatarUrl: Sessao.instance.usuario?.avatarUrl,
                    carregando: _salvandoAvatar,
                    onTap: ocupado ? null : _atualizarFoto,
                  ),
                ),
                const SizedBox(height: 8),
                Center(
                  child: TextButton(
                    onPressed: ocupado ? null : _atualizarFoto,
                    child: const Text('Alterar foto'),
                  ),
                ),
                const SizedBox(height: 20),

                // Dados
                const Text('Seus dados', style: AppTextStyles.titulo),
                const SizedBox(height: 12),
                AppTextField(
                  label: 'Nome',
                  icone: Icons.person_outline_rounded,
                  controller: _nomeController,
                  textInputAction: TextInputAction.next,
                  textCapitalization: TextCapitalization.words,
                  autofillHints: const [AutofillHints.name],
                ),
                const SizedBox(height: 16),
                AppTextField(
                  label: 'Telefone',
                  icone: Icons.phone_outlined,
                  controller: _telefoneController,
                  keyboardType: TextInputType.phone,
                  erro: _erroTelefone,
                  autofillHints: const [AutofillHints.telephoneNumber],
                ),
                const SizedBox(height: 24),

                // Aviso
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceAlt,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.lock_outline_rounded,
                        size: 18,
                        color: AppColors.textoSecundario,
                      ),
                      SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'CPF e e-mail não podem ser alterados.',
                          style: AppTextStyles.legenda,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),

      // Botão fixo no rodapé — só habilita quando algo mudou.
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: AppColors.surface,
          border: Border(top: BorderSide(color: AppColors.outline)),
        ),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
            child: AppButton(
              label: 'Salvar alterações',
              loading: _salvando,
              onPressed: (_houveMudanca && !_salvandoAvatar) ? _salvar : null,
            ),
          ),
        ),
      ),
    );
  }
}

/// Avatar grande com um selo de câmera no canto — a foto inteira é tocável.
/// Enquanto o envio está em andamento, mostra um véu com spinner por cima.
class _AvatarEditavel extends StatelessWidget {
  final String? avatarUrl;
  final bool carregando;
  final VoidCallback? onTap;

  const _AvatarEditavel({
    required this.avatarUrl,
    required this.carregando,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    const raio = 52.0;

    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: raio * 2 + 8,
        height: raio * 2 + 8,
        child: Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.center,
          children: [
            UserAvatar(avatarUrl: avatarUrl, radius: raio),
            if (carregando)
              Container(
                width: raio * 2,
                height: raio * 2,
                decoration: const BoxDecoration(
                  color: Colors.black38,
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            Positioned(
              right: 0,
              bottom: 0,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.background, width: 3),
                ),
                child: const Icon(
                  Icons.photo_camera_rounded,
                  size: 16,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
