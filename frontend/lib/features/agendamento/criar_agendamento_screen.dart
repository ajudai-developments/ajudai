import 'package:flutter/material.dart';
import 'package:shared/shared.dart';

import '../../core/errors/erro_mapper.dart';
import '../../core/ws/ws_message_stream.dart';
import '../../core/routes/app_routes.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/error_banner.dart';
import '../endereco/endereco_repository.dart';
import 'agendamento_repository.dart';
import 'criar_agendamento_args.dart';
import 'confirmar_pagamento_args.dart';
import 'widgets/cartao_selecao.dart';
import 'widgets/modal_selecionar_horario.dart';

/// Tela de criação de agendamento.
///
/// A escolha de data/horário fica num bottom sheet (ver
/// modal_selecionar_horario.dart) pra manter a tela principal enxuta —
/// aqui só aparece um resumo tocável do que foi escolhido. A grade de
/// horários do modal já vem com os intervalos ocupados do prestador
/// desabilitados, incluindo o caso de um intervalo "cobrir" um
/// agendamento existente.
class CriarAgendamentoScreen extends StatefulWidget {
  const CriarAgendamentoScreen({super.key});

  @override
  State<CriarAgendamentoScreen> createState() => _CriarAgendamentoScreenState();
}

const _horaMinima = 7;
const _horaMaxima = 23;
const _passoMinutos = 10;
const _diasFuturos = 30;

class _CriarAgendamentoScreenState extends State<CriarAgendamentoScreen> {
  final _enderecoRepository = EnderecoRepository();
  final _agendamentoRepository = AgendamentoRepository();

  late String _servicoOferecidoId;
  late String _prestadorId;
  bool _argumentosCarregados = false;

  bool _carregandoDadosIniciais = true;
  String? _erroCarregamento;
  List<Endereco> _enderecos = [];
  Endereco? _enderecoSelecionado;
  List<HorarioOcupado> _horariosOcupados = [];

  late DateTime _diaSelecionado;
  DateTime? _horaInicio;
  DateTime? _horaFim;

  bool _enviando = false;
  String? _erroGeral;

  @override
  void initState() {
    super.initState();
    final hoje = DateTime.now();
    _diaSelecionado = DateTime(hoje.year, hoje.month, hoje.day);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_argumentosCarregados) return;
    _argumentosCarregados = true;

