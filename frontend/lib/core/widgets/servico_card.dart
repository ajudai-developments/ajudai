import 'package:flutter/material.dart';
import 'package:shared/shared.dart';

import 'rating_display.dart';

/// Card resumido de um serviço oferecido.
///
/// Reutilizado em: servicos_lista_screen (busca/listagem) e
/// perfil_publico_screen (serviços oferecidos por um prestador).
///
/// O botão "Agendar" leva direto para a tela de criação de agendamento
/// referente a este servico_oferecido_id.
class ServicoCard extends StatelessWidget {
  final ServicoOferecidoPreview servico;
  final VoidCallback onTapDetalhe;
  final VoidCallback onTapAgendar;

  const ServicoCard({
    super.key,
    required this.servico,
    required this.onTapDetalhe,
    required this.onTapAgendar,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 0,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: theme.colorScheme.outlineVariant),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTapDetalhe,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _PrestadorAvatar(
                    avatarUrl: servico.prestadorAvatarUrl,
                    nome: servico.prestadorNome,
                    verificado: servico.prestadorVerificado,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          servico.servicoNome,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                servico.prestadorNome,
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (servico.prestadorVerificado) ...[
                              const SizedBox(width: 4),
                              Icon(
                                Icons.verified,
                                size: 15,
                                color: theme.colorScheme.primary,
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 6,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  _CategoriaChip(nome: servico.categoriaNome),
                  RatingDisplay(
                    media: servico.mediaAvaliacao,
                    quantidadeAvaliacoes: servico.quantidadeAvaliacoes ?? 0,
                  ),
                  if (servico.quantidadeSelos != null)
                    _SelosBadge(quantidade: servico.quantidadeSelos ?? 0),
                ],
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'A partir de',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                        Text(
                          _formatarValor(servico.valor),
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  FilledButton(
                    onPressed: onTapAgendar,
                    style: FilledButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 10,
                      ),
                    ),
                    child: const Text('Agendar'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatarValor(double valor) {
    return 'R\$ ${valor.toStringAsFixed(2).replaceAll('.', ',')}';
  }
}

class _PrestadorAvatar extends StatelessWidget {
  final String? avatarUrl;
  final String nome;
  final bool verificado;

  const _PrestadorAvatar({
    required this.avatarUrl,
    required this.nome,
    required this.verificado,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final iniciais = nome.trim().isNotEmpty
        ? nome.trim()[0].toUpperCase()
        : '?';

    return Stack(
      clipBehavior: Clip.none,
      children: [
        CircleAvatar(
          radius: 26,
          backgroundColor: theme.colorScheme.primaryContainer,
          backgroundImage: avatarUrl != null ? NetworkImage(avatarUrl!) : null,
          child: avatarUrl == null
              ? Text(
                  iniciais,
                  style: TextStyle(
                    color: theme.colorScheme.onPrimaryContainer,
                    fontWeight: FontWeight.bold,
                  ),
                )
              : null,
        ),
        if (verificado)
          Positioned(
            right: -2,
            bottom: -2,
            child: Container(
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.verified,
                size: 16,
                color: theme.colorScheme.primary,
              ),
            ),
          ),
      ],
    );
  }
}

class _CategoriaChip extends StatelessWidget {
  final String nome;

  const _CategoriaChip({required this.nome});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: theme.colorScheme.secondaryContainer,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        nome,
        style: theme.textTheme.labelSmall?.copyWith(
          color: theme.colorScheme.onSecondaryContainer,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _SelosBadge extends StatelessWidget {
  final int quantidade;

  const _SelosBadge({required this.quantidade});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          Icons.workspace_premium,
          size: 15,
          color: theme.colorScheme.tertiary,
        ),
        const SizedBox(width: 3),
        Text(
          '$quantidade ${quantidade == 1 ? 'selo' : 'selos'}',
          style: theme.textTheme.labelSmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}
