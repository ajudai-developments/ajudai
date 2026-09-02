import 'package:shared/src/dto/json_utils.dart';
import 'package:shared/src/dto/tipo_mensagem.dart';
import 'package:shared/src/dto/ws_message.dart';

/// O handler deve checar que o usuário da sessão tem
/// `status_prestador == aprovado` antes de gravar.
class CriarServicoOferecidoRequestDto implements WsMessage {
  final String servicoId;
  final String descricao;
  final double valor;

  CriarServicoOferecidoRequestDto({
    required this.servicoId,
    required this.descricao,
    required this.valor,
  });

  @override
  TipoMensagem get tipo => TipoMensagem.criarServicoOferecido;

  factory CriarServicoOferecidoRequestDto.fromJson(
    Map<String, dynamic> json,
  ) {
    final valor = JsonUtils.requireDouble(json, 'valor');
    if (valor < 0) {
      throw const FormatException('O valor não pode ser negativo.');
    }
    return CriarServicoOferecidoRequestDto(
      servicoId: JsonUtils.requireString(json, 'servico_id'),
      descricao: JsonUtils.requireString(json, 'descricao'),
      valor: valor,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'tipo': tipo.valor,
    'servico_id': servicoId,
    'descricao': descricao,
    'valor': valor,
  };
}
