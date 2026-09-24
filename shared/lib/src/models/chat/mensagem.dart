import 'package:shared/src/dto/json_utils.dart';
import 'package:shared/src/models/enums/tipo_conteudo_mensagem.dart';
import 'package:shared/src/models/arquivos/arquivo_anexado.dart';

class Mensagem {
  final String id;
  final String conversaId;
  final String remetenteId;
  final String? texto;
  final TipoConteudoMensagem tipo;
  final DateTime enviadoEm;
  final ArquivoAnexado? arquivo;

  Mensagem({
    required this.id,
    required this.conversaId,
    required this.remetenteId,
    required this.texto,
    required this.tipo,
    required this.enviadoEm,
    this.arquivo,
  });

  factory Mensagem.fromMap(Map<String, dynamic> map) {
    final arquivoJson = map['arquivo'] as Map<String, dynamic>?;
    return Mensagem(
      id: JsonUtils.requireString(map, 'id'),
      conversaId: JsonUtils.requireString(map, 'conversa_id'),
      remetenteId: JsonUtils.requireString(map, 'remetente_id'),
      texto: JsonUtils.optionalString(map, 'texto'),
      tipo:
          TipoConteudoMensagem.fromValor(
            JsonUtils.optionalString(map, 'tipo'),
          ) ??
          TipoConteudoMensagem.texto,
      enviadoEm: JsonUtils.requireDateTime(map, 'enviado_em'),
      arquivo: arquivoJson != null
          ? ArquivoAnexado.fromJson(arquivoJson)
          : null,
    );
  }

  factory Mensagem.fromJson(Map<String, dynamic> json) {
    final arquivoJson = json['arquivo'] as Map<String, dynamic>?;
    return Mensagem(
      id: JsonUtils.requireString(json, 'id'),
      conversaId: JsonUtils.requireString(json, 'conversa_id'),
      remetenteId: JsonUtils.requireString(json, 'remetente_id'),

      texto: JsonUtils.optionalString(json, 'texto'),
      tipo:
          TipoConteudoMensagem.fromValor(
            JsonUtils.optionalString(json, 'tipo'),
          ) ??
          TipoConteudoMensagem.texto,
      enviadoEm: JsonUtils.requireDateTime(json, 'enviado_em'),
      arquivo: arquivoJson != null
          ? ArquivoAnexado.fromJson(arquivoJson)
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'conversa_id': conversaId,
    'remetente_id': remetenteId,
    'texto': texto,
    'tipo': tipo.valor,
    'enviado_em': enviadoEm.toIso8601String(),
    'arquivo': arquivo?.toJson(),
  };
}
