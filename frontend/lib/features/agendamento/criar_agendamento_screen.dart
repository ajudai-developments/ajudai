import 'package:ajudai/core/ws/ws_message_stream.dart';
import 'package:flutter/material.dart';
import 'package:shared/shared.dart';

import '../../core/errors/erro_mapper.dart';
import '../../core/routes/app_routes.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/error_banner.dart';
import '../endereco/endereco_repository.dart';
import 'agendamento_repository.dart';
import 'confirmar_pagamento_args.dart';

/// Tela de criação de agendamento.
///
/// Recebe `servicoOferecidoId` (String) via argumento da rota. Deixa o
/// usuário escolher um endereço já cadastrado, data e horário, valida
/// tudo com AgendamentoValidator (do shared) e, se passar, chama
/// AgendamentoRepository.criarAgendamento pra gerar o preview — que é
/// repassado pra confirmar_pagamento_screen junto dos parâmetros
/// originais (ver ConfirmarPagamentoArgs).
class CriarAgendamentoScreen extends StatefulWidget {
  const CriarAgendamentoScreen({super.key});

  @override
  State<CriarAgendamentoScreen> createState() => _CriarAgendamentoScreenState();
}

class _CriarAgendamentoScreenState extends State<CriarAgendamentoScreen> {
  final _enderecoRepository = EnderecoRepository();
  final _agendamentoRepository = AgendamentoRepository();

  late String _servicoOferecidoId;
  bool _argumentosCarregados = false;

  bool _carregandoEnderecos = true;
  String? _erroEnderecos;
  List<Endereco> _enderecos = [];
  Endereco? _enderecoSelecionado;

  DateTime? _data;
  TimeOfDay? _horaInicio;
  TimeOfDay? _horaFim;

  bool _enviando = false;
  String? _erroGeral;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_argumentosCarregados) return;
    _argumentosCarregados = true;

    _servicoOferecidoId = ModalRoute.of(context)!.settings.arguments as String;
    _carregarEnderecos();
  }

  Future<void> _carregarEnderecos() async {
    setState(() {
      _carregandoEnderecos = true;
      _erroEnderecos = null;
    });

    try {
      final enderecos = await _enderecoRepository.obterMeusEnderecos();
      setState(() {
        _enderecos = enderecos;
        _enderecoSelecionado = enderecos.isNotEmpty ? enderecos.first : null;
      });
    } on WsErroException catch (e) {
      setState(() {
        _erroEnderecos = ErroMapper.paraMensagem(e.codigo, mensagemServidor: e.mensagem);
      });
    } on WsTimeoutException {
      setState(() => _erroEnderecos = 'Não foi possível carregar seus endereços.');
    } finally {
      if (mounted) setState(() => _carregandoEnderecos = false);
    }
  }

  Future<void> _cadastrarNovoEndereco() async {
    final resultado = await Navigator.of(context).pushNamed(AppRoutes.formEndereco);
    if (resultado == true) _carregarEnderecos();
  }

  Future<void> _selecionarData() async {
    final agora = DateTime.now();
    final escolhida = await showDatePicker(
      context: context,
      initialDate: _data ?? agora,
      firstDate: agora,
      lastDate: agora.add(const Duration(days: 30)),
    );
    if (escolhida != null) setState(() => _data = escolhida);
  }

  Future<void> _selecionarHora({required bool inicio}) async {
    final escolhida = await showTimePicker(
      context: context,
      initialTime: (inicio ? _horaInicio : _horaFim) ?? TimeOfDay.now(),
    );
    if (escolhida == null) return;
    setState(() {
      if (inicio) {
        _horaInicio = escolhida;
      } else {
        _horaFim = escolhida;
      }
    });
  }

  DateTime? _combinar(TimeOfDay? hora) {
    if (_data == null || hora == null) return null;
    return DateTime(_data!.year, _data!.month, _data!.day, hora.hour, hora.minute);
  }

  Future<void> _continuar() async {
    final endereco = _enderecoSelecionado;
    final inicioLocal = _combinar(_horaInicio);
    final fimLocal = _combinar(_horaFim);

    if (endereco == null) {
      setState(() => _erroGeral = 'Selecione um endereço.');
      return;
    }
    if (inicioLocal == null || fimLocal == null) {
      setState(() => _erroGeral = 'Selecione data e horário de início e fim.');
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
          enderecoId: endereco.id,
          horaInicio: horaInicioUtc,
          horaFim: horaFimUtc,
        ),
      );
    } on WsErroException catch (e) {
      setState(() {
        _erroGeral = ErroMapper.paraMensagem(e.codigo, mensagemServidor: e.mensagem);
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
      body: _carregandoEnderecos
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    ErrorBanner(mensagem: _erroGeral ?? _erroEnderecos),
                    Text('Endereço', style: AppTextStyles.titulo),
                    const SizedBox(height: 8),
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
                      DropdownButtonFormField<Endereco>(
                        initialValue: _enderecoSelecionado,
                        items: [
                          for (final endereco in _enderecos)
                            DropdownMenuItem(
                              value: endereco,
                              child: Text('${endereco.nome} — ${endereco.logradouro}, ${endereco.numero}'),
                            ),
                        ],
                        onChanged: (endereco) => setState(() => _enderecoSelecionado = endereco),
                      ),
                    const SizedBox(height: 24),
                    Text('Data e horário', style: AppTextStyles.titulo),
                    const SizedBox(height: 8),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(_data == null
                          ? 'Selecionar data'
                          : '${_data!.day.toString().padLeft(2, '0')}/'
                              '${_data!.month.toString().padLeft(2, '0')}/'
                              '${_data!.year}'),
                      trailing: const Icon(Icons.calendar_today),
                      onTap: _selecionarData,
                    ),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(_horaInicio == null
                          ? 'Horário de início'
                          : 'Início: ${_horaInicio!.format(context)}'),
                      trailing: const Icon(Icons.access_time),
                      onTap: () => _selecionarHora(inicio: true),
                    ),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(_horaFim == null
                          ? 'Horário de término'
                          : 'Término: ${_horaFim!.format(context)}'),
                      trailing: const Icon(Icons.access_time),
                      onTap: () => _selecionarHora(inicio: false),
                    ),
                    const SizedBox(height: 24),
                    AppButton(
                      label: 'Continuar',
                      loading: _enviando,
                      onPressed: _enderecos.isEmpty ? null : _continuar,
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}