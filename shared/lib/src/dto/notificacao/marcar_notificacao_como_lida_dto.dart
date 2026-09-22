import '../tipo_mensagem.dart';
import '../ws_message.dart';
import '../json_utils.dart';

class MarcarNotificacaoComoLidaRequestDto implements WsMessage {
	final String notificacaoId;

	const MarcarNotificacaoComoLidaRequestDto({required this.notificacaoId});

	@override
	TipoMensagem get tipo => TipoMensagem.marcarNotificacaoComoLida;

	factory MarcarNotificacaoComoLidaRequestDto.fromJson(
		Map<String, dynamic> json,
	) {
		return MarcarNotificacaoComoLidaRequestDto(
			notificacaoId: JsonUtils.requireString(json, 'notificacao_id'),
		);
	}

	@override
	Map<String, dynamic> toJson() => {
		'tipo': tipo.valor,
		'notificacao_id': notificacaoId,
	};
}

class MarcarNotificacaoComoLidaResponseDto implements WsMessage {
	const MarcarNotificacaoComoLidaResponseDto();

	@override
	TipoMensagem get tipo => TipoMensagem.marcarNotificacaoComoLidaOk;

	factory MarcarNotificacaoComoLidaResponseDto.fromJson(
		Map<String, dynamic> json,
	) {
		return const MarcarNotificacaoComoLidaResponseDto();
	}

	@override
	Map<String, dynamic> toJson() => {'tipo': tipo.valor};
}
