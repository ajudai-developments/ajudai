import 'package:ajudai/core/widgets/tipo_denuncia_label.dart';
import 'package:flutter/material.dart';
import 'package:shared/shared.dart';

import '../../core/routes/app_routes.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/async_list_view.dart';
import '../../core/widgets/status_chip.dart';
import 'denuncia_repository.dart';

/// Lista as denúncias que o usuário logado ABRIU (não as que ele
/// recebeu) — pensada pra viver dentro do Perfil. Tocar num item abre o
/// detalhe, com a linha do tempo de acompanhamento.
class MinhasDenunciasScreen extends StatelessWidget {
  const MinhasDenunciasScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Minhas denúncias')),
      body: AsyncListView<DenunciaComUrls>(
        carregar: DenunciaRepository().listarMinhasDenuncias,
        mensagemVazio: 'Você ainda não abriu nenhuma denúncia.',
        builder: (context, itens) => Column(
          children: [
            for (final item in itens) ...[
              _CartaoDenuncia(
                item: item,
                onTap: () => Navigator.of(
                  context,
                ).pushNamed(AppRoutes.denunciaDetalhe, arguments: item),
              ),
              const SizedBox(height: 12),
            ],
          ],
        ),
      ),
    );
  }
}

class _CartaoDenuncia extends StatelessWidget {
  final DenunciaComUrls item;
  final VoidCallback onTap;
  const _CartaoDenuncia({required this.item, required this.onTap});

  String _formatarData(DateTime data) =>
      '${data.day.toString().padLeft(2, '0')}/'
      '${data.month.toString().padLeft(2, '0')}/${data.year}';

  @override
  Widget build(BuildContext context) {
    final d = item.denuncia;

    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.outline),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    'Denúncia contra ${d.usuarioNome}',
                    style: AppTextStyles.titulo,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                StatusChip(valor: d.status.valor),
              ],
            ),
            const SizedBox(height: 2),
            Text(labelTipoDenuncia(d.tipo), style: AppTextStyles.legenda),
            const SizedBox(height: 4),
            Text(_formatarData(d.denunciadoEm), style: AppTextStyles.legenda),
            const SizedBox(height: 10),
            Text(
              d.descricao,
              style: AppTextStyles.corpo,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
            if (d.respostaAdmin != null) ...[
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.surfaceAlt,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Resposta da equipe', style: AppTextStyles.label),
                    const SizedBox(height: 4),
                    Text(d.respostaAdmin!, style: AppTextStyles.corpo),
                  ],
                ),
              ),
            ],
            if (item.urlsArquivos.isNotEmpty) ...[
              const SizedBox(height: 10),
              Row(
                children: [
                  const Icon(
                    Icons.attach_file_rounded,
                    size: 15,
                    color: AppColors.textoSecundario,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${item.urlsArquivos.length} anexo${item.urlsArquivos.length == 1 ? '' : 's'}',
                    style: AppTextStyles.legenda,
                  ),
                ],
              ),
            ],
            const SizedBox(height: 12),
            const Divider(height: 1, color: AppColors.outline),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  'Acompanhar andamento',
                  style: AppTextStyles.label.copyWith(color: AppColors.primary),
                ),
                const SizedBox(width: 2),
                const Icon(
                  Icons.chevron_right_rounded,
                  size: 18,
                  color: AppColors.primary,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
