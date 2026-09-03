import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'ws_client.dart';

/// TODO: mover para env/config ao subir para produção.
const String _wsUrl = 'wss://aerosol-fondling-reseller.ngrok-free.dev';

final wsClientProvider = Provider<WsClient>((ref) {
  final client = WsClient(url: Uri.parse(_wsUrl));
  ref.onDispose(client.desconectar);
  return client;
});
