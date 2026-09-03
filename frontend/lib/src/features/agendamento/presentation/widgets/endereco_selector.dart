// lib/src/features/agendamento/presentation/widgets/endereco_selector.dart
import 'package:ajudai/src/core/theme/app_colors.dart';
import 'package:ajudai/src/core/theme/app_text_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared/shared.dart';
import '../../state/agendamento_providers.dart';

class EnderecoSelector extends ConsumerStatefulWidget {
  final Function(Endereco endereco) onEnderecoSelecionado;
  final String? enderecoIdSelecionado;

  const EnderecoSelector({
    super.key,
    required this.onEnderecoSelecionado,
    this.enderecoIdSelecionado,
  });

  @override
  ConsumerState<EnderecoSelector> createState() => _EnderecoSelectorState();
}

class _EnderecoSelectorState extends ConsumerState<EnderecoSelector> {
  String? _enderecoIdSelecionado;

  @override
  void initState() {
    super.initState();
    _enderecoIdSelecionado = widget.enderecoIdSelecionado;
  }

  @override
  Widget build(BuildContext context) {
    final enderecosAsync = ref.watch(meusEnderecosProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Endereço', style: AppTextStyles.label),
            TextButton(
              onPressed: () {
                // Navegar para criar novo endereço
                // TODO: Implementar navegação
              },
              child: const Text('+ Novo'),
            ),
          ],
        ),
        const SizedBox(height: 8),

        enderecosAsync.when(
          loading: () => const Center(
            child: SizedBox(
              height: 40,
              child: CircularProgressIndicator(),
            ),
          ),
          error: (error, stack) => Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.erro.withOpacity(0.1),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                Icon(Icons.error_outline, color: AppColors.erro),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Erro ao carregar endereços',
                    style: AppTextStyles.corpo.copyWith(
                      color: AppColors.erro,
                    ),
                  ),
                ),
              ],
            ),
          ),
          data: (enderecos) {
            if (enderecos.isEmpty) {
              return Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.fundoCampo,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Column(
                  children: [
                    Text(
                      'Nenhum endereço cadastrado',
                      style: AppTextStyles.subtitulo,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    TextButton(
                      onPressed: () {
                        // Navegar para criar novo endereço
                        // TODO: Implementar navegação
                      },
                      child: const Text('Cadastrar endereço'),
                    ),
                  ],
                ),
              );
            }

            return Column(
              children: enderecos.map((endereco) {
                final isSelected = _enderecoIdSelecionado == endereco.id;
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _enderecoIdSelecionado = endereco.id;
                    });
                    widget.onEnderecoSelecionado(endereco);
                  },
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.vermelho.withOpacity(0.05)
                          : AppColors.fundoCampo,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: isSelected
                            ? AppColors.vermelho
                            : Colors.transparent,
                        width: 1.5,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          isSelected
                              ? Icons.radio_button_checked
                              : Icons.radio_button_unchecked,
                          color: isSelected
                              ? AppColors.vermelho
                              : AppColors.cinzaClaro,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                endereco.nome,
                                style: AppTextStyles.corpo.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Text(
                                '${endereco.logradouro}, ${endereco.numero}${endereco.complemento != null ? ', ${endereco.complemento}' : ''}',
                                style: AppTextStyles.secundario,
                              ),
                              Text(
                                '${endereco.bairro}, ${endereco.cidade} - ${endereco.estado}',
                                style: AppTextStyles.secundario.copyWith(
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            );
          },
        ),
      ],
    );
  }
}