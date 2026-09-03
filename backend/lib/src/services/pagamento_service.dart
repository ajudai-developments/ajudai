class PagamentoService {
  Future<bool> processar({required double valor}) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return true;
  }
}
