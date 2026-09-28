import 'package:flutter/material.dart';
import 'package:shared/shared.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/secao_card.dart';
import 'usuario_repository.dart';

/// Estatísticas do próprio usuário: verificação, avaliação, conquistas,
/// agendamentos e tempo de resposta.
///
/// Mesmo padrão visual das demais telas: título alinhado à esquerda,
/// cartões de seção ([SecaoCard]) e destaques numéricos em cima, pra dar
/// pra ler o essencial num relance.
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
      appBar: AppBar(
        backgroundColor: AppColors.background,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleSpacing: 0,
        title: const Text('Meu perfil completo', style: AppTextStyles.titulo),
      ),
      body: SafeArea(child: _corpo()),
    );
  }

  Widget _corpo() {
    if (_carregando) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      );
    }

    if (_erro != null || _dados == null) {
      return _EstadoErro(
        mensagem: _erro ?? 'Não foi possível carregar as estatísticas.',
        onTentarNovamente: _carregar,
      );
    }

    final d = _dados!;

    return RefreshIndicator(
      color: AppColors.primary,
      onRefresh: _carregar,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
        children: [
          _CartaoVerificacao(dados: d),
          const SizedBox(height: 12),

          // Destaques
          // IntrinsicHeight: o Row com `stretch` dentro de um ListView
          // (altura ilimitada) estoura "infinite height" sem ele.
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(child: _DestaqueAvaliacao(dados: d)),
                const SizedBox(width: 12),
                Expanded(
                  child: _Destaque(
                    icone: Icons.emoji_events_rounded,
                    valor:
                        '${d.totalConquistas}/${d.totalConquistasDisponiveis}',
                    legenda: 'conquistas',
                  ),
                ),
              ],
            ),
          ),
          if (d.tempoMedioRespostaSegundos != null) ...[
            const SizedBox(height: 12),
            _LinhaDestaque(
              icone: Icons.timer_outlined,
              titulo: 'Tempo médio de resposta',
              valor: _formatarTempo(d.tempoMedioRespostaSegundos!),
            ),
          ],
          const SizedBox(height: 12),

          _CartaoAgendamentos(dados: d),
          const SizedBox(height: 20),

          Center(
            child: Text(
              'Membro desde ${_formatarData(d.membroDesde)}',
              style: AppTextStyles.legenda,
            ),
          ),
        ],
      ),
    );
  }

  static String _formatarTempo(int segundos) {
    if (segundos < 60) return '$segundos seg';
    final minutos = segundos ~/ 60;
    if (minutos < 60) return '$minutos min';
    final horas = minutos ~/ 60;
    return '$horas h';
  }

  static String _formatarData(DateTime dt) {
    final local = dt.toLocal();
    final dia = local.day.toString().padLeft(2, '0');
    final mes = local.month.toString().padLeft(2, '0');
    return '$dia/$mes/${local.year}';
  }
}

/// Erro de carregamento com ação de tentar de novo.
class _EstadoErro extends StatelessWidget {
  final String mensagem;
  final VoidCallback onTentarNovamente;

  const _EstadoErro({required this.mensagem, required this.onTentarNovamente});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: const BoxDecoration(
                color: AppColors.surfaceAlt,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.cloud_off_rounded,
                color: AppColors.textoSecundario,
                size: 28,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              mensagem,
              textAlign: TextAlign.center,
              style: AppTextStyles.corpo,
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: 200,
              child: AppButton(
                label: 'Tentar novamente',
                onPressed: onTentarNovamente,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Verificação: se já verificado, um selo de confirmação; se não, o
/// progresso dos requisitos (barra + checklist).
class _CartaoVerificacao extends StatelessWidget {
  final PerfilEstatisticas dados;

  const _CartaoVerificacao({required this.dados});

  @override
  Widget build(BuildContext context) {
    if (dados.verificado) {
      return SecaoCard(
        corFundo: AppColors.successSoft,
        child: Row(
          children: [
            const Icon(Icons.verified_rounded, color: AppColors.success),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Você é um usuário verificado',
                style: AppTextStyles.titulo.copyWith(fontSize: 15),
              ),
            ),
          ],
        ),
      );
    }

    final requisitos = dados.requisitosVerificacao;
    final cumpridos = requisitos.where((r) => r.cumprido).length;
    final progresso = requisitos.isEmpty ? 0.0 : cumpridos / requisitos.length;

    return SecaoCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text('Verifique sua conta', style: AppTextStyles.titulo),
              ),
              Text(
                '$cumpridos de ${requisitos.length}',
                style: AppTextStyles.label,
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: progresso,
              minHeight: 8,
              backgroundColor: AppColors.surfaceAlt,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 12),
          for (final r in requisitos) _RequisitoLinha(requisito: r),
        ],
      ),
    );
  }
}

class _RequisitoLinha extends StatelessWidget {
  final RequisitoVerificacao requisito;

