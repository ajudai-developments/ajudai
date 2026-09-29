import 'package:ajudai/core/layout/responsivo.dart';
import 'package:ajudai/core/routes/app_routes.dart';
import 'package:ajudai/core/theme/app_colors.dart';
import 'package:ajudai/core/theme/app_text_styles.dart';
import 'package:ajudai/core/widgets/grade_adaptativa.dart';
import 'package:ajudai/core/widgets/shell_admin.dart';
import 'package:flutter/material.dart';
import 'package:shared/shared.dart';

import 'admin_repository.dart';

/// Painel inicial do admin: resumo do que está esperando ação.
class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  final _repo = AdminRepository();

  late final Future<int> _verificacoes = _repo
      .listarVerificacoes(StatusVerificacao.pendente)
      .then((l) => l.length);
  late final Future<int> _contestacoes = _repo
      .listarContestacoes(StatusContestacao.aberta)
      .then((l) => l.length);
  late final Future<int> _denuncias = _repo
      .listarDenuncias(StatusDenuncia.aberta)
      .then((l) => l.length);

  @override
  Widget build(BuildContext context) {
    return ShellAdmin(
      titulo: 'Painel',
      rotaAtual: AppRoutes.adminDashboard,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(32),
        child: ConteudoCentralizado(
          larguraMax: 1000,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Pendências', style: AppTextStyles.display),
              const SizedBox(height: 4),
              const Text(
                'O que está aguardando uma decisão da equipe.',
                style: AppTextStyles.corpo,
              ),
              const SizedBox(height: 28),
              GradeAdaptativa(
                larguraMinItem: 260,
                children: [
                  _CardResumo(
                    titulo: 'Verificações pendentes',
                    icone: Icons.verified_user_outlined,
                    futuro: _verificacoes,
                    rota: AppRoutes.verificacoes,
                  ),
                  _CardResumo(
                    titulo: 'Contestações abertas',
                    icone: Icons.gavel_outlined,
                    futuro: _contestacoes,
                    rota: AppRoutes.adminContestacoes,
                  ),
                  _CardResumo(
                    titulo: 'Denúncias abertas',
                    icone: Icons.flag_outlined,
                    futuro: _denuncias,
                    rota: AppRoutes.adminDenuncias,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CardResumo extends StatelessWidget {
  final String titulo;
  final IconData icone;
  final Future<int> futuro;
  final String rota;

  const _CardResumo({
    required this.titulo,
    required this.icone,
    required this.futuro,
    required this.rota,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => Navigator.of(context).pushReplacementNamed(rota),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.outline),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: const BoxDecoration(
                  color: AppColors.primarySoft,
                  shape: BoxShape.circle,
                ),
                child: Icon(icone, color: AppColors.primary, size: 22),
              ),
              const SizedBox(height: 16),
              FutureBuilder<int>(
                future: futuro,
                builder: (context, snap) {
                  if (snap.hasError) {
                    return const Text(
                      '—',
                      style: TextStyle(
                        fontSize: 34,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textoSecundario,
                      ),
                    );
                  }
                  if (!snap.hasData) {
                    return const SizedBox(
                      height: 42,
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    );
                  }
                  return Text(
                    '${snap.data}',
                    style: const TextStyle(
                      fontSize: 34,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textoTitulo,
                    ),
                  );
                },
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Expanded(child: Text(titulo, style: AppTextStyles.corpo)),
                  const Icon(
                    Icons.arrow_forward_rounded,
                    size: 18,
                    color: AppColors.textoSecundario,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
