import 'package:ajudai/features/perfil/widgets/modal_detalhe_servico.dart';
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
import 'widgets/cartao_servico_oferecido.dart';
import 'widgets/comentarios_list.dart';
import 'widgets/selos_destaque.dart';

/// Perfil público de um usuário — visualização somente leitura.
///
/// Recebe `usuarioId` via argumento da rota e busca o perfil público
/// direto do backend. Os comentários exibidos aqui são sobre o usuário
/// em si (`AvaliacaoUsuario`), não sobre serviços específicos — o
/// backend deixou de expor avaliações de serviço separadas no perfil.
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
      appBar: AppBar(
        title: Text(dados?.usuario.nome ?? 'Perfil'),
        backgroundColor: AppColors.background,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
      ),
      body: RefreshIndicator(
        onRefresh: _carregar,
        child: _carregando
            ? const Center(child: CircularProgressIndicator())
            : ListView(
                padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
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
      _Cabecalho(dados: dados),
      const SizedBox(height: 28),
      if (dados.ehPrestador) ...[
        _SecaoTitulo('Serviços oferecidos'),
        const SizedBox(height: 10),
        if (dados.servicosOferecidos.isEmpty)
          _mensagemVazia('Nenhum serviço oferecido cadastrado.')
        else
          Column(
            children: [
              for (final servico in dados.servicosOferecidos)
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: CartaoServicoOferecido(
                    servico: servico,
                    onTap: () => abrirModalDetalheServico(
                      context: context,
                      servicoOferecidoId: servico.servicoOferecidoId,
                      prestadorId: dados.usuario.id,
                    ),
                  ),
                ),
            ],
          ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 13),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              side: const BorderSide(color: AppColors.primary),
            ),
            onPressed: _conversar,
            icon: const Icon(Icons.chat_bubble_outline, size: 18),
            label: const Text('Conversar'),
          ),
        ),
        const SizedBox(height: 28),
        _SecaoTitulo('Comentários'),
        const SizedBox(height: 10),
        ComentariosList(comentarios: dados.comentarios),
      ] else
        _mensagemVazia('Este usuário não é prestador de serviços.'),
    ];
  }

  Widget _mensagemVazia(String texto) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFEDEDED)),
      ),
      child: Text(
        texto,
        style: const TextStyle(color: Colors.black45),
        textAlign: TextAlign.center,
      ),
    );
  }
}

class _SecaoTitulo extends StatelessWidget {
  final String texto;

  const _SecaoTitulo(this.texto);

  @override
  Widget build(BuildContext context) {
    return Text(texto, style: AppTextStyles.titulo);
  }
}

/// Cabeçalho do perfil: avatar, nome, selo de verificado, nota média
/// e selos/conquistas em destaque — tudo centralizado num único cartão.
class _Cabecalho extends StatelessWidget {
  final ObterPerfilPublicoResponseDto dados;

  const _Cabecalho({required this.dados});

  @override
  Widget build(BuildContext context) {
    final usuario = dados.usuario;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColors.primary.withValues(alpha: 0.25),
                width: 2,
              ),
            ),
            child: UserAvatar(avatarUrl: usuario.avatarUrl, radius: 42),
          ),
          const SizedBox(height: 14),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Flexible(
                child: Text(
                  usuario.nome,
                  style: AppTextStyles.titulo,
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (usuario.verificado) ...[
                const SizedBox(width: 6),
                const Icon(Icons.verified, size: 18, color: AppColors.primary),
              ],
            ],
          ),
          if (dados.ehPrestador) ...[
            const SizedBox(height: 8),
            RatingDisplay(
              media: dados.mediaAvaliacao,
              quantidadeAvaliacoes: dados.quantidadeAvaliacoes,
            ),
            const SizedBox(height: 4),
            Text(
              '${dados.quantidadeServicosConcluidos} serviços concluídos',
              style: const TextStyle(fontSize: 12.5, color: Colors.black45),
            ),
          ],
          if (dados.selos.isNotEmpty) ...[
            const SizedBox(height: 18),
            const Divider(height: 1),
            const SizedBox(height: 16),
            SelosDestaque(selos: dados.selos),
          ],
        ],
      ),
    );
  }
}
