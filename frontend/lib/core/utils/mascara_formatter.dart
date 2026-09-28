import 'package:flutter/services.dart';

/// Máscara de digitação para campos numéricos. Cada `#` na [mascara] é um
/// dígito; qualquer outro caractere é um separador fixo.
///
/// Só aceita dígitos, ignora o que passar do tamanho da máscara e não
/// deixa separador sobrando no final (apagar funciona normalmente).
///
///   inputFormatters: [MascaraFormatter.cpf]   // 123.456.789-09
///   inputFormatters: [MascaraFormatter.cep]   // 12345-678
///
/// O texto do campo fica COM os separadores. Antes de validar ou enviar,
/// tire tudo que não for dígito: `texto.replaceAll(RegExp(r'\D'), '')`.
class MascaraFormatter extends TextInputFormatter {
  final String mascara;

  const MascaraFormatter(this.mascara);

  static const cpf = MascaraFormatter('###.###.###-##');
  static const cep = MascaraFormatter('#####-###');

  static final _naoDigito = RegExp(r'\D');

  /// Aplica a máscara a um texto pronto (ex: ao preencher um campo por
  /// código, já que o `inputFormatters` só atua quando o usuário digita).
  String formatar(String texto) {
    return formatEditUpdate(
      TextEditingValue.empty,
      TextEditingValue(text: texto),
    ).text;
  }

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue valorAntigo,
    TextEditingValue valorNovo,
  ) {
    final texto = valorNovo.text;
    final digitos = texto.replaceAll(_naoDigito, '');

    // Quantos dígitos existem antes do cursor, pra recolocá-lo no lugar
    // certo depois de inserir os separadores.
    final offset = valorNovo.selection.baseOffset.clamp(0, texto.length);
    final digitosAntesDoCursor = texto
        .substring(0, offset)
        .replaceAll(_naoDigito, '')
        .length;

    final buffer = StringBuffer();
    var usados = 0;
    var cursor = 0;

    for (final c in mascara.split('')) {
      if (usados >= digitos.length) break;

      if (c == '#') {
        buffer.write(digitos[usados]);
        usados++;
        if (usados == digitosAntesDoCursor) cursor = buffer.length;
      } else {
        buffer.write(c);
      }
    }

    final formatado = buffer.toString();
    return TextEditingValue(
      text: formatado,
      selection: TextSelection.collapsed(
        offset: cursor.clamp(0, formatado.length),
      ),
    );
  }
}
