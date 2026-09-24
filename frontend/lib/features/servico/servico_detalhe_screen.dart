import 'package:flutter/material.dart';
import 'package:shared/shared.dart';

import '../../core/routes/app_routes.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/rating_display.dart';
import '../agendamento/criar_agendamento_args.dart';
import '../../core/widgets/user_avatar.dart';

/// Tela de detalhe de uma oferta de serviço.
///
/// Recebe o `ServicoOferecidoPreview` via argumento da rota e usa esse
/// resumo como fonte única de verdade para a apresentação do card e do
/// agendamento.
class ServicoDetalheScreen extends StatefulWidget {
  const ServicoDetalheScreen({super.key});

  @override
  State<ServicoDetalheScreen> createState() => _ServicoDetalheScreenState();
}

class _ServicoDetalheScreenState extends State<ServicoDetalheScreen> {
  late ServicoOferecidoPreview _servico;
  bool _argumentosCarregados = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_argumentosCarregados) return;
    _argumentosCarregados = true;

    final argumentos = ModalRoute.of(context)!.settings.arguments;
    if (argumentos is ServicoOferecidoPreview) {
      _servico = argumentos;
      return;
    }

    throw ArgumentError(
      'ServicoDetalheScreen espera um ServicoOferecidoPreview.',
    );
  }

  void _abrirPerfilPrestador() {
    Navigator.of(
      context,
    ).pushNamed(AppRoutes.perfilPublico, arguments: _servico.prestadorId);
  }

  void _agendar() {
    Navigator.of(context).pushNamed(
      AppRoutes.criarAgendamento,
      arguments: CriarAgendamentoArgs(
        servicoOferecidoId: _servico.servicoOferecidoId,
        prestadorId: _servico.prestadorId,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: Text(_servico.servicoNome)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildResumoServico(),
          const SizedBox(height: 16),
          _buildCartaoAgendamento(),
        ],
      ),
    );
  }

  Widget _buildResumoServico() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(_servico.servicoNome, style: AppTextStyles.titulo),
            const SizedBox(height: 4),
            Text(_servico.categoriaNome, style: AppTextStyles.legenda),
            const SizedBox(height: 12),
            InkWell(
              onTap: _abrirPerfilPrestador,
              borderRadius: BorderRadius.circular(12),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    UserAvatar(
                      avatarUrl: _servico.prestadorAvatarUrl,
                      radius: 24,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _servico.prestadorNome,
                            style: AppTextStyles.corpo,
                          ),
                          const SizedBox(height: 2),
                          Row(
                            children: [
                              if (_servico.prestadorVerificado) ...[
                                const Icon(
                                  Icons.verified,
                                  size: 16,
                                  color: AppColors.success,
                                ),
                                const SizedBox(width: 4),
                              ],
                              Flexible(
                                child: Text(
                                  '${_servico.quantidadeAvaliacoes} avaliações • ${_servico.quantidadeSelos} selos',
                                  style: AppTextStyles.legenda,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.chevron_right),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            RatingDisplay(
              media: _servico.mediaAvaliacao,
              quantidadeAvaliacoes: _servico.quantidadeAvaliacoes,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCartaoAgendamento() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Agendamento', style: AppTextStyles.titulo),
            const SizedBox(height: 12),
            _linha('Serviço', _servico.servicoNome),
            const SizedBox(height: 8),
            _linha('Categoria', _servico.categoriaNome),
            const SizedBox(height: 8),
            _linha('Prestador', _servico.prestadorNome),
            const SizedBox(height: 8),
            _linha('Valor', 'R\$ ${_servico.valor.toStringAsFixed(2)}'),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _agendar,
                child: const Text('Agendar'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _linha(String label, String valor) {
    return Row(
      children: [
        SizedBox(width: 90, child: Text(label, style: AppTextStyles.legenda)),
        Expanded(child: Text(valor, style: AppTextStyles.corpo)),
      ],
    );
  }
}
