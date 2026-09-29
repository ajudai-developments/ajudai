import 'package:ajudai/core/routes/app_routes.dart';
import 'package:ajudai/core/theme/app_colors.dart';
import 'package:ajudai/core/theme/app_text_styles.dart';
import 'package:ajudai/core/widgets/abas_chips_web.dart';
import 'package:ajudai/core/widgets/app_button.dart';
import 'package:ajudai/core/widgets/app_text_field.dart';
import 'package:ajudai/core/widgets/error_banner.dart';
import 'package:ajudai/core/widgets/mestre_detalhe.dart';
import 'package:ajudai/core/widgets/secao_card.dart';
import 'package:ajudai/core/widgets/shell_admin.dart';
import 'package:ajudai/core/widgets/status_chip.dart';
import 'package:ajudai/core/widgets/status_timeline.dart';
import 'package:ajudai/core/widgets/tipo_denuncia_label.dart';
import 'package:ajudai/features/admin/widgets/admin_widgets.dart';
import 'package:flutter/material.dart';
import 'package:shared/shared.dart';

import 'admin_repository.dart';

class AdminDenunciasScreen extends StatefulWidget {
  const AdminDenunciasScreen({super.key});

  @override
  State<AdminDenunciasScreen> createState() => _AdminDenunciasScreenState();
}

class _AdminDenunciasScreenState extends State<AdminDenunciasScreen> {
  static const _abas = [
    'Abertas',
    'Em análise',
    'Resolvidas',
    'Rejeitadas',
    'Todas',
  ];
  static const _filtros = <StatusDenuncia?>[
    StatusDenuncia.aberta,
    StatusDenuncia.emAnalise,
    StatusDenuncia.resolvida,
    StatusDenuncia.rejeitada,
    null,
  ];

  final _repo = AdminRepository();
  int _aba = 0;

  @override
  Widget build(BuildContext context) {
    return ShellAdmin(
      titulo: 'Denúncias',
      rotaAtual: AppRoutes.adminDenuncias,
      child: MestreDetalhe<DenunciaAdminComUrls>(
        key: ValueKey(_aba),
        carregar: () => _repo.listarDenuncias(_filtros[_aba]),
        idDe: (item) => item.denuncia.id,
        aoAbrir: (item) async {
          if (item.denuncia.status != StatusDenuncia.aberta) return item;
          final novo = await _repo.marcarDenunciaEmAnalise(item.denuncia.id);
          return item.comStatus(novo);
        },
        mensagemVazio: 'Nenhuma denúncia nesta categoria.',
        filtros: AbasChipsWeb(
          abas: _abas,
          selecionada: _aba,
          onChanged: (i) => setState(() => _aba = i),
        ),
        itemBuilder: (context, item) {
          final d = item.denuncia;
          return Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      labelTipoDenuncia(d.tipo),
                      style: AppTextStyles.corpo.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppColors.textoTitulo,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Contra ${d.usuarioNome}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.legenda,
                    ),
                    Text(
                      formatarDataHora(d.denunciadoEm),
                      style: AppTextStyles.legenda,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              StatusChip(valor: d.status.valor),
            ],
          );
        },
        detalheBuilder: (context, item, recarregar) =>
            _DetalheDenuncia(item: item, aoAtualizar: recarregar),
      ),
    );
  }
}

class _DetalheDenuncia extends StatefulWidget {
  final DenunciaAdminComUrls item;
  final Future<void> Function() aoAtualizar;

  const _DetalheDenuncia({required this.item, required this.aoAtualizar});

  @override
  State<_DetalheDenuncia> createState() => _DetalheDenunciaState();
}

class _DetalheDenunciaState extends State<_DetalheDenuncia> {
  static const _statusPossiveis = [
    StatusDenuncia.emAnalise,
    StatusDenuncia.resolvida,
    StatusDenuncia.rejeitada,
  ];

  final _repo = AdminRepository();
  final _resposta = TextEditingController();
  StatusDenuncia _status = StatusDenuncia.resolvida;
  bool _removerPrestador = false;
  bool _banirUsuario = false;
  bool _enviando = false;
  String? _erro;
  String? _erroResposta;

  DenunciaComDetalhes get _d => widget.item.denuncia;
  bool get _emAberto =>
      _d.status == StatusDenuncia.aberta ||
      _d.status == StatusDenuncia.emAnalise;

  @override
  void dispose() {
    _resposta.dispose();
    super.dispose();
  }

  String _labelStatus(StatusDenuncia s) {
    switch (s) {
      case StatusDenuncia.aberta:
        return 'Aberta';
      case StatusDenuncia.emAnalise:
        return 'Em análise';
      case StatusDenuncia.resolvida:
        return 'Resolvida (denúncia procedente)';
      case StatusDenuncia.rejeitada:
        return 'Rejeitada (improcedente)';
    }
  }

  String _labelPapel(UserRole r) {
    switch (r) {
      case UserRole.cliente:
        return 'Cliente';
      case UserRole.prestador:
        return 'Prestador';
      case UserRole.admin:
        return 'Admin';
    }
  }

