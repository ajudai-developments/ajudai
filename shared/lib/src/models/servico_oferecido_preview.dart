import 'package:shared/src/dto/json_utils.dart';

/// Card resumido de um serviço oferecido, para telas de listagem/busca.
/// A visão detalhada (perfil completo) fica em ObterServicoOferecidoResponseDto.
class ServicoOferecidoPreview {
  final String servicoOferecidoId;
  final String servicoNome;
  final String categoriaNome;
  final double valor;
  final String prestadorId;
  final String prestadorNome;
  final bool prestadorVerificado;
  final double? mediaAvaliacao;
  final int quantidadeAvaliacoes;
  final int quantidadeSelos;

  ServicoOferecidoPreview({
    required this.servicoOferecidoId,
    required this.servicoNome,
    required this.categoriaNome,
    required this.valor,
    required this.prestadorId,
    required this.prestadorNome,
    required this.prestadorVerificado,
    this.mediaAvaliacao,
    required this.quantidadeAvaliacoes,
    required this.quantidadeSelos,
  });

  factory ServicoOferecidoPreview.fromJson(Map<String, dynamic> json) {
    return ServicoOferecidoPreview(
      servicoOferecidoId: JsonUtils.requireString(
        json,
        'servico_oferecido_id',
      ),
      servicoNome: JsonUtils.requireString(json, 'servico_nome'),
      categoriaNome: JsonUtils.requireString(json, 'categoria_nome'),
      valor: JsonUtils.requireDouble(json, 'valor'),
      prestadorId: JsonUtils.requireString(json, 'prestador_id'),
      prestadorNome: JsonUtils.requireString(json, 'prestador_nome'),
      prestadorVerificado: JsonUtils.requireBool(
        json,
        'prestador_verificado',
      ),
      mediaAvaliacao: JsonUtils.optionalDouble(json, 'media_avaliacao'),
      quantidadeAvaliacoes: JsonUtils.requireInt(
        json,
        'quantidade_avaliacoes',
      ),
      quantidadeSelos: JsonUtils.requireInt(json, 'quantidade_selos'),
    );
  }

  Map<String, dynamic> toJson() => {
    'servico_oferecido_id': servicoOferecidoId,
    'servico_nome': servicoNome,
    'categoria_nome': categoriaNome,
    'valor': valor,
    'prestador_id': prestadorId,
    'prestador_nome': prestadorNome,
    'prestador_verificado': prestadorVerificado,
    'media_avaliacao': mediaAvaliacao,
    'quantidade_avaliacoes': quantidadeAvaliacoes,
    'quantidade_selos': quantidadeSelos,
  };
}
