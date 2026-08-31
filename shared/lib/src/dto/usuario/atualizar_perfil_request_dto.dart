import '../ws_message.dart';

class AtualizarPerfilRequestDto implements WsMessage {
  final String? nome;
  final String? telefone;

  AtualizarPerfilRequestDto({this.nome, this.telefone});

  @override
  String get tipo => 'atualizar_perfil';

  factory AtualizarPerfilRequestDto.fromJson(Map<String, dynamic> json) {
    return AtualizarPerfilRequestDto(
      nome: json['nome'] as String?,
      telefone: json['telefone'] as String?,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'tipo': tipo,
    'nome': ?nome,
    'telefone': ?telefone,
  };
}
