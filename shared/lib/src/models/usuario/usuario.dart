import 'package:shared/shared.dart';

class Usuario {
  final String id;
  final String nome;
  final String cpf;
  final String? telefone;
  final UserRole userRole;
  final bool statusUsuario;
  final StatusPrestador statusPrestador;
  final bool verificado;
  final String? avatarUrl;
  final DateTime criadoEm;
  final DateTime? editadoEm;

  Usuario({
    required this.id,
    required this.nome,
    required this.cpf,
    this.telefone,
    this.userRole = UserRole.cliente,
    this.statusUsuario = false,
    this.statusPrestador = StatusPrestador.naoSolicitado,
    this.verificado = false,
    this.avatarUrl,
    required this.criadoEm,
    this.editadoEm,
  });

  Usuario copyWith({
    String? id,
    String? nome,
    String? cpf,
    String? telefone,
    UserRole? userRole,
    bool? statusUsuario,
    StatusPrestador? statusPrestador,
    bool? verificado,
    String? avatarUrl,
    DateTime? criadoEm,
    DateTime? editadoEm,
  }) {
    return Usuario(
      id: id ?? this.id,
      nome: nome ?? this.nome,
      cpf: cpf ?? this.cpf,
      telefone: telefone ?? this.telefone,
      userRole: userRole ?? this.userRole,
      statusUsuario: statusUsuario ?? this.statusUsuario,
      statusPrestador: statusPrestador ?? this.statusPrestador,
      verificado: verificado ?? this.verificado,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      criadoEm: criadoEm ?? this.criadoEm,
      editadoEm: editadoEm ?? this.editadoEm,
    );
  }

  factory Usuario.fromJson(Map<String, dynamic> json) {
    return Usuario(
      id: json['id'] as String,
      nome: json['nome'] as String,
      cpf: json['cpf'] as String,
      telefone: json['telefone'] as String?,
      userRole: UserRole.fromString(json['user_role'] as String),
      statusUsuario: json['status_usuario'] as bool,
      statusPrestador: StatusPrestador.fromString(
        json['status_prestador'] as String,
      ),
      verificado: json['verificado'] as bool,
      avatarUrl: json['avatar_url'] as String?,
      criadoEm: DateTime.parse(json['criado_em'] as String),
      editadoEm: json['editado_em'] != null
          ? DateTime.parse(json['editado_em'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'nome': nome,
    'cpf': cpf,
    'telefone': telefone,
    'user_role': userRole.name,
    'status_usuario': statusUsuario,
    'status_prestador': statusPrestador.toDbValue(),
    'verificado': verificado,
    'avatar_url': avatarUrl,
    'criado_em': criadoEm.toIso8601String(),
    'editado_em': editadoEm?.toIso8601String(),
  };
}
