import 'package:ajudai/core/layout/responsivo.dart';
import 'package:ajudai/core/widgets/grade_adaptativa.dart';
import 'package:ajudai/core/widgets/tela_adaptativa.dart';
import 'package:flutter/material.dart';
import 'package:shared/shared.dart';

import '../../core/routes/app_routes.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/async_list_view.dart';
import '../../core/widgets/cabecalho_simples.dart';
import 'endereco_repository.dart';

/// Limite de endereços por usuário, espelhando a regra já validada no
/// backend (EnderecoService/PostgrestException 'limite_enderecos_excedido').
/// Mantido aqui só pra desabilitar o botão preventivamente na UI — a
/// validação de verdade continua sendo feita pelo servidor.
const _limiteEnderecos = 3;

/// Lista de endereços do usuário.
///
/// Cabeçalho vermelho da marca, cada endereço como cartão tocável (toque =
/// editar) e botão de adicionar fixo no rodapé.

class MeusEnderecosScreen extends StatefulWidget {
  const MeusEnderecosScreen({super.key});

  @override
  State<MeusEnderecosScreen> createState() => _MeusEnderecosScreenState();
}

class _MeusEnderecosScreenState extends State<MeusEnderecosScreen> {
  final _enderecoRepository = EnderecoRepository();
  final _listKey = GlobalKey<AsyncListViewState<Endereco>>();

  int _totalEnderecos = 0;

  Future<void> _abrirFormulario({Endereco? enderecoParaEditar}) async {
    final resultado = await Navigator.of(
      context,
    ).pushNamed(AppRoutes.formEndereco, arguments: enderecoParaEditar);

    if (resultado == true) {
      _listKey.currentState?.recarregar();
    }
  }

  @override
  Widget build(BuildContext context) {
    final atingiuLimite = _totalEnderecos >= _limiteEnderecos;
    final web = context.usaLayoutWeb;

    return TelaAdaptativa(
      titulo: 'Meus endereços',
      rotaAtual: AppRoutes.meuPerfil,
      semAppBarMobile: true,
      child: Column(
        children: [
          if (!web)
            const CabecalhoSimples(
              titulo: 'Meus endereços',
              subtitulo: 'Onde você quer receber os serviços',
            ),
          Expanded(
            child: AsyncListView<Endereco>(
              key: _listKey,
              carregar: _enderecoRepository.obterMeusEnderecos,
              mensagemVazio:
                  'Você ainda não tem endereços.\nAdicione um para agendar serviços.',
              onDadosCarregados: (enderecos) {
                if (mounted) {
                  setState(() => _totalEnderecos = enderecos.length);
                }
              },
              builder: (context, enderecos) {
                final cards = [
                  for (final endereco in enderecos)
                    _EnderecoCard(
                      endereco: endereco,
                      onTap: () =>
                          _abrirFormulario(enderecoParaEditar: endereco),
                    ),
                ];

                return web
                    ? Padding(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        child: GradeAdaptativa(
                          larguraMinItem: 300,
                          maxColunas: 3,
                          children: cards,
                        ),
                      )
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          for (final card in cards) ...[
                            card,
                            const SizedBox(height: 12),
                          ],
                        ],
                      );
              },
            ),
          ),
          Container(
            width: double.infinity,
            decoration: const BoxDecoration(
              color: AppColors.surface,
              border: Border(top: BorderSide(color: AppColors.outline)),
            ),
            child: SafeArea(
              top: false,
              child: ConteudoCentralizado(
                larguraMax: 560,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: Text(
                          atingiuLimite
                              ? 'Você atingiu o limite de $_limiteEnderecos endereços. '
                                    'Edite ou troque um deles.'
                              : '$_totalEnderecos de $_limiteEnderecos endereços',
                          style: AppTextStyles.legenda,
                          textAlign: TextAlign.center,
                        ),
                      ),
                      AppButton(
                        label: 'Adicionar endereço',
                        onPressed: atingiuLimite
                            ? null
                            : () => _abrirFormulario(),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Cartão de um endereço: ícone pelo nome (Casa/Trabalho/outro), nome em
/// destaque, rua + número (+ complemento) e bairro/cidade.
class _EnderecoCard extends StatelessWidget {
  final Endereco endereco;
  final VoidCallback onTap;

  const _EnderecoCard({required this.endereco, required this.onTap});

  IconData get _icone {
    switch (endereco.nome.trim().toLowerCase()) {
      case 'casa':
        return Icons.home_rounded;
      case 'trabalho':
        return Icons.work_rounded;
      default:
        return Icons.place_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final complemento = endereco.complemento?.trim();
    final linhaRua = complemento == null || complemento.isEmpty
        ? '${endereco.logradouro}, ${endereco.numero}'
        : '${endereco.logradouro}, ${endereco.numero} - $complemento';

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.outline),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: const BoxDecoration(
                color: AppColors.primarySoft,
                shape: BoxShape.circle,
              ),
              child: Icon(_icone, color: AppColors.primary, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    endereco.nome,
                    style: AppTextStyles.titulo,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    linhaRua,
                    style: AppTextStyles.corpo.copyWith(
                      color: AppColors.textoTitulo,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${endereco.bairro} • ${endereco.cidade}/${endereco.estado}',
                    style: AppTextStyles.legenda,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            const Padding(
              padding: EdgeInsets.only(top: 10),
              child: Icon(
                Icons.chevron_right_rounded,
                color: AppColors.textoSecundario,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
