import 'package:backend/src/app/app.dart';
import 'package:backend/src/app/dependencies.dart';

Future<void> main() async {
  final dependencies = Dependencies();
  final app = App(dependencies);

  await app.start();
}
