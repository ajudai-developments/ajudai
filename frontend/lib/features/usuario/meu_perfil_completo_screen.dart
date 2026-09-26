import 'package:flutter/material.dart';
import 'package:shared/shared.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/rating_display.dart';
import 'usuario_repository.dart';

class MeuPerfilCompletoScreen extends StatefulWidget {
  const MeuPerfilCompletoScreen({super.key});

  @override
  State<MeuPerfilCompletoScreen> createState() =>
      _MeuPerfilCompletoScreenState();
}

class _MeuPerfilCompletoScreenState extends State<MeuPerfilCompletoScreen> {
  final _repository = UsuarioRepository();

  bool _carregando = true;
  String? _erro;
  PerfilEstatisticas? _dados;

  @override
  void initState() {
    super.initState();
    _carregar();
  }

  Future<void> _carregar() async {
    setState(() {
      _carregando = true;
      _erro = null;
    });
    try {
      final dados = await _repository.obterPerfilEstatisticas();
      if (mounted) setState(() => _dados = dados);
    } catch (_) {
      if (mounted) {
        setState(() => _erro = 'Não foi possível carregar as estatísticas.');
      }
    } finally {
      if (mounted) setState(() => _carregando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Meu perfil completo')),
      body: SafeArea(
        child: _carregando
            ? const Center(child: CircularProgressIndicator())
            : _erro != null
            ? Center(child: Text(_erro!))
            : RefreshIndicator(
                onRefresh: _carregar,
                child: ListView(
                  padding: const EdgeInsets.all(20),
                  children: _buildConteudo(_dados!),
                ),
              ),
      ),
    );
  }

  List<Widget> _buildConteudo(PerfilEstatisticas d) {
    return [
      _cardVerificacao(d),
      const SizedBox(height: 16),
      _card(
        titulo: 'Avaliação',
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            RatingDisplay(
              media: d.mediaAvaliacao,
              quantidadeAvaliacoes: d.totalAvaliacoes,
            ),
          ],
        ),
      ),
      const SizedBox(height: 16),
      _card(
        titulo: 'Agendamentos',
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _estatLinha(
              'Concluídos como cliente',
              d.agendamentosConcluidosComoCliente,
            ),
            _estatLinha(
              'Cancelados como cliente',
              d.agendamentosCanceladosComoCliente,
            ),
            if (d.agendamentosConcluidosComoPrestador != null) ...[
              const Divider(height: 20),
              _estatLinha(
                'Concluídos como prestador',
                d.agendamentosConcluidosComoPrestador!,
              ),
              _estatLinha(
                'Cancelados como prestador',
                d.agendamentosCanceladosComoPrestador!,
              ),
            ],
          ],
        ),
      ),
      if (d.tempoMedioRespostaSegundos != null) ...[
        const SizedBox(height: 16),
        _card(
          titulo: 'Tempo médio de resposta',
          child: Text(
            _formatarTempo(d.tempoMedioRespostaSegundos!),
            style: AppTextStyles.corpo,
          ),
        ),
      ],
      const SizedBox(height: 16),
      _card(
        titulo: 'Conquistas',
        child: Text(
          '${d.totalConquistas} de ${d.totalConquistasDisponiveis} desbloqueadas',
          style: AppTextStyles.corpo,
        ),
      ),
      const SizedBox(height: 16),
      _card(
        titulo: 'Membro desde',
        child: Text(_formatarData(d.membroDesde), style: AppTextStyles.corpo),
      ),
    ];
  }

  Widget _cardVerificacao(PerfilEstatisticas d) {
    if (d.verificado) {
      return _card(
        titulo: 'Verificação',
        child: const Row(
          children: [
            Icon(Icons.verified, color: AppColors.success),
            SizedBox(width: 8),
            Text('Você é um usuário verificado!'),
          ],
        ),
      );
    }

    return _card(
      titulo: 'Requisitos para verificação',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [for (final r in d.requisitosVerificacao) _requisitoLinha(r)],
      ),
    );
  }

  Widget _requisitoLinha(RequisitoVerificacao r) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            r.cumprido ? Icons.check_circle : Icons.radio_button_unchecked,
            size: 18,
            color: r.cumprido ? AppColors.success : Colors.grey.shade400,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  r.descricao,
                  style: TextStyle(
                    decoration: r.cumprido ? TextDecoration.lineThrough : null,
                    color: r.cumprido ? Colors.grey.shade500 : null,
                  ),
                ),
                Text(
                  r.progresso,
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _estatLinha(String label, int valor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: AppTextStyles.corpo),
          Text('$valor', style: const TextStyle(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _card({required String titulo, required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.black.withValues(alpha: 0.06)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(titulo, style: AppTextStyles.titulo.copyWith(fontSize: 15)),
          const SizedBox(height: 10),
          child,
        ],
      ),
    );
  }

  String _formatarTempo(int segundos) {
    if (segundos < 60) return '$segundos seg';
    final minutos = segundos ~/ 60;
    if (minutos < 60) return '$minutos min';
    final horas = minutos ~/ 60;
    return '$horas h';
  }

  String _formatarData(DateTime dt) {
    final local = dt.toLocal();
    return '${local.day.toString().padLeft(2, '0')}/${local.month.toString().padLeft(2, '0')}/${local.year}';
  }
}
