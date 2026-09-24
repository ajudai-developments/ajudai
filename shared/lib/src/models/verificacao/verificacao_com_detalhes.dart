import 'package:shared/src/dto/json_utils.dart';
import 'package:shared/src/models/enums/status_verificacao.dart';
import 'package:shared/src/models/arquivos/arquivo_anexado.dart';

class VerificacaoComDetalhes {
  final String id;
  final String usuarioId;
  final DateTime solicitadoEm;
  final DateTime? alteradoEm;
  final String? alteradoPorAdminId;
  final StatusVerificacao status;
  final String usuarioNome;
  final String usuarioCpf;
  final String? usuarioTelefone;
  final List<ArquivoAnexado> arquivos;

  VerificacaoComDetalhes({
    required this.id,
    required this.usuarioId,
    required this.solicitadoEm,
    this.alteradoEm,
    this.alteradoPorAdminId,
    required this.status,
    required this.usuarioNome,
    required this.usuarioCpf,
    this.usuarioTelefone,
    required this.arquivos,
  });

  factory VerificacaoComDetalhes.fromJson(Map<String, dynamic> json) {
    final arquivos = JsonUtils.requireListaDeMapas(json, 'arquivos');
    return VerificacaoComDetalhes(
      id: JsonUtils.requireString(json, 'id'),
      usuarioId: JsonUtils.requireString(json, 'usuario_id'),
      solicitadoEm: JsonUtils.requireDateTime(json, 'solicitado_em'),
      alteradoEm: JsonUtils.optionalDateTime(json, 'alterado_em'),
      alteradoPorAdminId: JsonUtils.optionalString(
        json,
        'alterado_por_admin_id',
      ),
      status: StatusVerificacao.values.byName(
        JsonUtils.requireString(json, 'status'),
      ),
      usuarioNome: JsonUtils.requireString(json, 'usuario_nome'),
      usuarioCpf: JsonUtils.requireString(json, 'usuario_cpf'),
      usuarioTelefone: JsonUtils.optionalString(json, 'usuario_telefone'),
      arquivos: arquivos.map(ArquivoAnexado.fromJson).toList(),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'usuario_id': usuarioId,
    'solicitado_em': solicitadoEm.toIso8601String(),
    'alterado_em': alteradoEm?.toIso8601String(),
    'alterado_por_admin_id': alteradoPorAdminId,
    'status': status.name,
    'usuario_nome': usuarioNome,
    'usuario_cpf': usuarioCpf,
    'usuario_telefone': usuarioTelefone,
    'arquivos': arquivos.map((a) => a.toJson()).toList(),
  };
}
