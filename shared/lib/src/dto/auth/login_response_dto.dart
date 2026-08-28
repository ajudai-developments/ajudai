import 'package:shared/src/dto/ws_message.dart';

class LoginResponseDto implements WsMessage {
  final String userId;

  LoginResponseDto({required this.userId});

  @override
  String get tipo => 'login_ok';

  @override
  Map<String, dynamic> toJson() => {'tipo': tipo, 'userId': userId};
}
