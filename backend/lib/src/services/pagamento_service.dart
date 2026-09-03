class PagamentoService {
  Future<bool> processar({
    required double valor,
    required String metodoPagamento,
  }) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return true;
  }
}
