import 'package:shared/src/dto/json_utils.dart';
import 'package:shared/src/dto/tipo_mensagem.dart';
import 'package:shared/src/dto/ws_message.dart';
import 'package:shared/src/models/arquivos/arquivo_upload.dart';

class SolicitarPrestadorRequestDto implements WsMessage {
  final List<ArquivoUpload> arquivos;

  SolicitarPrestadorRequestDto({required this.arquivos});

  @override
  TipoMensagem get tipo => TipoMensagem.solicitarPrestador;

  factory SolicitarPrestadorRequestDto.fromJson(Map<String, dynamic> json) {
    final lista = JsonUtils.requireListaDeMapas(json, 'arquivos');
    return SolicitarPrestadorRequestDto(
      arquivos: lista.map(ArquivoUpload.fromJson).toList(),
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'tipo': tipo.valor,
    'arquivos': arquivos.map((a) => a.toJson()).toList(),
  };
}
