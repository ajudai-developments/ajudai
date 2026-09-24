import 'package:shared/src/dto/json_utils.dart';
import 'package:shared/src/models/enums/tipo_denuncia.dart';
import 'package:shared/src/models/enums/status_denuncia.dart';
import 'package:shared/src/models/enums/user_role.dart';
import 'package:shared/src/models/enums/status_prestador.dart';
import 'package:shared/src/models/arquivos/arquivo_anexado.dart';

class DenunciaComDetalhes {
  final String id;
  final String usuarioId;
  final String usuarioNome;
  final UserRole usuarioRole;
  final StatusPrestador usuarioStatusPrestador;
  final bool usuarioBanido;
  final String denunciadorId;
  final String denunciadorNome;
  final TipoDenuncia tipo;
  final String descricao;
  final DateTime denunciadoEm;
  final StatusDenuncia status;
  final String? respostaAdmin;
  final String? respondidoPorAdminId;
  final DateTime? respondidoEm;
  final bool removeuPrestador;
  final bool baniuUsuario;
  final List<ArquivoAnexado> arquivos;

  DenunciaComDetalhes({
    required this.id,
    required this.usuarioId,
    required this.usuarioNome,
    required this.usuarioRole,
    required this.usuarioStatusPrestador,
    required this.usuarioBanido,
    required this.denunciadorId,
    required this.denunciadorNome,
    required this.tipo,
    required this.descricao,
    required this.denunciadoEm,
    required this.status,
    this.respostaAdmin,
    this.respondidoPorAdminId,
    this.respondidoEm,
    required this.removeuPrestador,
    required this.baniuUsuario,
    required this.arquivos,
  });

  factory DenunciaComDetalhes.fromJson(Map<String, dynamic> json) {
    final arquivos = JsonUtils.requireListaDeMapas(json, 'arquivos');
    return DenunciaComDetalhes(
      id: JsonUtils.requireString(json, 'id'),
      usuarioId: JsonUtils.requireString(json, 'usuario_id'),
      usuarioNome: JsonUtils.requireString(json, 'usuario_nome'),
      usuarioRole: UserRole.fromString(
        JsonUtils.requireString(json, 'usuario_role'),
      ),
      usuarioStatusPrestador: StatusPrestador.fromString(
        JsonUtils.requireString(json, 'usuario_status_prestador'),
      ),
      usuarioBanido: JsonUtils.requireBool(json, 'usuario_banido'),
      denunciadorId: JsonUtils.requireString(json, 'denunciador_id'),
      denunciadorNome: JsonUtils.requireString(json, 'denunciador_nome'),
      tipo: TipoDenuncia.fromValor(JsonUtils.requireString(json, 'tipo')),
      descricao: JsonUtils.requireString(json, 'descricao'),
      denunciadoEm: JsonUtils.requireDateTime(json, 'denunciado_em'),
      status: StatusDenuncia.fromValor(JsonUtils.requireString(json, 'status')),
      respostaAdmin: JsonUtils.optionalString(json, 'resposta_admin'),
      respondidoPorAdminId: JsonUtils.optionalString(
        json,
        'respondido_por_admin_id',
      ),
      respondidoEm: JsonUtils.optionalDateTime(json, 'respondido_em'),
      removeuPrestador: JsonUtils.requireBool(json, 'removeu_prestador'),
      baniuUsuario: JsonUtils.requireBool(json, 'baniu_usuario'),
      arquivos: arquivos.map(ArquivoAnexado.fromJson).toList(),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'usuario_id': usuarioId,
    'usuario_nome': usuarioNome,
    'usuario_role': usuarioRole.name,
    'usuario_status_prestador': usuarioStatusPrestador.name,
    'usuario_banido': usuarioBanido,
    'denunciador_id': denunciadorId,
    'denunciador_nome': denunciadorNome,
    'tipo': tipo.valor,
    'descricao': descricao,
    'denunciado_em': denunciadoEm.toIso8601String(),
    'status': status.valor,
    'resposta_admin': respostaAdmin,
    'respondido_por_admin_id': respondidoPorAdminId,
    'respondido_em': respondidoEm?.toIso8601String(),
    'removeu_prestador': removeuPrestador,
    'baniu_usuario': baniuUsuario,
    'arquivos': arquivos.map((a) => a.toJson()).toList(),
  };
}
