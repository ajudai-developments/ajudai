import 'package:backend/supabase_client.dart';

Future<void> main() async {
  final response = await supabase.auth.signUp(
    email: "djefferp@gmail.com",
    password: "abcDFG123",
    data: {
      'nome': 'Djeffer Teste',
      'cpf': '12345678901',
      'telefone': '44999999999',
    },
  );

  print("USER: ${response.user}\n");
  print('SESSION: ${response.session}');
}
