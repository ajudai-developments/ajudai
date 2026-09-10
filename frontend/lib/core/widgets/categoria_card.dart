import 'package:flutter/material.dart';
import 'package:shared/shared.dart';

/// Card de categoria de serviço.
///
/// Reutilizado em: home_screen (grade resumida) e categorias_screen
/// (lista completa).
///
/// NOTA DE ACESSIBILIDADE (do protótipo original): evitar texto branco
/// sobreposto a imagem de fundo — baixo contraste. Em vez disso, cada
/// categoria deve ter UMA COR SÓLIDA + UM ÍCONE correspondente (ex:
/// faxina -> ícone de vassoura/balde, cor azul; cuidado de idosos ->
/// ícone de coração/mãos, cor laranja; etc). O texto do nome da
/// categoria fica sobre a cor sólida, não sobre foto, com uma cor de
/// texto que garanta contraste (ex: branco sobre cor escura saturada,
/// ou textoTitulo sobre cor clara).
///
/// TODO: mapear cada Categoria (vinda do backend, por nome) para um
/// (IconData, Color) fixo — precisa ser definido com design antes de
/// implementar de verdade. Por enquanto, ícone/cor genéricos abaixo.
class CategoriaCard extends StatelessWidget {
  final Categoria categoria;
  final VoidCallback onTap;

  const CategoriaCard({super.key, required this.categoria, required this.onTap});

  @override
  Widget build(BuildContext context) {
    // TODO: substituir por mapeamento categoria -> (icone, cor) real.
    const icone = Icons.miscellaneous_services;
    const cor = Colors.blueGrey;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        decoration: BoxDecoration(
          color: cor,
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(icone, color: Colors.white, size: 32),
            const SizedBox(height: 8),
            Text(
              categoria.nome,
              style: const TextStyle(color: Colors.white),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}