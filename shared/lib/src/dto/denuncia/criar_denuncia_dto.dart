import 'package:shared/shared.dart';

class CriarDenunciaRequestDto implements WsMessage {
  final String usuarioId;
  final TipoDenuncia tipoDenuncia;
  final String descricao;
  final List<ArquivoUpload> arquivos;

  CriarDenunciaRequestDto({
    required this.usuarioId,
    required this.tipoDenuncia,
    required this.descricao,
    this.arquivos = const [],
  });

  factory CriarDenunciaRequestDto.fromJson(Map<String, dynamic> json) {
    final listaArquivos = json['arquivos'] as List? ?? [];
    return CriarDenunciaRequestDto(
      usuarioId: JsonUtils.requireString(json, 'usuario_id'),
      tipoDenuncia: TipoDenuncia.fromValor(
        JsonUtils.requireString(json, 'tipo_denuncia'),
      ),
      descricao: JsonUtils.requireString(json, 'descricao'),
      arquivos: listaArquivos
          .map((a) => ArquivoUpload.fromJson(a as Map<String, dynamic>))
          .toList(),
    );
  }

  @override
  TipoMensagem get tipo => TipoMensagem.criarDenuncia;

  @override
  Map<String, dynamic> toJson() => {
    'tipo': tipo.valor,
    'usuario_id': usuarioId,
    'tipo_denuncia': tipoDenuncia.valor,
    'descricao': descricao,
    'arquivos': arquivos.map((a) => a.toJson()).toList(),
  };
}

class CriarDenunciaResponseDto implements WsMessage {
  final String idDenuncia;
  final int quantidadeArquivosSalvos;

  CriarDenunciaResponseDto({
    required this.idDenuncia,
    required this.quantidadeArquivosSalvos,
  });

  factory CriarDenunciaResponseDto.fromJson(Map<String, dynamic> json) {
    return CriarDenunciaResponseDto(
      idDenuncia: JsonUtils.requireString(json, 'id_denuncia'),
      quantidadeArquivosSalvos: JsonUtils.requireInt(
        json,
        'quantidade_arquivos_salvos',
      ),
    );
  }

  @override
  TipoMensagem get tipo => TipoMensagem.criarDenunciaOk;

  @override
  Map<String, dynamic> toJson() => {
    'tipo': tipo.valor,
    'id_denuncia': idDenuncia,
    'quantidade_arquivos_salvos': quantidadeArquivosSalvos,
  };
}
