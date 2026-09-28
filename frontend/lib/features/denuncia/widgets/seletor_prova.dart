import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared/shared.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

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

/// Seletor de provas (foto/vídeo): grade com o que já foi selecionado +
/// botão de adicionar, que abre um bottom sheet com câmera/galeria.
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
      if (mounted) {
        setState(() => _erro = 'Arquivo maior que 30MB. Escolha outro.');
      }
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

    showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.surface,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (sheetContext) {
        void escolher(bool video, ImageSource origem) {
          Navigator.of(sheetContext).pop();
          _adicionar(video: video, origem: origem);
        }

        return SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.outline,
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Text('Adicionar prova', style: AppTextStyles.titulo),
                const SizedBox(height: 8),
                _OpcaoSheet(
                  icone: Icons.photo_camera_outlined,
                  rotulo: 'Tirar foto',
                  onTap: () => escolher(false, ImageSource.camera),
                ),
                _OpcaoSheet(
                  icone: Icons.videocam_outlined,
                  rotulo: 'Gravar vídeo',
                  onTap: () => escolher(true, ImageSource.camera),
                ),
                _OpcaoSheet(
                  icone: Icons.image_outlined,
                  rotulo: 'Foto da galeria',
                  onTap: () => escolher(false, ImageSource.gallery),
                ),
                _OpcaoSheet(
                  icone: Icons.video_library_outlined,
                  rotulo: 'Vídeo da galeria',
                  onTap: () => escolher(true, ImageSource.gallery),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text('Provas', style: AppTextStyles.titulo),
            const SizedBox(width: 6),
            Text('(opcional)', style: AppTextStyles.legenda),
            const Spacer(),
            Text(
              '${widget.valor.length}/${widget.maximo}',
              style: AppTextStyles.legenda,
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          'Fotos e vídeos ajudam nossa equipe a analisar mais rápido.',
          style: AppTextStyles.legenda,
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            for (var i = 0; i < widget.valor.length; i++)
              _Miniatura(item: widget.valor[i], onRemover: () => _remover(i)),
            if (widget.valor.length < widget.maximo)
              _BotaoAdicionar(onTap: _abrirSeletor),
          ],
        ),
        if (_erro != null) ...[
          const SizedBox(height: 8),
          Text(
            _erro!,
            style: AppTextStyles.legenda.copyWith(color: AppColors.error),
          ),
        ],
      ],
    );
  }
}

class _OpcaoSheet extends StatelessWidget {
  final IconData icone;
  final String rotulo;
  final VoidCallback onTap;

  const _OpcaoSheet({
    required this.icone,
    required this.rotulo,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: const BoxDecoration(
                color: AppColors.primarySoft,
                shape: BoxShape.circle,
              ),
              child: Icon(icone, color: AppColors.primary, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                rotulo,
                style: AppTextStyles.corpo.copyWith(
                  fontSize: 15,
                  color: AppColors.textoTitulo,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const Icon(
              Icons.chevron_right_rounded,
              color: AppColors.textoSecundario,
            ),
          ],
        ),
      ),
    );
  }
}

class _Miniatura extends StatelessWidget {
  final ItemProva item;
  final VoidCallback onRemover;

  const _Miniatura({required this.item, required this.onRemover});

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: Container(
            width: 84,
            height: 84,
            decoration: BoxDecoration(
              color: item.ehVideo
                  ? AppColors.textoTitulo
                  : AppColors.surfaceAlt,
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
                    color: Colors.white,
                    size: 32,
                  )
                : null,
          ),
        ),
        Positioned(
          top: -6,
          right: -6,
          child: GestureDetector(
            onTap: onRemover,
            child: Container(
              padding: const EdgeInsets.all(3),
              decoration: BoxDecoration(
                color: AppColors.textoTitulo,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.surface, width: 2),
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
}

class _BotaoAdicionar extends StatelessWidget {
  final VoidCallback onTap;
  const _BotaoAdicionar({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: onTap,
      child: Container(
        width: 84,
        height: 84,
        decoration: BoxDecoration(
          color: AppColors.surfaceAlt,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.outline),
        ),
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.add_photo_alternate_outlined,
              color: AppColors.primary,
              size: 26,
            ),
            SizedBox(height: 4),
            Text(
              'Adicionar',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
