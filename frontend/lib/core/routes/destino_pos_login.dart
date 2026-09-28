import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:shared/shared.dart';

import '../session/sessao.dart';
import 'app_routes.dart';

String destinoPosLogin() {
  final papel = Sessao.instance.permissoes.papel;

  if (papel == UserRole.admin) {
    return kIsWeb ? AppRoutes.adminDashboard : AppRoutes.login;
  }
  return AppRoutes.home;
}
