import 'package:dio/dio.dart';
import '../models/encomenda.dart';

class ApiService {
  final Dio _dio = Dio(BaseOptions(
    baseUrl: 'http://localhost:3000/api',
    connectTimeout: const Duration(seconds: 5),
    receiveTimeout: const Duration(seconds: 3),
    headers: {'Content-Type': 'application/json'},
  ));

  // Métodos para Encomendas
  Future<List<Encomenda>> getEncomendas() async {
    try {
      final response = await _dio.get('/encomendas');
      return (response.data as List)
          .map((json) => Encomenda.fromJson(json))
          .toList();
    } catch (e) {
      throw 'Erro ao buscar encomendas: $e';
    }
  }

  Future<Encomenda> getDetalhesEncomenda(String id) async {
    try {
      final response = await _dio.get('/encomendas/$id');
      return Encomenda.fromJson(response.data);
    } catch (e) {
      throw 'Erro ao buscar detalhes da encomenda: $e';
    }
  }

  Future<void> atualizarEstadoEncomenda(String id, String novoEstado) async {
    try {
      await _dio.put(
        '/encomendas/$id/estado',
        data: {'estado': novoEstado},
      );
    } catch (e) {
      throw 'Erro ao atualizar estado da encomenda: $e';
    }
  }

  // Métodos para Anúncios
  Future<List<dynamic>> getAnuncios() async {
    try {
      final response = await _dio.get('/anuncios');
      return response.data as List;
    } catch (e) {
      throw 'Erro ao buscar anúncios: $e';
    }
  }

  Future<Map<String, dynamic>> getDetalhesAnuncio(String id) async {
    try {
      final response = await _dio.get('/anuncios/$id');
      return response.data as Map<String, dynamic>;
    } catch (e) {
      throw 'Erro ao buscar detalhes do anúncio: $e';
    }
  }

  Future<void> criarAnuncio(Map<String, dynamic> dados) async {
    try {
      await _dio.post('/anuncios', data: dados);
    } catch (e) {
      throw 'Erro ao criar anúncio: $e';
    }
  }
} 