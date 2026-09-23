import 'package:shared/shared.dart';

class MensagemComUrl {
  final Mensagem mensagem;
  final String? urlArquivo;

  MensagemComUrl({required this.mensagem, this.urlArquivo});

  Map<String, dynamic> toJson() => {
    ...mensagem.toJson(),
    'url_arquivo': urlArquivo,
  };
}
