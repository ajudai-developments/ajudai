import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared/shared.dart';

class SessionStorage {
  static const _chaveUsuario = 'usuario_logado';

  final FlutterSecureStorage _storage;

  SessionStorage({FlutterSecureStorage? storage})
    : _storage = storage ?? const FlutterSecureStorage();

  Future<void> salvar(Usuario usuario) async {
    await _storage.write(
      key: _chaveUsuario,
      value: jsonEncode(usuario.toJson()),
    );
  }

  Future<Usuario?> carregar() async {
    final bruto = await _storage.read(key: _chaveUsuario);
    if (bruto == null) return null;
    return Usuario.fromJson(jsonDecode(bruto) as Map<String, dynamic>);
  }

  Future<void> limpar() async {
    await _storage.delete(key: _chaveUsuario);
  }
}
