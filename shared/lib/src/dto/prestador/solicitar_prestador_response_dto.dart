import 'package:shared/shared.dart';

class SolicitarPrestadorResponseDto implements WsMessage {
  final Usuario usuario;
  final Verificacao verificacao;

  SolicitarPrestadorResponseDto({
    required this.usuario,
    required this.verificacao,
  });

  @override
  TipoMensagem get tipo => TipoMensagem.solicitarPrestadorOk;

  factory SolicitarPrestadorResponseDto.fromJson(Map<String, dynamic> json) {
    return SolicitarPrestadorResponseDto(
      usuario: Usuario.fromJson(json['usuario'] as Map<String, dynamic>),
      verificacao: Verificacao.fromJson(
        json['verificacao'] as Map<String, dynamic>,
      ),
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'tipo': tipo.valor,
    'usuario': usuario.toJson(),
    'verificacao': verificacao.toJson(),
  };
}
