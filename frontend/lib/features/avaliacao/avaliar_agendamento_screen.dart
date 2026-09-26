import 'package:flutter/material.dart';

import '../../core/errors/erro_mapper.dart';
import '../../core/routes/app_routes.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/error_banner.dart';
import '../../core/widgets/user_avatar.dart';
import '../../core/ws/ws_message_stream.dart';
import '../denuncia/denunciar_usuario_args.dart';
import 'avaliacao_repository.dart';
import 'avaliar_agendamento_args.dart';
import 'widgets/rating_input.dart';

/// Tela única do fluxo de avaliação. A avaliação é OPCIONAL, então
/// nunca bloqueia: dá pra pular a qualquer momento (botão no app bar
/// ou o próprio botão principal, que vira "Pular avaliação" quando
/// nada foi preenchido), e dá pra enviar só uma das notas — por
/// exemplo, avaliar a pessoa e deixar o serviço em branco — sem exigir
/// as duas.
///
/// Quando [AvaliarAgendamentoArgs.avaliarServico] é true (quem avalia é
/// o CLIENTE), mostra as duas seções — serviço e pessoa — uma embaixo
/// da outra, na mesma tela. Quando é o PRESTADOR, mostra só a seção da
/// pessoa.
class AvaliarAgendamentoScreen extends StatefulWidget {
  const AvaliarAgendamentoScreen({super.key});

  @override
  State<AvaliarAgendamentoScreen> createState() =>
      _AvaliarAgendamentoScreenState();
}

class _AvaliarAgendamentoScreenState extends State<AvaliarAgendamentoScreen> {
  final _avaliacaoRepository = AvaliacaoRepository();
  final _mensagemServicoController = TextEditingController();
  final _mensagemPessoaController = TextEditingController();

  late AvaliarAgendamentoArgs _args;
  bool _argumentosCarregados = false;

  int _notaServico = 0;
  int _notaPessoa = 0;
  bool _enviando = false;
  String? _erro;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_argumentosCarregados) return;
    _argumentosCarregados = true;
    _args =
        ModalRoute.of(context)!.settings.arguments as AvaliarAgendamentoArgs;
  }

  @override
  void dispose() {
    _mensagemServicoController.dispose();
    _mensagemPessoaController.dispose();
    super.dispose();
  }

  bool get _nadaPreenchido => _notaServico == 0 && _notaPessoa == 0;

  Future<void> _enviar() async {
    setState(() {
      _enviando = true;
      _erro = null;
    });

    try {
      if (_args.avaliarServico) {
        final mensagem = _mensagemServicoController.text.trim();
        await _avaliacaoRepository.avaliarAgendamento(
          agendamentoId: _args.agendamentoId,
          avaliadoId: _args.avaliadoId,
          avaliacao: _notaServico > 0 ? _notaServico.toDouble() : null,
          pulado: _notaServico == 0,
          mensagem: mensagem.isEmpty ? null : mensagem,
        );
      }

      final mensagemPessoa = _mensagemPessoaController.text.trim();
      await _avaliacaoRepository.avaliarUsuario(
        agendamentoId: _args.agendamentoId,
        avaliacao: _notaPessoa > 0 ? _notaPessoa.toDouble() : null,
        pulado: _notaPessoa == 0,
        mensagem: mensagemPessoa.isEmpty ? null : mensagemPessoa,
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _nadaPreenchido
                ? 'Avaliação pulada.'
                : 'Avaliação enviada. Obrigado!',
          ),
        ),
      );
      Navigator.of(context).pop();
    } on WsErroException catch (e) {
      setState(() {
        _erro = ErroMapper.paraMensagem(e.codigo, mensagemServidor: e.mensagem);
      });
    } on WsTimeoutException {
      setState(() {
        _erro = 'Não foi possível conectar ao servidor. Tente novamente.';
      });
    } finally {
      if (mounted) setState(() => _enviando = false);
    }
  }

  Future<void> _contestar() async {
    await Navigator.of(
      context,
    ).pushNamed(AppRoutes.contestarAgendamento, arguments: _args.agendamentoId);
  }

  Future<void> _denunciar() async {
    await Navigator.of(context).pushNamed(
      AppRoutes.denunciarUsuario,
      arguments: DenunciarUsuarioArgs(
        usuarioId: _args.avaliadoId,
        nomeUsuario: _args.nomeContraparte,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Avaliar'),
        centerTitle: true,
        elevation: 0,
        actions: [
          TextButton(
            onPressed: _enviando ? null : _enviar,
            child: const Text('Pular'),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ErrorBanner(mensagem: _erro),
              const SizedBox(height: 4),
              Center(
                child: Text(
                  'A avaliação é opcional — mas ajuda a comunidade.',
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 16),
              if (_args.avaliarServico) ...[
                _buildCardServico(),
                const SizedBox(height: 16),
              ],
              _buildCardPessoa(),
              const SizedBox(height: 20),
              AppButton(
                label: _nadaPreenchido ? 'Pular avaliação' : 'Enviar avaliação',
                loading: _enviando,
                onPressed: _enviar,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCardServico() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.black.withValues(alpha: 0.06)),
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
          Text(
            _args.nomeServico,
            style: AppTextStyles.corpo.copyWith(fontWeight: FontWeight.w700),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            'Como foi sua experiência com esse serviço?',
            style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          RatingInput(
            valor: _notaServico,
            onChanged: (v) => setState(() => _notaServico = v),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _mensagemServicoController,
            maxLines: 3,
            decoration: InputDecoration(
              labelText: 'Comentário sobre o serviço (opcional)',
              alignLabelWithHint: true,
              filled: true,
              fillColor: AppColors.background,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton.icon(
              onPressed: _enviando ? null : _contestar,
              icon: Icon(
                Icons.report_gmailerrorred_outlined,
                size: 16,
                color: Colors.grey.shade600,
              ),
              label: Text(
                'Contestar o serviço',
                style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCardPessoa() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.black.withValues(alpha: 0.06)),
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
          UserAvatar(avatarUrl: _args.avatarContraparte, radius: 32),
          const SizedBox(height: 10),
          Text(
            _args.nomeContraparte,
            style: AppTextStyles.corpo.copyWith(fontWeight: FontWeight.w700),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 2),
          Text(
            _args.papelContraparte,
            style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
          ),
          const SizedBox(height: 16),
          RatingInput(
            valor: _notaPessoa,
            onChanged: (v) => setState(() => _notaPessoa = v),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _mensagemPessoaController,
            maxLines: 3,
            decoration: InputDecoration(
              labelText: 'Comentário sobre ${_args.nomeContraparte} (opcional)',
              alignLabelWithHint: true,
              filled: true,
              fillColor: AppColors.background,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton.icon(
              onPressed: _enviando ? null : _denunciar,
              icon: Icon(
                Icons.flag_outlined,
                size: 16,
                color: Colors.grey.shade600,
              ),
              label: Text(
                'Denunciar ${_args.nomeContraparte}',
                style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
