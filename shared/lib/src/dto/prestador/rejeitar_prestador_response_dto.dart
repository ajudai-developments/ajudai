import 'package:shared/shared.dart';

/// Importante: o enum `status_prestador` do banco não tem um valor
/// "rejeitado" — só nao_solicitado / pendente / aprovado / suspenso.
/// Ao rejeitar, o handler deve voltar `usuarios.status_prestador` para
/// `nao_solicitado` (permitindo solicitar de novo no futuro) e marcar
/// `verificacoes.status` como `rejeitado` (esse enum sim tem esse valor).
class RejeitarPrestadorResponseDto implements WsMessage {
  final Usuario usuario;
  final Verificacao verificacao;

  RejeitarPrestadorResponseDto({
    required this.usuario,
    required this.verificacao,
  });

  @override
  TipoMensagem get tipo => TipoMensagem.rejeitarPrestadorOk;

  factory RejeitarPrestadorResponseDto.fromJson(Map<String, dynamic> json) {
    return RejeitarPrestadorResponseDto(
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
