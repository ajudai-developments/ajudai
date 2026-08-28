import '../ws_message.dart';

class CadastroResponseDto implements WsMessage {
  final String userId;

  CadastroResponseDto({required this.userId});

  @override
  String get tipo => 'cadastro_ok';

  @override
  Map<String, dynamic> toJson() => {'tipo': tipo, 'userId': userId};
}
