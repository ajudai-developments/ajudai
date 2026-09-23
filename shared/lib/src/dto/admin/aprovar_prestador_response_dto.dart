import 'package:shared/shared.dart';

class AprovarPrestadorResponseDto implements WsMessage {
  final Usuario usuario;
  final Verificacao? verificacao;

  AprovarPrestadorResponseDto({required this.usuario, this.verificacao});

  @override
  TipoMensagem get tipo => TipoMensagem.aprovarPrestadorOk;

  factory AprovarPrestadorResponseDto.fromJson(Map<String, dynamic> json) {
    return AprovarPrestadorResponseDto(
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
    'verificacao': verificacao?.toJson(),
  };
}
