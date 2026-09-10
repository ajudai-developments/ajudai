import 'package:flutter/material.dart';
import 'package:shared/shared.dart';

import '../../core/routes/app_routes.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/async_list_view.dart';
import 'endereco_repository.dart';

/// Limite de endereços por usuário, espelhando a regra já validada no
/// backend (EnderecoService/PostgrestException 'limite_enderecos_excedido').
/// Mantido aqui só pra desabilitar o botão preventivamente na UI — a
/// validação de verdade continua sendo feita pelo servidor.
const _limiteEnderecos = 3;

class MeusEnderecosScreen extends StatefulWidget {
  const MeusEnderecosScreen({super.key});

  @override
  State<MeusEnderecosScreen> createState() => _MeusEnderecosScreenState();
}

class _MeusEnderecosScreenState extends State<MeusEnderecosScreen> {
  final _enderecoRepository = EnderecoRepository();
  final _listKey = GlobalKey<AsyncListViewState<Endereco>>();

  // Só usado pra decidir se o FAB fica desabilitado — a lista em si
  // é renderizada e mantida pelo AsyncListView.
  int _totalEnderecos = 0;

  Future<void> _abrirFormulario({Endereco? enderecoParaEditar}) async {
    final resultado = await Navigator.of(context).pushNamed(
      AppRoutes.formEndereco,
      arguments: enderecoParaEditar,
    );

    // form_endereco_screen deve retornar `true` via Navigator.pop(true)
    // quando criar/editar com sucesso, pra sabermos que precisa recarregar.
    if (resultado == true) {
      _listKey.currentState?.recarregar();
    }
  }

  @override
  Widget build(BuildContext context) {
    final atingiuLimite = _totalEnderecos >= _limiteEnderecos;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Meus endereços')),
      body: AsyncListView<Endereco>(
        key: _listKey,
        carregar: _enderecoRepository.obterMeusEnderecos,
        mensagemVazio: 'Você ainda não tem endereços cadastrados.',
        onDadosCarregados: (enderecos) {
          setState(() => _totalEnderecos = enderecos.length);
        },
        builder: (context, enderecos) => Column(
          children: [
            for (final endereco in enderecos)
              Card(
                child: ListTile(
                  title: Text(endereco.nome, style: AppTextStyles.titulo),
                  subtitle: Text(
                    '${endereco.logradouro}, ${endereco.numero}'
                    '${endereco.complemento != null ? ' - ${endereco.complemento}' : ''}\n'
                    '${endereco.bairro} - ${endereco.cidade}/${endereco.estado}',
                    style: AppTextStyles.corpo,
                  ),
                  isThreeLine: true,
                  trailing: const Icon(Icons.edit),
                  onTap: () => _abrirFormulario(enderecoParaEditar: endereco),
                ),
              ),
            const SizedBox(height: 8),
            Text(
              '${enderecos.length}/$_limiteEnderecos endereços cadastrados',
              style: AppTextStyles.legenda,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: atingiuLimite ? null : () => _abrirFormulario(),
        backgroundColor: atingiuLimite ? AppColors.textoSecundario : AppColors.primary,
        icon: const Icon(Icons.add),
        label: Text(atingiuLimite ? 'Limite atingido' : 'Adicionar endereço'),
      ),
    );
  }
}