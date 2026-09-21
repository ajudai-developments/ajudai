import 'package:shared/src/dto/json_utils.dart';
import 'package:shared/src/models/enums/tipo_conteudo_mensagem.dart';

class Mensagem {
  final String id;
  final String idConversa;
  final String idRemetente;
  final String? texto;
  final TipoConteudoMensagem tipo;
  final DateTime enviadoEm;

  Mensagem({
    required this.id,
    required this.idConversa,
    required this.idRemetente,
    required this.texto,
    required this.tipo,
    required this.enviadoEm,
  });

  factory Mensagem.fromMap(Map<String, dynamic> map) {
    return Mensagem(
      id: JsonUtils.requireString(map, 'id'),
      idConversa: JsonUtils.requireString(map, 'conversa_id'),
      idRemetente: JsonUtils.requireString(map, 'remetente_id'),
      texto: JsonUtils.optionalString(map, 'texto'),
      tipo:
          TipoConteudoMensagem.fromValor(
            JsonUtils.optionalString(map, 'tipo'),
          ) ??
          TipoConteudoMensagem.texto,
      enviadoEm: JsonUtils.requireDateTime(map, 'enviado_em'),
    );
  }

  factory Mensagem.fromJson(Map<String, dynamic> json) {
    return Mensagem(
      id: JsonUtils.requireString(json, 'id'),
      idConversa: JsonUtils.requireString(json, 'id_conversa'),
      idRemetente: JsonUtils.requireString(json, 'id_remetente'),
      texto: JsonUtils.optionalString(json, 'texto'),
      tipo:
          TipoConteudoMensagem.fromValor(
            JsonUtils.optionalString(json, 'tipo'),
          ) ??
          TipoConteudoMensagem.texto,
      enviadoEm: JsonUtils.requireDateTime(json, 'enviado_em'),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'id_conversa': idConversa,
    'id_remetente': idRemetente,
    'texto': texto,
    'tipo': tipo.valor,
    'enviado_em': enviadoEm.toIso8601String(),
  };
}
