library;

export 'src/models/usuario/usuario.dart';
export 'src/models/usuario/usuario_basico.dart';
export 'src/models/usuario/perfil_completo.dart';
export 'src/models/endereco/endereco.dart';
export 'src/models/categoria/categoria.dart';
export 'src/models/servico/servico.dart';
export 'src/models/servico/servico_oferecido.dart';
export 'src/models/servico/servico_oferecido_resumo.dart';
export 'src/models/servico/servico_oferecido_preview.dart';
export 'src/models/verificacao/verificacao.dart';
export 'src/models/verificacao/verificacao_com_usuario.dart';
export 'src/models/agendamento/agendamento.dart';
export 'src/models/agendamento/agendamento_detalhado_cliente.dart';
export 'src/models/agendamento/agendamento_detalhado_prestador.dart';
export 'src/models/horario_ocupado.dart';
export 'src/models/conquista/conquista.dart';
export 'src/models/conquista/conquista_usuario.dart';
export 'src/models/avaliacao/avaliacao_usuario.dart';
export 'src/models/avaliacao/avaliacao_servico.dart';
export 'src/models/chat/mensagem.dart';
export 'src/models/chat/conversa_resumo.dart';
export 'src/models/chat/mensagem_com_url.dart';

export 'src/models/arquivos/arquivo_upload.dart';
export 'src/models/arquivos/arquivo_anexado.dart';
export 'src/models/denuncia/denuncia.dart';

export 'src/models/contestacao/contestacao.dart';
export 'src/models/contestacao/contestacao_com_detalhes.dart';

export 'src/dto/ws_message.dart';
export 'src/dto/auth/login_request_dto.dart';
export 'src/dto/auth/login_response_dto.dart';
export 'src/dto/auth/restaurar_sessao_dto.dart';
export 'src/dto/erro_dto.dart';
export 'src/dto/auth/cadastro_request_dto.dart';
export 'src/dto/auth/cadastro_response.dart';
export 'src/dto/usuario/atualizar_perfil_request_dto.dart';
export 'src/dto/usuario/atualizar_perfil_response_dto.dart';
export 'src/dto/usuario/obter_perfil_publico_dto.dart';
export 'src/dto/usuario/perfil_completo_dto.dart';
export 'src/dto/usuario/atualizar_avatar_dto.dart';
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
export 'src/dto/admin/aprovar_prestador_request_dto.dart';
export 'src/dto/admin/aprovar_prestador_response_dto.dart';
export 'src/dto/prestador/rejeitar_prestador_request_dto.dart';
export 'src/dto/prestador/rejeitar_prestador_response_dto.dart';
export 'src/dto/admin/listar_verificacoes_request_dto.dart';

export 'src/dto/servico/listar_categorias_request_dto.dart';
export 'src/dto/servico/listar_categorias_response_dto.dart';
export 'src/dto/servico/listar_servicos_oferecidos_por_categoria_request_dto.dart';
export 'src/dto/servico/listar_servicos_oferecidos_por_categoria_response_dto.dart';
export 'src/dto/servico/listar_servicos_oferecidos_por_servico_dto.dart';
export 'src/dto/servico/obter_servico_oferecido_request_dto.dart';
export 'src/dto/servico/obter_servico_oferecido_response_dto.dart';
export 'src/dto/servico/listar_servico_dto.dart';
export 'src/dto/servico/editar_servico_oferecido_dto.dart';
export 'src/dto/servico/desativar_servico_oferecido_dto.dart';
export 'src/dto/servico/ativar_servico_oferecido_dto.dart';

export 'src/dto/prestador/criar_servico_oferecido_dto.dart';
export 'src/dto/prestador/listar_meus_servicos_oferecidos_dto.dart';
export 'src/dto/prestador/listar_meus_servicos_oferecidos_desativados_dto.dart';

export 'src/dto/agendamento/criar_agendamento_request_dto.dart';
export 'src/dto/agendamento/criar_agendamento_response_dto.dart';
export 'src/dto/agendamento/confirmar_pagamento_request_dto.dart';
export 'src/dto/agendamento/confirmar_pagamento_response_dto.dart';

export 'src/dto/agendamento/cancelar_agendamento_dto.dart';
export 'src/dto/agendamento/concluir_agendamento_dto.dart';
export 'src/dto/agendamento/confirmar_conclusao_agendamento_dto.dart';
export 'src/dto/agendamento/iniciar_agendamento_dto.dart';
export 'src/dto/agendamento/listar_agendamentos_cliente_dto.dart';
export 'src/dto/agendamento/listar_agendamentos_prestador_dto.dart';
export 'src/dto/agendamento/obter_agendamento_cliente_dto.dart';
export 'src/dto/agendamento/obter_agendamento_prestador_dto.dart';
export 'src/dto/agendamento/responder_agendamento_dto.dart';
export 'src/dto/agendamento/listar_horario_ocupado_prestador_dto.dart';

export 'src/dto/avaliacao/avaliacao_agendamento_dto.dart';
export 'src/dto/avaliacao/avaliar_usuario_dto.dart';

export 'src/dto/notificacao/listar_minhas_notificacoes_response_dto.dart';
export 'src/dto/notificacao/listar_minhas_notificacoes_request_dto.dart';
export 'src/dto/notificacao/marcar_notificacao_como_lida_dto.dart';
export 'src/dto/notificacao/marcar_todas_notificacoes_como_lida_dto.dart';

export 'src/dto/denuncia/criar_denuncia_dto.dart';
export 'src/dto/denuncia/listar_minhas_denuncias_dto.dart';

export 'src/dto/contestacao/criar_contestacao_dto.dart';
export 'src/dto/contestacao/listar_minhas_contestacoes_dto.dart';

export 'src/dto/chat/listar_conversas_dto.dart';
export 'src/dto/chat/listar_mensagens_dto.dart';
export 'src/dto/chat/enviar_mensagem_dto.dart';
export 'src/dto/chat/criar_conversa_dto.dart';

export 'src/dto/admin/admin_listar_contestacao_dto.dart';
export 'src/dto/admin/admin_responder_contestacao_dto.dart';
export 'src/dto/admin/listar_verificacoes_response_dto.dart';

export 'src/validators/cpf_validator.dart';
export 'src/validators/telefone_validator.dart';
export 'src/validators/agendamento_validator.dart';

export 'src/models/enums/status_prestador.dart';
export 'src/models/enums/user_role.dart';
export 'src/models/enums/status_verificacao.dart';
export 'src/models/enums/status_agendamento.dart';
export 'src/models/enums/tipo_conquista.dart';
export 'src/models/enums/tipo_alteracao_agendamento.dart';
export 'src/models/enums/eventos_agendamento.dart';
export 'src/models/enums/tipo_denuncia.dart';
export 'src/models/enums/tipo_conteudo_mensagem.dart';
export 'src/models/enums/tipo_arquivo.dart';
export 'src/models/enums/status_contestacao.dart';
export 'src/models/enums/status_solicitacao_preco.dart';
