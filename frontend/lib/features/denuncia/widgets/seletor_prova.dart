import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared/shared.dart';

/// Limite de 30MB por arquivo — mesma regra do backend pra provas de
/// denúncia/contestação (foto ou vídeo).
const _limiteBytes = 30 * 1024 * 1024;

class ItemProva {
  final ArquivoUpload arquivo;
  final bool ehVideo;
  final String caminhoLocal; // só pra preview, não vai pro backend

  ItemProva({
    required this.arquivo,
    required this.ehVideo,
    required this.caminhoLocal,
  });
}

/// Seletor de provas (foto/vídeo). Mostra uma grade com o que já foi
/// selecionado + botão de adicionar, que abre um bottom sheet pra
/// escolher câmera/galeria e foto/vídeo.
class SeletorProvas extends StatefulWidget {
  final List<ItemProva> valor;
  final ValueChanged<List<ItemProva>> onChanged;
  final int maximo;

  const SeletorProvas({
    super.key,
    required this.valor,
    required this.onChanged,
    this.maximo = 5,
  });

  @override
  State<SeletorProvas> createState() => _SeletorProvasState();
}

class _SeletorProvasState extends State<SeletorProvas> {
  final _picker = ImagePicker();
  String? _erro;

  Future<void> _adicionar({
    required bool video,
    required ImageSource origem,
  }) async {
    setState(() => _erro = null);

    final XFile? arquivo = video
        ? await _picker.pickVideo(source: origem)
        : await _picker.pickImage(source: origem, imageQuality: 85);

    if (arquivo == null) return;

    final file = File(arquivo.path);
    final tamanho = await file.length();
    if (tamanho > _limiteBytes) {
      setState(() => _erro = 'Arquivo maior que 30MB. Escolha outro.');
      return;
    }

    final bytes = await file.readAsBytes();
    final extensao = arquivo.path.split('.').last;

    final item = ItemProva(
      arquivo: ArquivoUpload(
        nomeOriginal: arquivo.name,
        extensao: extensao,
        bytesBase64: base64Encode(bytes),
      ),
      ehVideo: video,
      caminhoLocal: arquivo.path,
    );

    widget.onChanged([...widget.valor, item]);
  }

  void _remover(int index) {
    final novaLista = List.of(widget.valor)..removeAt(index);
    widget.onChanged(novaLista);
  }

  void _abrirSeletor() {
    if (widget.valor.length >= widget.maximo) {
      setState(() => _erro = 'Máximo de ${widget.maximo} arquivos.');
      return;
    }
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.photo_camera_outlined),
              title: const Text('Tirar foto'),
              onTap: () {
                Navigator.of(context).pop();
                _adicionar(video: false, origem: ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.videocam_outlined),
              title: const Text('Gravar vídeo'),
              onTap: () {
                Navigator.of(context).pop();
                _adicionar(video: true, origem: ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.image_outlined),
              title: const Text('Escolher foto da galeria'),
              onTap: () {
                Navigator.of(context).pop();
                _adicionar(video: false, origem: ImageSource.gallery);
              },
            ),
            ListTile(
              leading: const Icon(Icons.video_library_outlined),
              title: const Text('Escolher vídeo da galeria'),
              onTap: () {
                Navigator.of(context).pop();
                _adicionar(video: true, origem: ImageSource.gallery);
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Provas (opcional)',
          style: Theme.of(context).textTheme.labelLarge,
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (var i = 0; i < widget.valor.length; i++)
              _buildMiniatura(widget.valor[i], () => _remover(i)),
            if (widget.valor.length < widget.maximo)
              _buildBotaoAdicionar(scheme),
          ],
        ),
        if (_erro != null) ...[
          const SizedBox(height: 6),
          Text(_erro!, style: TextStyle(color: scheme.error, fontSize: 12)),
        ],
      ],
    );
  }

  Widget _buildMiniatura(ItemProva item, VoidCallback onRemover) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: 72,
          height: 72,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: Colors.black12,
            image: item.ehVideo
                ? null
                : DecorationImage(
                    image: FileImage(File(item.caminhoLocal)),
                    fit: BoxFit.cover,
                  ),
          ),
          child: item.ehVideo
              ? const Icon(
                  Icons.play_circle_fill_rounded,
                  color: Colors.white70,
                  size: 28,
                )
              : null,
        ),
        Positioned(
          top: -6,
          right: -6,
          child: GestureDetector(
            onTap: onRemover,
            child: Container(
              padding: const EdgeInsets.all(2),
              decoration: const BoxDecoration(
                color: Colors.black87,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.close_rounded,
                size: 14,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBotaoAdicionar(ColorScheme scheme) {
    return GestureDetector(
      onTap: _abrirSeletor,
      child: Container(
        width: 72,
        height: 72,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: scheme.outlineVariant),
        ),
        child: Icon(Icons.add_rounded, color: scheme.onSurfaceVariant),
      ),
    );
  }
}
