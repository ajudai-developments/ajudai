import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../ws/ws_client.dart';
import '../../auth/state/auth_controller.dart';
import '../state/perfil_providers.dart';

const _responsabilidades = [
  'Estou ciente de que será feito o uso da minha localização durante os serviços.',
  'Estou ciente de que sou responsável por eventuais danos causados aos itens pessoais dos clientes.',
  'Comprometo-me a comparecer nos horários agendados ou avisar com antecedência em caso de imprevisto.',
  'Estou ciente de que meu cadastro pode ser suspenso em caso de denúncias procedentes.',
  'Concordo em manter meus dados de contato e serviços oferecidos sempre atualizados.',
];

class TornarPrestadorPage extends ConsumerStatefulWidget {
  const TornarPrestadorPage({super.key});

  @override
  ConsumerState<TornarPrestadorPage> createState() => _TornarPrestadorPageState();
}

class _TornarPrestadorPageState extends ConsumerState<TornarPrestadorPage> {
  late final List<bool> _aceites = List.filled(_responsabilidades.length, false);
  bool _enviando = false;

  bool get _todosAceitos => _aceites.every((v) => v);

  Future<void> _confirmar() async {
    setState(() => _enviando = true);
    try {
      final resposta = await ref.read(perfilRepositoryProvider).solicitarPrestador();
      await ref.read(authControllerProvider.notifier).atualizarUsuarioLocal(resposta.usuario);
      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Solicitação enviada! Vamos avisar quando for aprovada.')),
        );
      }
    } on WsErrorException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.mensagem)));
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Não foi possível enviar sua solicitação.')),
        );
      }
    } finally {
      if (mounted) setState(() => _enviando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Quero ser prestador')),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                Text(
                  'Antes de continuar, leia e confirme cada item abaixo:',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 16),
                for (var i = 0; i < _responsabilidades.length; i++)
                  CheckboxListTile(
                    contentPadding: EdgeInsets.zero,
                    controlAffinity: ListTileControlAffinity.leading,
                    value: _aceites[i],
                    onChanged: (v) => setState(() => _aceites[i] = v ?? false),
                    title: Text(_responsabilidades[i]),
                  ),
              ],
            ),
          ),
          SafeArea(
            minimum: const EdgeInsets.all(20),
            child: ElevatedButton(
              onPressed: (_todosAceitos && !_enviando) ? _confirmar : null,
              child: _enviando
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : const Text('Aceitar e enviar solicitação'),
            ),
          ),
        ],
      ),
    );
  }
}