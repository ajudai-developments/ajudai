import 'package:flutter/material.dart';

/// Ícone usado quando o serviço não está no mapa (ex: um serviço novo
/// cadastrado no catálogo que ainda não ganhou ícone).
const IconData _iconePadrao = Icons.handyman_outlined;

/// Ícone de cada serviço do catálogo.
///
/// A chave é o NOME do serviço (é o que o app recebe em
/// `ServicoRecente.servicoNome`; os ids são uuids gerados no banco, então
/// não dá pra mapear por eles). A busca ignora maiúsculas, acentos e
/// pontuação — ver [_normalizar].
IconData iconeDoServico(String servicoNome) =>
    _icones[_normalizar(servicoNome)] ?? _iconePadrao;

/// Lê 'Corte de Cabelo', 'corte de cabelo', 'CORTE DE CABELO'... tudo igual.
String _normalizar(String texto) {
  const comAcento = 'áàâãäéèêëíìîïóòôõöúùûüçñ';
  const semAcento = 'aaaaaeeeeiiiiooooouuuucn';

  final buffer = StringBuffer();
  for (final rune in texto.toLowerCase().runes) {
    final caractere = String.fromCharCode(rune);
    final i = comAcento.indexOf(caractere);
    buffer.write(i >= 0 ? semAcento[i] : caractere);
  }

  return buffer
      .toString()
      .replaceAll(RegExp(r'[^a-z0-9 ]'), '')
      .replaceAll(RegExp(r'\s+'), ' ')
      .trim();
}

final Map<String, IconData> _icones = {
  for (final e in _iconesPorNome.entries) _normalizar(e.key): e.value,
};

const Map<String, IconData> _iconesPorNome = {
  // Beleza e Estética
  'Corte de Cabelo': Icons.content_cut_rounded,
  'Manicure e Pedicure': Icons.back_hand_outlined,
  'Maquiagem': Icons.brush_outlined,
  'Depilação': Icons.spa_outlined,
  'Design de Sobrancelhas': Icons.visibility_outlined,

  // Tecnologia
  'Formatação de Computador': Icons.computer_outlined,
  'Instalação de Redes/Wi-Fi': Icons.wifi_outlined,
  'Conserto de Celular': Icons.smartphone_outlined,
  'Instalação de Câmeras de Segurança': Icons.videocam_outlined,

  // Reformas e Construção
  'Pintura Residencial': Icons.format_paint_outlined,
  'Marcenaria': Icons.carpenter_outlined,
  'Instalação de Piso': Icons.grid_view_outlined,
  'Gesso e Drywall': Icons.layers_outlined,
  'Montagem de Móveis': Icons.chair_outlined,

  // Jardinagem
  'Manutenção de Jardim': Icons.yard_outlined,
  'Poda de Árvores': Icons.park_outlined,
  'Paisagismo': Icons.landscape_outlined,
  'Corte de Grama': Icons.grass_outlined,

  // Hidráulica
  'Reparo de Vazamentos': Icons.water_drop_outlined,
  'Desentupimento': Icons.plumbing_outlined,
  'Instalação de Torneiras e Registros': Icons.build_circle_outlined,
  "Instalação de Caixa d'Água": Icons.water_outlined,

  // Eventos
  'Fotografia de Eventos': Icons.photo_camera_outlined,
  'Buffet e Catering': Icons.restaurant_outlined,
  'Decoração de Festas': Icons.celebration_outlined,
  'DJ e Som para Eventos': Icons.headphones_outlined,

  // Pet Care
  'Banho e Tosa': Icons.bathtub_outlined,
  'Passeio com Cães': Icons.pets_outlined,
  'Adestramento': Icons.emoji_events_outlined,
  'Hospedagem de Pets': Icons.night_shelter_outlined,

  // Elétrica
  'Instalação Elétrica': Icons.electrical_services_outlined,
  'Manutenção Elétrica': Icons.bolt_outlined,
  'Instalação de Ar-Condicionado': Icons.ac_unit_outlined,
  'Instalação de Chuveiro Elétrico': Icons.shower_outlined,

  // Aulas Particulares
  'Reforço Escolar': Icons.menu_book_outlined,
  'Aulas de Idiomas': Icons.translate_outlined,
  'Aulas de Música': Icons.music_note_outlined,
  'Aulas de Informática': Icons.laptop_outlined,

  // Limpeza
  'Limpeza Residencial': Icons.cleaning_services_outlined,
  'Limpeza Pós-Obra': Icons.construction_outlined,
  'Limpeza de Estofados': Icons.weekend_outlined,
  'Limpeza de Vidros': Icons.window_outlined,
};
