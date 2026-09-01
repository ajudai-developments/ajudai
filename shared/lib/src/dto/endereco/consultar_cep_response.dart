import '../tipo_mensagem.dart';
import '../ws_message.dart';

class ConsultarCepResponseDto implements WsMessage {
  final String cep;
  final String logradouro;
  final String bairro;
  final String cidade;
  final String estado;

  ConsultarCepResponseDto({
    required this.cep,
    required this.logradouro,
    required this.bairro,
    required this.cidade,
    required this.estado,
  });

  @override
  TipoMensagem get tipo => TipoMensagem.consultarCepOk;

  @override
  Map<String, dynamic> toJson() => {
    'tipo': tipo.valor,
    'cep': cep,
    'logradouro': logradouro,
    'bairro': bairro,
    'cidade': cidade,
    'estado': estado,
  };
}
