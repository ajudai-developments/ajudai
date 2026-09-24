import 'package:flutter/material.dart';
import 'package:shared/shared.dart';

import '../../core/errors/erro_mapper.dart';
import '../../core/routes/app_routes.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/error_banner.dart';
import '../../core/widgets/rating_display.dart';
import '../../core/widgets/user_avatar.dart';
import '../../core/ws/ws_message_stream.dart';
import '../conversas/conversas_repository.dart';
import '../usuario/usuario_repository.dart';
import 'widgets/comentarios_list.dart';
import 'widgets/selos_list.dart';

/// Perfil público de um usuário — visualização somente leitura.
///
/// Esta tela recebe `usuarioId` via argumento da rota e busca o perfil
/// público diretamente no backend.
class PerfilPublicoScreen extends StatefulWidget {
  const PerfilPublicoScreen({super.key});

  @override
  State<PerfilPublicoScreen> createState() => _PerfilPublicoScreenState();
}

class _PerfilPublicoScreenState extends State<PerfilPublicoScreen> {
  final _usuarioRepository = UsuarioRepository();
  final _conversasRepository = ConversasRepository();

  late String _usuarioId;
  bool _argumentosCarregados = false;

  bool _carregando = true;
  String? _erro;
  ObterPerfilPublicoResponseDto? _dados;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_argumentosCarregados) return;
    _argumentosCarregados = true;

    _usuarioId = ModalRoute.of(context)!.settings.arguments as String;
    _carregar();
  }

  Future<void> _carregar() async {
    setState(() {
      _carregando = true;
      _erro = null;
    });

    try {
      final dados = await _usuarioRepository.obterPerfilPublico(
        usuarioId: _usuarioId,
      );
      setState(() => _dados = dados);
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

  Future<void> _conversar() async {
    final usuario = _dados?.usuario;
    if (usuario == null) return;

    try {
      final conversaId = await _conversasRepository.criarConversa(usuario.id);
      final conversas = await _conversasRepository.listarConversas();
      final conversa = conversas.firstWhere(
        (item) => item.conversaId == conversaId,
      );
      if (!mounted) return;
      await Navigator.of(
        context,
      ).pushNamed(AppRoutes.conversa, arguments: conversa);
    } on WsErroException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            ErroMapper.paraMensagem(e.codigo, mensagemServidor: e.mensagem),
          ),
        ),
      );
    } on WsTimeoutException {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Não foi possível iniciar a conversa.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final dados = _dados;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: Text(dados?.usuario.nome ?? 'Perfil')),
      body: RefreshIndicator(
        onRefresh: _carregar,
        child: _carregando
            ? const Center(child: CircularProgressIndicator())
            : ListView(
                padding: const EdgeInsets.all(24),
                children: [
                  ErrorBanner(mensagem: _erro),
                  if (dados != null) ..._buildConteudo(dados),
                ],
              ),
      ),
    );
  }

  List<Widget> _buildConteudo(ObterPerfilPublicoResponseDto dados) {
    return [
      Center(child: UserAvatar(avatarUrl: dados.usuario.avatarUrl, radius: 40)),
      const SizedBox(height: 12),
      Text(
        dados.usuario.nome,
        style: AppTextStyles.titulo,
        textAlign: TextAlign.center,
      ),
      if (dados.usuario.verificado) ...[
        const SizedBox(height: 4),
        const Center(
          child: Chip(
            avatar: Icon(Icons.verified, size: 16, color: Colors.white),
            label: Text('Verificado', style: TextStyle(color: Colors.white)),
            backgroundColor: AppColors.success,
          ),
        ),
      ],
      const SizedBox(height: 8),
      if (dados.ehPrestador) ...[
        Center(
          child: RatingDisplay(
            media: dados.mediaAvaliacao,
            quantidadeAvaliacoes: dados.quantidadeAvaliacoes,
          ),
        ),
        const SizedBox(height: 24),
        if (dados.selos.isNotEmpty) ...[
          Text('Selos', style: AppTextStyles.titulo),
          const SizedBox(height: 8),
          SelosList(selos: dados.selos),
          const SizedBox(height: 24),
        ],
        Text('Serviços oferecidos', style: AppTextStyles.titulo),
        const SizedBox(height: 8),
        ..._buildServicos(dados),
        const SizedBox(height: 12),
        OutlinedButton.icon(
          onPressed: _conversar,
          icon: const Icon(Icons.chat_bubble_outline),
          label: const Text('Conversar'),
        ),
        const SizedBox(height: 24),
        Text('Comentários', style: AppTextStyles.titulo),
        const SizedBox(height: 8),
        ComentariosList(comentarios: dados.comentarios),
      ] else ...[
        const SizedBox(height: 12),
        const Text('Usuário não é prestador.'),
      ],
    ];
  }

  List<Widget> _buildServicos(ObterPerfilPublicoResponseDto dados) {
    if (dados.servicosOferecidos.isEmpty) {
      return const [Text('Nenhum serviço oferecido cadastrado.')];
    }

    return [
      for (final servico in dados.servicosOferecidos) ...[
        Card(
          child: ListTile(
            onTap: () => Navigator.of(
              context,
            ).pushNamed(AppRoutes.servicoDetalhe, arguments: servico),
            title: Text(servico.servicoNome),
            subtitle: Text(
              '${servico.categoriaNome} • R\$ ${servico.valor.toStringAsFixed(2)}',
            ),
            trailing: const Icon(Icons.chevron_right),
          ),
        ),
        const SizedBox(height: 8),
      ],
    ];
  }
}
