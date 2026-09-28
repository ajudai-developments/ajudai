import 'package:flutter/material.dart';

import '../../../core/routes/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/app_button.dart';

/// Passo 2 do cadastro: endereço (opcional).
///
/// Reaproveita o formulário de endereço que já existe no app
/// (AppRoutes.formEndereco), que devolve `true` ao salvar com sucesso.
/// Tanto salvar quanto "Fazer isso depois" chamam [onAvancar].
class CadastroEnderecoStep extends StatelessWidget {
  final VoidCallback onAvancar;

  const CadastroEnderecoStep({super.key, required this.onAvancar});

  Future<void> _adicionar(BuildContext context) async {
    final resultado = await Navigator.of(
      context,
    ).pushNamed(AppRoutes.formEndereco);
    if (resultado == true) onAvancar();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(height: 24),
                  Container(
                    width: 120,
                    height: 120,
                    decoration: const BoxDecoration(
                      color: AppColors.primarySoft,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.location_on_rounded,
                      size: 56,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 28),
                  Text(
                    'Onde você precisa de ajuda?',
                    textAlign: TextAlign.center,
                    style: AppTextStyles.display.copyWith(fontSize: 24),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Cadastre seu endereço para agendar serviços mais '
                    'rápido. Você também pode fazer isso depois.',
                    textAlign: TextAlign.center,
                    style: AppTextStyles.corpo,
                  ),
                  const SizedBox(height: 28),
                  const _Dica(
                    icone: Icons.info_outline_rounded,
                    texto:
                        'Seus endereços ficam em Perfil › Meus endereços, '
                        'onde você pode adicionar ou revisar quando quiser.',
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          AppButton(
            label: 'Adicionar endereço',
            onPressed: () => _adicionar(context),
          ),
          const SizedBox(height: 8),
          TextButton(
            onPressed: onAvancar,
            style: TextButton.styleFrom(
              foregroundColor: AppColors.textoSecundario,
            ),
            child: const Text('Fazer isso depois'),
          ),
        ],
      ),
    );
  }
}

class _Dica extends StatelessWidget {
  final IconData icone;
  final String texto;

  const _Dica({required this.icone, required this.texto});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surfaceAlt,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icone, size: 20, color: AppColors.textoSecundario),
          const SizedBox(width: 10),
          Expanded(child: Text(texto, style: AppTextStyles.legenda)),
        ],
      ),
    );
  }
}
