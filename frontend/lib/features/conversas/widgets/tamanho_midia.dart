import 'dart:ui';

/// Calcula o tamanho de exibição de uma mídia (imagem ou vídeo) dentro do
/// chat, respeitando a proporção original mas limitando largura e altura
/// máximas — evita que um vídeo/foto gravado na vertical ocupe a tela toda.
Size tamanhoMidiaChat({
  required double aspectRatio,
  required double maxWidth,
  required double maxHeight,
  double minWidth = 150,
}) {
  var largura = maxHeight * aspectRatio;
  var altura = maxHeight;

  if (largura > maxWidth) {
    largura = maxWidth;
    altura = maxWidth / aspectRatio;
  }

  if (largura < minWidth) {
    largura = minWidth;
    altura = minWidth / aspectRatio;
    if (altura > maxHeight) {
      altura = maxHeight;
      largura = maxHeight * aspectRatio;
    }
  }

  return Size(largura, altura);
}
