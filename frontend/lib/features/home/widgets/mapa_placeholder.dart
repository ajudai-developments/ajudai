import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';

/// Placeholder do mapa de serviços próximos.
///
/// TODO: sem geolocalização/mapeamento de serviços no backend ainda.
/// Quando existir, substituir por um mapa real (ex: google_maps_flutter)
/// com os marcadores de prestadores próximos.
class MapaPlaceholder extends StatelessWidget {
  const MapaPlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 160,
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.textoSecundario.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      alignment: Alignment.center,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.map_outlined, color: AppColors.textoSecundario, size: 32),
          const SizedBox(height: 8),
          Text(
            'Mapa de serviços próximos em breve',
            style: TextStyle(color: AppColors.textoSecundario),
          ),
        ],
      ),
    );
  }
}