  Future<void> _enviar() async {
    final texto = _resposta.text.trim();
    if (texto.isEmpty) {
      setState(() => _erroResposta = 'Escreva uma resposta para as partes.');
      return;
    }

    // Punições só fazem sentido se a denúncia for procedente.
    final procedente = _status == StatusDenuncia.resolvida;

    final messenger = ScaffoldMessenger.of(context);
    setState(() {
      _enviando = true;
      _erro = null;
      _erroResposta = null;
    });
    try {
      await _repo.responderDenuncia(
        denunciaId: _d.id,
        status: _status,
        resposta: texto,
        removerPrestador: procedente && _removerPrestador,
        banirUsuario: procedente && _banirUsuario,
      );
      messenger.showSnackBar(
        const SnackBar(content: Text('Denúncia respondida.')),
      );
      await widget.aoAtualizar();
    } catch (e) {
      if (mounted) setState(() => _erro = mensagemDeErroWs(e));
    } finally {
      if (mounted) setState(() => _enviando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final d = _d;
    final ehPrestador = d.usuarioRole == UserRole.prestador;
    final procedente = _status == StatusDenuncia.resolvida;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CabecalhoDetalhe(
          titulo: labelTipoDenuncia(d.tipo),
          subtitulo: 'Registrada em ${formatarDataHora(d.denunciadoEm)}',
          trailing: StatusChip(valor: d.status.valor),
        ),
        SecaoAdmin(
          titulo: 'Envolvidos',
          child: BlocoInfo(
            linhas: [
              MapEntry('Denunciante', d.denunciadorNome),
              MapEntry('Denunciado', d.usuarioNome),
              MapEntry('Papel do denunciado', _labelPapel(d.usuarioRole)),
              if (ehPrestador)
                MapEntry(
                  'Situação como prestador',
                  d.usuarioStatusPrestador.toDbValue().replaceAll('_', ' '),
                ),
              MapEntry('Conta', d.usuarioBanido ? 'Banida' : 'Ativa'),
            ],
          ),
        ),
        SecaoAdmin(
          titulo: 'Descrição',
          child: SecaoCard(
            child: Text(d.descricao, style: AppTextStyles.corpo),
          ),
        ),
        if (d.arquivos.isNotEmpty)
          SecaoAdmin(
            titulo: 'Anexos (${d.arquivos.length})',
            child: GradeAnexos(
              arquivos: d.arquivos,
              urls: widget.item.urlsArquivos,
            ),
          ),
        SecaoAdmin(
          titulo: 'Andamento',
          child: SecaoCard(child: StatusTimeline(status: d.status.valor)),
        ),
        if (_emAberto)
          SecaoAdmin(
            titulo: 'Responder denúncia',
            child: SecaoCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  ErrorBanner(mensagem: _erro),
                  DropdownButtonFormField<StatusDenuncia>(
                    initialValue: _status,
                    decoration: const InputDecoration(labelText: 'Decisão'),
                    items: [
                      for (final s in _statusPossiveis)
                        DropdownMenuItem(
                          value: s,
                          child: Text(_labelStatus(s)),
                        ),
                    ],
                    onChanged: _enviando
                        ? null
                        : (s) => setState(() => _status = s ?? _status),
                  ),
                  const SizedBox(height: 16),
                  AppTextField(
                    label: 'Resposta para as partes',
                    controller: _resposta,
                    maxLines: 5,
                    minLines: 4,
                    erro: _erroResposta,
                    textCapitalization: TextCapitalization.sentences,
                  ),
                  if (procedente) ...[
                    const SizedBox(height: 8),
                    if (ehPrestador)
                      SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        activeThumbColor: AppColors.primary,
                        title: const Text('Remover como prestador'),
                        subtitle: const Text(
                          'O usuário deixa de oferecer serviços.',
                        ),
                        value: _removerPrestador,
                        onChanged: _enviando
                            ? null
                            : (v) => setState(() => _removerPrestador = v),
                      ),
                    if (!d.usuarioBanido)
                      SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        activeThumbColor: AppColors.primary,
                        title: const Text('Banir usuário'),
                        subtitle: const Text('Bloqueia o acesso à conta.'),
                        value: _banirUsuario,
                        onChanged: _enviando
                            ? null
                            : (v) => setState(() => _banirUsuario = v),
                      ),
                  ],
                  const SizedBox(height: 16),
                  Align(
                    alignment: Alignment.centerRight,
                    child: SizedBox(
                      width: 220,
                      child: AppButton(
                        label: 'Enviar resposta',
                        loading: _enviando,
                        onPressed: _enviar,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          )
        else
          SecaoAdmin(
            titulo: 'Resposta da equipe',
            child: SecaoCard(
              corFundo: d.status == StatusDenuncia.resolvida
                  ? AppColors.successSoft
                  : null,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(d.respostaAdmin ?? '—', style: AppTextStyles.corpo),
                  if (d.removeuPrestador || d.baniuUsuario) ...[
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      children: [
                        if (d.removeuPrestador)
                          const ChipAdmin(
                            label: 'Prestador removido',
                            cor: AppColors.error,
                          ),
                        if (d.baniuUsuario)
                          const ChipAdmin(
                            label: 'Usuário banido',
                            cor: AppColors.error,
                          ),
                      ],
                    ),
                  ],
                  if (d.respondidoEm != null) ...[
                    const SizedBox(height: 10),
                    Text(
                      'Respondida em ${formatarDataHora(d.respondidoEm!)}',
                      style: AppTextStyles.legenda,
                    ),
                  ],
                ],
              ),
            ),
          ),
      ],
    );
  }
}
