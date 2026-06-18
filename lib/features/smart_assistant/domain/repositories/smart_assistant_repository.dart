import '../../data/models/chat_request.dart';
import '../../data/models/chat_response.dart';
import '../../data/models/welcoming_response.dart';

abstract class SmartAssistantRepository {
  Future<WelcomingResponse> getWelcomingMessage();
  Future<ChatResponse> sendMessage(ChatRequest request);
}
