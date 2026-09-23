import 'package:shared/shared.dart';

class MensagemComUrl {
  final Mensagem mensagem;
  final String? urlArquivo;

  MensagemComUrl({required this.mensagem, this.urlArquivo});

  factory MensagemComUrl.fromJson(Map<String, dynamic> json) {
    return MensagemComUrl(
      mensagem: Mensagem.fromMap(json),
      urlArquivo: JsonUtils.optionalString(json, 'url_arquivo'),
    );
  }

  Map<String, dynamic> toJson() => {
    ...mensagem.toJson(),
    'url_arquivo': urlArquivo,
  };
}
