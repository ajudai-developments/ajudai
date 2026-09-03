library;

export 'src/models/usuario.dart';
export 'src/models/endereco.dart';
export 'src/models/categoria.dart';
export 'src/models/servico.dart';
export 'src/models/servico_oferecido.dart';
export 'src/models/servico_oferecido_preview.dart';
export 'src/models/verificacao.dart';
export 'src/models/verificacao_com_usuario.dart';
export 'src/models/agendamento.dart';
export 'src/models/conquista.dart';
export 'src/models/conquista_usuario.dart';
export 'src/models/avaliacao_usuario.dart';

export 'src/dto/ws_message.dart';
export 'src/dto/auth/login_request_dto.dart';
export 'src/dto/auth/login_response_dto.dart';
export 'src/dto/erro_dto.dart';
export 'src/dto/auth/cadastro_request_dto.dart';
export 'src/dto/auth/cadastro_response.dart';
export 'src/dto/usuario/atualizar_perfil_request_dto.dart';
export 'src/dto/usuario/atualizar_perfil_response_dto.dart';
export 'src/dto/tipo_mensagem.dart';
export 'src/dto/json_utils.dart';
export 'src/dto/endereco/consultar_cep_request.dart';
export 'src/dto/endereco/consultar_cep_response.dart';
export 'src/dto/endereco/criar_endereco_request.dart';
export 'src/dto/endereco/criar_endereco_response.dart';
export 'src/dto/endereco/obter_meus_enderecos_request_dto.dart';
export 'src/dto/endereco/obter_meus_enderecos_response_dto.dart';
export 'src/dto/endereco/editar_endereco_request_dto.dart';
export 'src/dto/endereco/editar_endereco_response_dto.dart';
export 'src/dto/notificacao/notificacao_dto.dart';

export 'src/dto/prestador/solicitar_prestador_request_dto.dart';
export 'src/dto/prestador/solicitar_prestador_response_dto.dart';
export 'src/dto/prestador/aprovar_prestador_request_dto.dart';
export 'src/dto/prestador/aprovar_prestador_response_dto.dart';
export 'src/dto/prestador/rejeitar_prestador_request_dto.dart';
export 'src/dto/prestador/rejeitar_prestador_response_dto.dart';
export 'src/dto/prestador/listar_verificacoes_request_dto.dart';
export 'src/dto/prestador/listar_verificacoes_response_dto.dart';

export 'src/dto/servico/listar_categorias_request_dto.dart';
export 'src/dto/servico/listar_categorias_response_dto.dart';
export 'src/dto/servico/listar_servicos_request_dto.dart';
export 'src/dto/servico/listar_servicos_response_dto.dart';
export 'src/dto/servico/obter_servico_oferecido_request_dto.dart';
export 'src/dto/servico/obter_servico_oferecido_response_dto.dart';

export 'src/dto/prestador/criar_servico_oferecido_dto.dart';
export 'src/dto/prestador/meus_servicos_oferecidos_dto.dart';

export 'src/dto/agendamento/criar_agendamento_request_dto.dart';
export 'src/dto/agendamento/criar_agendamento_response_dto.dart';
export 'src/dto/agendamento/confirmar_pagamento_request_dto.dart';
export 'src/dto/agendamento/confirmar_pagamento_response_dto.dart';

export 'src/dto/agendamento/cancelar_agendamento_dto.dart';
export 'src/dto/agendamento/concluir_agendamento_dto.dart';
export 'src/dto/agendamento/confirmar_conclusao_agendamento_dto.dart';
export 'src/dto/agendamento/iniciar_agendamento_dto.dart';
export 'src/dto/agendamento/listar_agendamentos_dto.dart';
export 'src/dto/agendamento/obter_agendamento_dto.dart';
export 'src/dto/agendamento/responder_agendamento_dto.dart';

export 'src/validators/cpf_validator.dart';
export 'src/validators/telefone_validator.dart';
export 'src/validators/agendamento_validator.dart';

export 'src/models/enums/status_prestador.dart';
export 'src/models/enums/user_role.dart';
export 'src/models/enums/status_verificacao.dart';
export 'src/models/enums/status_agendamento.dart';
export 'src/models/enums/tipo_conquista.dart';
export 'src/models/enums/tipo_alteracao_agendamento.dart';
