import 'package:shared/shared.dart';
import 'package:shared/src/models/enums/categoria_notificacao.dart';

class NotificacaoDto implements WsMessage {
  final String? id;
  final String titulo;
  final String mensagem;
  final CategoriaNotificacao categoria;
  final Map<String, dynamic>? dados;

  NotificacaoDto({
    this.id,
    required this.titulo,
    required this.mensagem,
    this.categoria = CategoriaNotificacao.geral,
    this.dados,
  });

  @override
  TipoMensagem get tipo => TipoMensagem.notificacao;

  factory NotificacaoDto.fromJson(Map<String, dynamic> json) {
    return NotificacaoDto(
      id: JsonUtils.optionalString(json, 'id'),
      titulo: JsonUtils.requireString(json, 'titulo'),
      mensagem: JsonUtils.requireString(json, 'mensagem'),
      categoria: CategoriaNotificacao.fromValor(
        JsonUtils.optionalString(json, 'categoria') ?? '',
      ),
      dados: JsonUtils.optionalMap(json, 'dados'),
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    if (id != null) 'id': id,
    'tipo': tipo.valor,
    'titulo': titulo,
    'mensagem': mensagem,
    'categoria': categoria.valor,
    if (dados != null) 'dados': dados,
  };
}
