import 'package:flutter/material.dart';
import 'package:shared/shared.dart';
import 'package:url_launcher/url_launcher.dart';

import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

/// Container branco arredondado com borda — o "card" de seção reutilizado
/// nas telas de detalhe. Aceita uma cor de fundo alternativa (ex: verde
/// suave pra destacar uma resposta positiva da equipe).
class SecaoCard extends StatelessWidget {
  final Widget child;
  final Color? corFundo;

  const SecaoCard({super.key, required this.child, this.corFundo});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: corFundo ?? AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.outline),
      ),
      child: child,
    );
  }
}

/// Linha "rótulo à esquerda, valor à direita" dentro de um [SecaoCard].
class LinhaInfo extends StatelessWidget {
  final String label;
  final String valor;

  const LinhaInfo({super.key, required this.label, required this.valor});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(label, style: AppTextStyles.legenda),
        const Spacer(),
        Text(
          valor,
          style: AppTextStyles.corpo.copyWith(fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}

/// Grade de anexos (fotos/vídeos/áudios/documentos) de uma denúncia ou
/// contestação.
///
/// [arquivos] (metadados, com o [TipoArquivo] de cada um) e [urls] (os
/// links, na mesma ordem) vêm de listas paralelas do backend — por isso
/// são combinadas aqui por índice. Se as listas vierem com tamanhos
/// diferentes (não deveria acontecer, mas por segurança), usa o menor
/// tamanho entre as duas em vez de estourar índice.
///
/// Imagem: miniatura de verdade via Image.network. Vídeo, áudio e
/// documento: ícone + extensão, sem tentar carregar como imagem (evita o
/// "flash" de erro de rede que acontecia antes, quando qualquer URL era
/// tratada como possível imagem).
class GradeAnexos extends StatelessWidget {
  final List<ArquivoAnexado> arquivos;
  final List<String?> urls;

  const GradeAnexos({super.key, required this.arquivos, required this.urls});

  @override
  Widget build(BuildContext context) {
    final quantidade = arquivos.length < urls.length
        ? arquivos.length
        : urls.length;
    if (quantidade == 0) return const SizedBox.shrink();

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
      ),
      itemCount: quantidade,
      itemBuilder: (context, index) {
        final arquivo = arquivos[index];
        final url = urls[index];
        return _MiniaturaAnexo(arquivo: arquivo, url: url);
      },
    );
  }
}

class _MiniaturaAnexo extends StatelessWidget {
  final ArquivoAnexado arquivo;
  final String? url;

  const _MiniaturaAnexo({required this.arquivo, required this.url});

  IconData get _icone {
    switch (arquivo.tipo) {
      case TipoArquivo.video:
        return Icons.play_circle_fill_rounded;
      case TipoArquivo.audio:
        return Icons.audiotrack_rounded;
      case TipoArquivo.documento:
        return Icons.description_rounded;
      case TipoArquivo.imagem:
        return Icons.image_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final ehImagem = arquivo.tipo == TipoArquivo.imagem;
    final podeAbrir = url != null;

    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: podeAbrir ? () => _abrir(context) : null,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Container(
          color: AppColors.surfaceAlt,
          child: ehImagem && podeAbrir
              ? Image.network(
                  url!,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => _placeholder(),
                )
              : _placeholder(),
        ),
      ),
    );
  }

  Widget _placeholder() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(_icone, color: AppColors.textoSecundario, size: 26),
          const SizedBox(height: 4),
          Text(
            arquivo.extensaoInferida.toUpperCase(),
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: AppColors.textoSecundario,
            ),
          ),
        ],
      ),
    );
  }

  void _abrir(BuildContext context) {
    final ehImagem = arquivo.tipo == TipoArquivo.imagem;

    if (ehImagem) {
      showDialog<void>(
        context: context,
        builder: (context) => Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.all(16),
          child: GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: InteractiveViewer(
              child: Image.network(
                url!,
                errorBuilder: (context, error, stackTrace) => Container(
                  padding: const EdgeInsets.all(32),
                  color: Colors.white,
                  child: const Icon(Icons.broken_image_rounded, size: 48),
                ),
              ),
            ),
          ),
        ),
      );
      return;
    }

    // Vídeo/áudio/documento: sem player embutido nesta tela ainda — abre
    // a URL no navegador/app externo do dispositivo.
    _abrirUrlExterna(context, url!);
  }

  Future<void> _abrirUrlExterna(BuildContext context, String url) async {
    final uri = Uri.tryParse(url);
    if (uri == null) return;

    final abriu = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!abriu && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Não foi possível abrir o arquivo.')),
      );
    }
  }
}
