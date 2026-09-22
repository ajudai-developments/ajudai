import 'package:backend/src/app/dependencies.dart';
import 'package:backend/src/ws/ws_server.dart';

class App {
  final Dependencies dependencies;

  App(this.dependencies);

  Future<void> start() async {
    dependencies.iniciarListeners();

    final server = WsServer(dependencies.router, dependencies.sessaoService);

    await server.iniciar();
  }
}
