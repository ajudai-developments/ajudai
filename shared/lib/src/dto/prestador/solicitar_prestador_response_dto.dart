import 'package:shared/shared.dart';

class SolicitarPrestadorResponseDto implements WsMessage {
  final Usuario usuario;
  final Verificacao verificacao;
  final int quantidadeArquivosSalvos;

  SolicitarPrestadorResponseDto({
    required this.usuario,
    required this.verificacao,
    required this.quantidadeArquivosSalvos,
  });

  @override
  TipoMensagem get tipo => TipoMensagem.solicitarPrestadorOk;

  factory SolicitarPrestadorResponseDto.fromJson(Map<String, dynamic> json) {
    return SolicitarPrestadorResponseDto(
      usuario: Usuario.fromJson(json['usuario'] as Map<String, dynamic>),
      verificacao: Verificacao.fromJson(
        json['verificacao'] as Map<String, dynamic>,
      ),
      quantidadeArquivosSalvos: JsonUtils.requireInt(
        json,
        'quantidade_arquivos_salvos',
      ),
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'tipo': tipo.valor,
    'usuario': usuario.toJson(),
    'verificacao': verificacao.toJson(),
    'quantidade_arquivos_salvos': quantidadeArquivosSalvos,
  };
}
