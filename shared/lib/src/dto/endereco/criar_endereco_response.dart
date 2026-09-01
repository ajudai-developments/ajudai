import '../tipo_mensagem.dart';
import '../ws_message.dart';
import '../../models/endereco.dart';

class CriarEnderecoResponseDto implements WsMessage {
  final Endereco endereco;

  const CriarEnderecoResponseDto({required this.endereco});

  @override
  TipoMensagem get tipo => TipoMensagem.criarEnderecoOk;

  @override
  Map<String, dynamic> toJson() => {
    'tipo': tipo.valor,
    'endereco': endereco.toJson(),
  };
}
