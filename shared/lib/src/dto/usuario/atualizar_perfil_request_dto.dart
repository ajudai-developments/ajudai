import 'package:shared/src/dto/json_utils.dart';
import 'package:shared/src/dto/tipo_mensagem.dart';

import '../ws_message.dart';

class AtualizarPerfilRequestDto implements WsMessage {
  final String? nome;
  final String? telefone;

  AtualizarPerfilRequestDto({this.nome, this.telefone});

  @override
  TipoMensagem get tipo => TipoMensagem.atualizarPerfil;

  factory AtualizarPerfilRequestDto.fromJson(Map<String, dynamic> json) {
    return AtualizarPerfilRequestDto(
      nome: JsonUtils.optionalString(json, 'nome'),
      telefone: JsonUtils.optionalString(json, 'telefone'),
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'tipo': tipo.valor,
    'nome': ?nome,
    'telefone': ?telefone,
  };
}
