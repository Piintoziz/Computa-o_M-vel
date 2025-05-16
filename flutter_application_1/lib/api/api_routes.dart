class ApiRoutes {
  // URL base da API
  static const String baseUrl = 'http://localhost:3000/api';

  // Rotas para Encomendas
  static String get encomendas => '$baseUrl/encomendas';
  static String detalhesEncomenda(String id) => '$baseUrl/encomendas/$id';
  static String atualizarEstadoEncomenda(String id) => '$baseUrl/encomendas/$id/estado';
  static String get proximasEntregas => '$baseUrl/encomendas/proximas';

  // Rotas para Anúncios
  static String get anuncios => '$baseUrl/anuncios';
  static String detalhesAnuncio(String id) => '$baseUrl/anuncios/$id';
  static String get criarAnuncio => '$baseUrl/anuncios';

  // Rotas de Autenticação
  static String get login => '$baseUrl/auth/login';
  static String get registro => '$baseUrl/auth/registro';
} 