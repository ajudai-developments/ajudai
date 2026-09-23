import 'package:shared/shared.dart';

class CriarContestacaoRequestDto implements WsMessage {
  final String agendamentoId;
  final String descricao;
  final List<ArquivoUpload> arquivos;

  CriarContestacaoRequestDto({
    required this.agendamentoId,
    required this.descricao,
    this.arquivos = const [],
  });

  factory CriarContestacaoRequestDto.fromJson(Map<String, dynamic> json) {
    final listaArquivos = json['arquivos'] as List? ?? [];
    return CriarContestacaoRequestDto(
      agendamentoId: JsonUtils.requireString(json, 'agendamento_id'),
      descricao: JsonUtils.requireString(json, 'descricao'),
      arquivos: listaArquivos
          .map((a) => ArquivoUpload.fromJson(a as Map<String, dynamic>))
          .toList(),
    );
  }

  @override
  TipoMensagem get tipo => TipoMensagem.criarContestacao;

  @override
  Map<String, dynamic> toJson() => {
    'tipo': tipo.valor,
    'agendamento_id': agendamentoId,
    'descricao': descricao,
    'arquivos': arquivos.map((a) => a.toJson()).toList(),
  };
}

class CriarContestacaoResponseDto implements WsMessage {
  final String idContestacao;
  final int quantidadeArquivosSalvos;

  CriarContestacaoResponseDto({
    required this.idContestacao,
    required this.quantidadeArquivosSalvos,
  });

  factory CriarContestacaoResponseDto.fromJson(Map<String, dynamic> json) {
    return CriarContestacaoResponseDto(
      idContestacao: JsonUtils.requireString(json, 'id_contestacao'),
      quantidadeArquivosSalvos: JsonUtils.requireInt(
        json,
        'quantidade_arquivos_salvos',
      ),
    );
  }

  @override
  TipoMensagem get tipo => TipoMensagem.criarContestacaoOk;

  @override
  Map<String, dynamic> toJson() => {
    'tipo': tipo.valor,
    'id_contestacao': idContestacao,
    'quantidade_arquivos_salvos': quantidadeArquivosSalvos,
  };
}