    final args =
        ModalRoute.of(context)!.settings.arguments as CriarAgendamentoArgs;
    _servicoOferecidoId = args.servicoOferecidoId;
    _prestadorId = args.prestadorId;
    _carregarDadosIniciais();
  }

  Future<void> _carregarDadosIniciais() async {
    setState(() {
      _carregandoDadosIniciais = true;
      _erroCarregamento = null;
    });

    try {
      final resultados = await Future.wait([
        _enderecoRepository.obterMeusEnderecos(),
        _agendamentoRepository.listarHorariosOcupados(_prestadorId),
      ]);
      setState(() {
        _enderecos = resultados[0] as List<Endereco>;
        _enderecoSelecionado = _enderecos.isNotEmpty ? _enderecos.first : null;
        _horariosOcupados = resultados[1] as List<HorarioOcupado>;
      });
    } on WsErroException catch (e) {
      setState(() {
        _erroCarregamento = ErroMapper.paraMensagem(
          e.codigo,
          mensagemServidor: e.mensagem,
        );
      });
    } on WsTimeoutException {
      setState(() => _erroCarregamento = 'Não foi possível carregar os dados.');
    } finally {
      if (mounted) setState(() => _carregandoDadosIniciais = false);
    }
  }

  Future<void> _cadastrarNovoEndereco() async {
    final resultado = await Navigator.of(
      context,
    ).pushNamed(AppRoutes.formEndereco);
    if (resultado == true) _carregarDadosIniciais();
  }

  Future<void> _abrirSeletorHorario() async {
    final resultado = await abrirModalSelecionarHorario(
      context: context,
      diaInicial: _diaSelecionado,
      horaInicioInicial: _horaInicio,
      horaFimInicial: _horaFim,
      horariosOcupados: _horariosOcupados,
      diasFuturos: _diasFuturos,
      horaMinima: _horaMinima,
      horaMaxima: _horaMaxima,
      passoMinutos: _passoMinutos,
    );
    if (resultado == null || !mounted) return;
    setState(() {
      _diaSelecionado = resultado.dia;
      _horaInicio = resultado.horaInicio;
      _horaFim = resultado.horaFim;
    });
  }

  String _resumoHorario() {
    if (_horaInicio == null || _horaFim == null) {
      return 'Escolher data e horário';
    }
    final data =
        '${_diaSelecionado.day.toString().padLeft(2, '0')}/'
        '${_diaSelecionado.month.toString().padLeft(2, '0')}';
    String h(DateTime d) =>
        '${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';
    return '$data · ${h(_horaInicio!)} às ${h(_horaFim!)}';
  }

  Future<void> _continuar() async {
    final endereco = _enderecoSelecionado;
    final inicioLocal = _horaInicio;
    final fimLocal = _horaFim;

    if (endereco == null) {
      setState(() => _erroGeral = 'Selecione um endereço.');
      return;
    }
    if (inicioLocal == null || fimLocal == null) {
      setState(() => _erroGeral = 'Selecione o horário de início e término.');
      return;
    }

    final horaInicioUtc = inicioLocal.toUtc();
    final horaFimUtc = fimLocal.toUtc();

    try {
      AgendamentoValidator.validar(
        agoraUtc: DateTime.now().toUtc(),
        horaInicioUtc: horaInicioUtc,
        horaFimUtc: horaFimUtc,
      );
    } on ArgumentError catch (e) {
      setState(() => _erroGeral = e.message as String);
      return;
    }

    setState(() {
      _enviando = true;
      _erroGeral = null;
    });

    try {
      final preview = await _agendamentoRepository.criarAgendamento(
        prestadorId: _prestadorId,
        servicoOferecidoId: _servicoOferecidoId,
        enderecoId: endereco.id,
        horaInicio: horaInicioUtc,
        horaFim: horaFimUtc,
      );

      if (!mounted) return;
      Navigator.of(context).pushNamed(
        AppRoutes.confirmarPagamento,
        arguments: ConfirmarPagamentoArgs(
          preview: preview,
          prestadorId: _prestadorId,
          enderecoId: endereco.id,
          horaInicio: horaInicioUtc,
          horaFim: horaFimUtc,
        ),
      );
    } on WsErroException catch (e) {
      setState(() {
        _erroGeral = ErroMapper.paraMensagem(
          e.codigo,
          mensagemServidor: e.mensagem,
        );
      });
    } on WsTimeoutException {
      setState(() {
        _erroGeral = 'Não foi possível conectar ao servidor. Tente novamente.';
      });
    } finally {
      if (mounted) setState(() => _enviando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Novo agendamento')),
      body: _carregandoDadosIniciais
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    ErrorBanner(mensagem: _erroGeral ?? _erroCarregamento),
                    Text(
                      'Detalhes do agendamento',
                      style: AppTextStyles.titulo,
                    ),
                    const SizedBox(height: 12),
                    if (_enderecos.isEmpty)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Você ainda não tem endereços cadastrados.',
                            style: AppTextStyles.corpo,
                          ),
                          const SizedBox(height: 8),
                          OutlinedButton(
                            onPressed: _cadastrarNovoEndereco,
                            child: const Text('Cadastrar endereço'),
                          ),
                        ],
                      )
                    else
                      CartaoSelecao(
                        icone: Icons.location_on_outlined,
                        titulo: 'Endereço',
                        valor: _enderecoSelecionado == null
                            ? 'Selecionar endereço'
                            : '${_enderecoSelecionado!.nome} — '
                                  '${_enderecoSelecionado!.logradouro}, '
                                  '${_enderecoSelecionado!.numero}',
                        preenchido: _enderecoSelecionado != null,
                        onTap: () => _mostrarSeletorEndereco(context),
                      ),
                    const SizedBox(height: 12),
                    CartaoSelecao(
                      icone: Icons.calendar_today_outlined,
                      titulo: 'Data e horário',
                      valor: _resumoHorario(),
                      preenchido: _horaInicio != null && _horaFim != null,
                      onTap: _abrirSeletorHorario,
                    ),
                    const SizedBox(height: 28),
                    AppButton(
                      label: 'Continuar',
                      loading: _enviando,
                      onPressed:
                          _enderecos.isEmpty ||
                              _enderecoSelecionado == null ||
                              _horaInicio == null ||
                              _horaFim == null
                          ? null
                          : _continuar,
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Future<void> _mostrarSeletorEndereco(BuildContext context) async {
    final escolhido = await showModalBottomSheet<Endereco>(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                'Escolha o endereço',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            for (final endereco in _enderecos)
              ListTile(
                title: Text(endereco.nome),
                subtitle: Text('${endereco.logradouro}, ${endereco.numero}'),
                onTap: () => Navigator.of(context).pop(endereco),
              ),
          ],
        ),
      ),
    );
    if (escolhido != null) setState(() => _enderecoSelecionado = escolhido);
  }
}
