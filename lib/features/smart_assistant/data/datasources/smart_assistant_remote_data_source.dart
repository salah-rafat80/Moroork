
import 'package:injectable/injectable.dart';
import '../../../../core/api/api_client.dart';
import '../models/chat_request.dart';
import '../models/chat_response.dart';
import '../models/welcoming_response.dart';

abstract class SmartAssistantRemoteDataSource {
  Future<WelcomingResponse> getWelcomingMessage();
  Future<ChatResponse> sendMessage(ChatRequest request);
}

@LazySingleton(as: SmartAssistantRemoteDataSource)
class SmartAssistantRemoteDataSourceImpl implements SmartAssistantRemoteDataSource {
  final ApiClient _apiClient;

  // The base URL from the user's swagger: https://apigetaway-staging.sustaingrc.com/tprm-ai
  // Assuming the ApiClient (Dio) might have a different base URL for the main traffic app,
  // we might need to override the baseUrl for this specific data source.
  // We can do this on the request level or inject a named Dio instance.
  // For now, we will override the URL in the request to ensure it hits the right endpoint.
  static const String _aiBaseUrl = 'https://apigetaway-staging.sustaingrc.com/tprm-ai';

  SmartAssistantRemoteDataSourceImpl(this._apiClient);

  @override
  Future<WelcomingResponse> getWelcomingMessage() async {
    final response = await _apiClient.dio.get('$_aiBaseUrl/api/v1/welcoming');
    return WelcomingResponse.fromJson(response.data);
  }

  @override
  Future<ChatResponse> sendMessage(ChatRequest request) async {
    final response = await _apiClient.dio.post(
      '$_aiBaseUrl/api/v1/moroork-assistant/chat',
      data: request.toJson(),
    );
    return ChatResponse.fromJson(response.data);
  }
}
