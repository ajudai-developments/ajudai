import 'package:flutter/material.dart';
import 'package:shared/shared.dart';

import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/user_avatar.dart';

/// Card compacto de um prestador recente (foto + nome), usado na Home.
/// Ao tocar, o chamador leva pro detalhe do serviço que o usuário
/// contratou com esse prestador.
class PrestadorRecenteCard extends StatelessWidget {
  final PrestadorRecente prestador;
  final VoidCallback onTap;

  const PrestadorRecenteCard({
    super.key,
    required this.prestador,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 84,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Column(
            children: [
              UserAvatar(avatarUrl: prestador.prestadorAvatarUrl, radius: 30),
              const SizedBox(height: 8),
              Text(
                prestador.prestadorNome,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: AppTextStyles.corpo.copyWith(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
