import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';


import '../../core/errors/erro_mapper.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/error_banner.dart';
import '../../core/ws/ws_message_stream.dart';
import 'prestador_repository.dart';

/// Tela de solicitação para virar prestador.
///
/// Além do pedido em si (SolicitarPrestadorRequestDto não tem nenhum
/// campo), exige 3 consentimentos explícitos e a permissão de
/// localização do dispositivo — em preparação para o rastreamento de
/// atividade durante o serviço (feature futura, ainda sem backend).
///
/// IMPORTANTE — isso é só a permissão do SISTEMA OPERACIONAL, não tem
/// nenhuma ligação com o backend ainda: `SolicitarPrestadorRequestDto`
/// não tem campo de localização, então hoje a gente só GARANTE que a
/// permissão já está concedida antes de deixar a pessoa virar
/// prestador — não enviamos nem armazenamos nenhuma coordenada. Quando
/// o rastreamento de verdade for implementado (durante um agendamento
/// em andamento), vai ser preciso: (1) o pacote `geolocator` pra ler a
/// posição em si (`permission_handler` só cuida da permissão), e (2)
/// muito provavelmente `Permission.locationAlways` em vez de
/// `locationWhenInUse` — que é um pedido de permissão SEPARADO e mais
/// invasivo (o app te rastreia mesmo em segundo plano), com telas de
/// consentimento adicionais exigidas pelas lojas (Google Play/App
/// Store) e configuração extra de plataforma. Pedimos só
/// `locationWhenInUse` aqui por enquanto.
///
/// Setup de plataforma necessário (fora do código Dart) pra isso
/// funcionar, e que eu não posso fazer por aqui:
/// - Android: `<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />`
///   em `android/app/src/main/AndroidManifest.xml`.
/// - iOS: chave `NSLocationWhenInUseUsageDescription` em `ios/Runner/Info.plist`
///   com o texto que aparece pro usuário explicando o motivo do pedido.
/// - `pubspec.yaml`: adicionar `permission_handler: ^12.0.1`.
class SolicitarPrestadorScreen extends StatefulWidget {
  const SolicitarPrestadorScreen({super.key});

  @override
  State<SolicitarPrestadorScreen> createState() => _SolicitarPrestadorScreenState();
}

class _SolicitarPrestadorScreenState extends State<SolicitarPrestadorScreen> {
  final _prestadorRepository = PrestadorRepository();

  bool _aceitaRastreamento = false;
  bool _aceitaResponsabilidade = false;
  bool _aceitaPoliticaSuspensao = false;

  bool _enviando = false;
  String? _erro;

  bool get _podeConfirmar =>
      _aceitaRastreamento && _aceitaResponsabilidade && _aceitaPoliticaSuspensao;

  Future<void> _solicitar() async {
    setState(() {
      _enviando = true;
      _erro = null;
    });

    try {
      final permissaoOk = await _garantirPermissaoLocalizacao();
      if (!permissaoOk) return;

      await _prestadorRepository.solicitarPrestador();

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Solicitação enviada! Vamos analisar em breve.')),
      );
      Navigator.of(context).pop();
    } on WsErroException catch (e) {
      setState(() {
        _erro = ErroMapper.paraMensagem(e.codigo, mensagemServidor: e.mensagem);
      });
    } on WsTimeoutException {
      setState(() {
        _erro = 'Não foi possível conectar ao servidor. Tente novamente.';
      });
    } finally {
      if (mounted) setState(() => _enviando = false);
    }
  }

  /// Retorna true se a permissão está concedida (pedindo se necessário).
  /// Mostra a mensagem de erro apropriada e retorna false caso contrário.
  Future<bool> _garantirPermissaoLocalizacao() async {
    var status = await Permission.locationWhenInUse.status;

    if (status.isGranted) return true;

    if (status.isPermanentlyDenied) {
      setState(() {
        _erro = 'Você negou permanentemente o acesso à localização. '
            'Abra as configurações do app pra permitir.';
      });
      return false;
    }

    status = await Permission.locationWhenInUse.request();

    if (status.isGranted) return true;

    if (status.isPermanentlyDenied) {
      setState(() {
        _erro = 'Você negou permanentemente o acesso à localização. '
            'Abra as configurações do app pra permitir.';
      });
    } else {
      setState(() {
        _erro = 'É necessário permitir o acesso à localização para se '
            'tornar prestador.';
      });
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Quero ser prestador')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ErrorBanner(mensagem: _erro),
              Text(
                'Virar prestador',
                style: AppTextStyles.titulo,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                'Ao solicitar, sua conta passa por uma análise antes de '
                'poder oferecer serviços na plataforma. Você será avisado '
                'quando a análise terminar.',
                style: AppTextStyles.corpo,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              if (_erro != null &&
                  _erro!.contains('configurações do app')) ...[
                OutlinedButton(
                  onPressed: openAppSettings,
                  child: const Text('Abrir configurações'),
                ),
                const SizedBox(height: 16),
              ],
              _consentimento(
                valor: _aceitaRastreamento,
                onChanged: (v) => setState(() => _aceitaRastreamento = v ?? false),
                texto: 'Entendo que minha localização será utilizada para o '
                    'rastreamento da atividade durante o serviço.',
              ),
              _consentimento(
                valor: _aceitaResponsabilidade,
                onChanged: (v) => setState(() => _aceitaResponsabilidade = v ?? false),
                texto: 'Entendo que sou responsabilizado por quaisquer danos '
                    'causados às propriedades dos clientes.',
              ),
              _consentimento(
                valor: _aceitaPoliticaSuspensao,
                onChanged: (v) => setState(() => _aceitaPoliticaSuspensao = v ?? false),
                texto: 'Entendo que, no caso de violação das diretrizes do '
                    'aplicativo, fico sujeito a ter o cargo de prestador '
                    'suspenso ou, no pior dos casos, ser banido da '
                    'plataforma Ajudaí.',
              ),
              const SizedBox(height: 24),
              AppButton(
                label: 'Confirmar solicitação',
                loading: _enviando,
                onPressed: _podeConfirmar ? _solicitar : null,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _consentimento({
    required bool valor,
    required ValueChanged<bool?> onChanged,
    required String texto,
  }) {
    return CheckboxListTile(
      value: valor,
      onChanged: onChanged,
      controlAffinity: ListTileControlAffinity.leading,
      contentPadding: EdgeInsets.zero,
      title: Text(texto, style: AppTextStyles.corpo),
    );
  }
}