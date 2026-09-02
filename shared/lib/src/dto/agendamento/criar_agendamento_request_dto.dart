import 'package:shared/src/dto/json_utils.dart';
import 'package:shared/src/dto/tipo_mensagem.dart';
import 'package:shared/src/dto/ws_message.dart';

class CriarAgendamentoRequestDto implements WsMessage {
  final String servicoOferecidoId;
  final String? enderecoId;
  final String? enderecoLogradouro;
  final String? enderecoNumero;
  final String? enderecoComplemento;
  final String? enderecoBairro;
  final String? enderecoCidade;
  final String? enderecoEstado;
  final String? enderecoCep;
  final DateTime horaInicio;
  final DateTime horaFim;

  CriarAgendamentoRequestDto({
    required this.servicoOferecidoId,
    this.enderecoId,
    this.enderecoLogradouro,
    this.enderecoNumero,
    this.enderecoComplemento,
    this.enderecoBairro,
    this.enderecoCidade,
    this.enderecoEstado,
    this.enderecoCep,
    required this.horaInicio,
    required this.horaFim,
  });

  bool get usaEnderecoSalvo => enderecoId != null;

  @override
  TipoMensagem get tipo => TipoMensagem.criarAgendamento;

  factory CriarAgendamentoRequestDto.fromJson(Map<String, dynamic> json) {
    return CriarAgendamentoRequestDto(
      servicoOferecidoId: JsonUtils.requireString(json, 'servico_oferecido_id'),
      enderecoId: JsonUtils.optionalString(json, 'endereco_id'),
      enderecoLogradouro: JsonUtils.optionalString(json, 'endereco_logradouro'),
      enderecoNumero: JsonUtils.optionalString(json, 'endereco_numero'),
      enderecoComplemento: JsonUtils.optionalString(
        json,
        'endereco_complemento',
      ),
      enderecoBairro: JsonUtils.optionalString(json, 'endereco_bairro'),
      enderecoCidade: JsonUtils.optionalString(json, 'endereco_cidade'),
      enderecoEstado: JsonUtils.optionalString(json, 'endereco_estado'),
      enderecoCep: JsonUtils.optionalString(json, 'endereco_cep'),
      horaInicio: JsonUtils.requireDateTime(json, 'hora_inicio'),
      horaFim: JsonUtils.requireDateTime(json, 'hora_fim'),
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'tipo': tipo.valor,
    'servico_oferecido_id': servicoOferecidoId,
    'endereco_id': enderecoId,
    'endereco_logradouro': enderecoLogradouro,
    'endereco_numero': enderecoNumero,
    'endereco_complemento': enderecoComplemento,
    'endereco_bairro': enderecoBairro,
    'endereco_cidade': enderecoCidade,
    'endereco_estado': enderecoEstado,
    'endereco_cep': enderecoCep,
    'hora_inicio': horaInicio.toIso8601String(),
    'hora_fim': horaFim.toIso8601String(),
  };
}
