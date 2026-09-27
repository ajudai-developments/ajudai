import 'package:ajudai/core/ws/ws_client.dart';
import 'package:ajudai/features/auth/auth_repository.dart';
import 'package:flutter/material.dart';

import 'app.dart';

void main() {
  WsClient.instance.aoRestaurarSessao(() => AuthRepository().restaurarSessao());
  runApp(const App());
}
