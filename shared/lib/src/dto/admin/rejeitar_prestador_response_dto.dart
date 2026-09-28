import 'package:shared/shared.dart';

class RejeitarPrestadorResponseDto implements WsMessage {
  final Verificacao verificacao;

  RejeitarPrestadorResponseDto({required this.verificacao});

  @override
  TipoMensagem get tipo => TipoMensagem.rejeitarPrestadorOk;

  factory RejeitarPrestadorResponseDto.fromJson(Map<String, dynamic> json) {
    return RejeitarPrestadorResponseDto(
      verificacao: Verificacao.fromJson(
        json['verificacao'] as Map<String, dynamic>,
      ),
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'tipo': tipo.valor,
    'verificacao': verificacao.toJson(),
  };
}