  const _RequisitoLinha({required this.requisito});

  @override
  Widget build(BuildContext context) {
    final cumprido = requisito.cumprido;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            cumprido
                ? Icons.check_circle_rounded
                : Icons.radio_button_unchecked_rounded,
            size: 20,
            color: cumprido ? AppColors.success : AppColors.outline,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  requisito.descricao,
                  style: AppTextStyles.corpo.copyWith(
                    color: cumprido
                        ? AppColors.textoSecundario
                        : AppColors.textoTitulo,
                  ),
                ),
                const SizedBox(height: 2),
                Text(requisito.progresso, style: AppTextStyles.legenda),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Destaque da avaliação: nota grande + quantidade. Sem avaliações, mostra
/// um traço em vez do texto longo.
class _DestaqueAvaliacao extends StatelessWidget {
  final PerfilEstatisticas dados;

  const _DestaqueAvaliacao({required this.dados});

  @override
  Widget build(BuildContext context) {
    final media = dados.mediaAvaliacao;
    final temAvaliacao = media != null && dados.totalAvaliacoes > 0;

    return _Destaque(
      icone: Icons.star_rounded,
      corIcone: AppColors.avaliacao,
      valor: temAvaliacao ? media.toStringAsFixed(1) : '—',
      legenda: temAvaliacao
          ? '${dados.totalAvaliacoes} '
                '${dados.totalAvaliacoes == 1 ? 'avaliação' : 'avaliações'}'
          : 'sem avaliações',
    );
  }
}

/// Cartão de destaque: ícone, número grande e legenda curta.
class _Destaque extends StatelessWidget {
  final IconData icone;
  final Color corIcone;
  final String valor;
  final String legenda;

  const _Destaque({
    required this.icone,
    required this.valor,
    required this.legenda,
    this.corIcone = AppColors.primary,
  });

  @override
  Widget build(BuildContext context) {
    return SecaoCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icone, color: corIcone, size: 26),
          const SizedBox(height: 12),
          Text(valor, style: AppTextStyles.display),
          const SizedBox(height: 2),
          Text(legenda, style: AppTextStyles.legenda),
        ],
      ),
    );
  }
}

/// Destaque horizontal (ícone + título à esquerda, valor à direita).
class _LinhaDestaque extends StatelessWidget {
  final IconData icone;
  final String titulo;
  final String valor;

  const _LinhaDestaque({
    required this.icone,
    required this.titulo,
    required this.valor,
  });

  @override
  Widget build(BuildContext context) {
    return SecaoCard(
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: const BoxDecoration(
              color: AppColors.primarySoft,
              shape: BoxShape.circle,
            ),
            child: Icon(icone, color: AppColors.primary, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(child: Text(titulo, style: AppTextStyles.corpo)),
          Text(
            valor,
            style: AppTextStyles.titulo.copyWith(color: AppColors.textoTitulo),
          ),
        ],
      ),
    );
  }
}

/// Agendamentos concluídos/cancelados, como cliente e (se for prestador)
/// como prestador.
class _CartaoAgendamentos extends StatelessWidget {
  final PerfilEstatisticas dados;

  const _CartaoAgendamentos({required this.dados});

  @override
  Widget build(BuildContext context) {
    final ehPrestador = dados.agendamentosConcluidosComoPrestador != null;

    return SecaoCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Agendamentos', style: AppTextStyles.titulo),
          const SizedBox(height: 16),
          _BlocoAgendamentos(
            titulo: 'Como cliente',
            concluidos: dados.agendamentosConcluidosComoCliente,
            cancelados: dados.agendamentosCanceladosComoCliente,
          ),
          if (ehPrestador) ...[
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Divider(height: 1, color: AppColors.outline),
            ),
            _BlocoAgendamentos(
              titulo: 'Como prestador',
              concluidos: dados.agendamentosConcluidosComoPrestador ?? 0,
              cancelados: dados.agendamentosCanceladosComoPrestador ?? 0,
            ),
          ],
        ],
      ),
    );
  }
}

class _BlocoAgendamentos extends StatelessWidget {
  final String titulo;
  final int concluidos;
  final int cancelados;

  const _BlocoAgendamentos({
    required this.titulo,
    required this.concluidos,
    required this.cancelados,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(titulo, style: AppTextStyles.legenda),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: _Numero(
                valor: concluidos,
                legenda: 'concluídos',
                cor: AppColors.success,
              ),
            ),
            Expanded(
              child: _Numero(
                valor: cancelados,
                legenda: 'cancelados',
                cor: AppColors.textoNormal,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _Numero extends StatelessWidget {
  final int valor;
  final String legenda;
  final Color cor;

  const _Numero({
    required this.valor,
    required this.legenda,
    required this.cor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('$valor', style: AppTextStyles.display.copyWith(color: cor)),
        Text(legenda, style: AppTextStyles.legenda),
      ],
    );
  }
}
