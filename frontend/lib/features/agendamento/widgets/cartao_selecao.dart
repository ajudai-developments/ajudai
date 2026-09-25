import 'package:flutter/material.dart';

class CartaoSelecao extends StatelessWidget {
  final IconData icone;
  final String titulo;
  final String valor;
  final bool preenchido;
  final VoidCallback onTap;

  const CartaoSelecao({
    required this.icone,
    required this.titulo,
    required this.valor,
    required this.preenchido,
    required this.onTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFE3E3E3)),
        ),
        child: Row(
          children: [
            Icon(icone, color: Colors.black54, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    titulo,
                    style: const TextStyle(fontSize: 12, color: Colors.black45),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    valor,
                    style: TextStyle(
                      fontSize: 14.5,
                      fontWeight: FontWeight.w600,
                      color: preenchido ? Colors.black87 : Colors.black38,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: Colors.black38),
          ],
        ),
      ),
    );
  }
}
