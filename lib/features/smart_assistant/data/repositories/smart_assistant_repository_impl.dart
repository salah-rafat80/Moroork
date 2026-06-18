import 'package:injectable/injectable.dart';
import '../../../../core/api/api_error_handler.dart';
import '../../domain/repositories/smart_assistant_repository.dart';
import '../datasources/smart_assistant_remote_data_source.dart';
import '../models/chat_request.dart';
import '../models/chat_response.dart';
import '../models/welcoming_response.dart';
import 'package:dio/dio.dart';

@Injectable(as: SmartAssistantRepository)
class SmartAssistantRepositoryImpl implements SmartAssistantRepository {
  final SmartAssistantRemoteDataSource _remoteDataSource;

  SmartAssistantRepositoryImpl(this._remoteDataSource);

  @override
  Future<WelcomingResponse> getWelcomingMessage() async {
    try {
      return await _remoteDataSource.getWelcomingMessage();
    } on DioException catch (e) {
      throw Exception(ApiErrorHandler.extractMessage(e));
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  @override
  Future<ChatResponse> sendMessage(ChatRequest request) async {
    try {
      return await _remoteDataSource.sendMessage(request);
    } on DioException catch (e) {
      throw Exception(ApiErrorHandler.extractMessage(e));
    } catch (e) {
      throw Exception(e.toString());
    }
  }
}
