import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:uuid/uuid.dart';
import '../data/models/chat_message.dart';
import '../data/models/chat_request.dart';
import '../domain/repositories/smart_assistant_repository.dart';
import 'smart_assistant_chat_event_state.dart';

@injectable
class SmartAssistantChatBloc extends Bloc<SmartAssistantChatEvent, SmartAssistantChatState> {
  final SmartAssistantRepository _repository;
  final _uuid = const Uuid();

  SmartAssistantChatBloc(this._repository) : super(const SmartAssistantChatInitial()) {
    on<WelcomingMessageFetched>(_onWelcomingMessageFetched);
    on<MessageSent>(_onMessageSent);
  }

  Future<void> _onWelcomingMessageFetched(
    WelcomingMessageFetched event,
    Emitter<SmartAssistantChatState> emit,
  ) async {
    emit(SmartAssistantChatLoading(state.messages));
    try {
      final response = await _repository.getWelcomingMessage();
      
      final welcomeMessage = ChatMessage(
        id: _uuid.v4(),
        text: response.message,
        isUser: false,
        timestamp: DateTime.now(),
      );

      final updatedMessages = List<ChatMessage>.from(state.messages)..add(welcomeMessage);
      emit(SmartAssistantChatSuccess(updatedMessages));
    } catch (e) {
      emit(SmartAssistantChatFailure(state.messages, e.toString()));
    }
  }

  Future<void> _onMessageSent(
    MessageSent event,
    Emitter<SmartAssistantChatState> emit,
  ) async {
    final text = event.text.trim();
    if (text.isEmpty) return;

    final userMessage = ChatMessage(
      id: _uuid.v4(),
      text: text,
      isUser: true,
      timestamp: DateTime.now(),
    );

    // Add user message to UI immediately and transition to loading state (to show thinking indicator)
    var currentMessages = List<ChatMessage>.from(state.messages)..add(userMessage);
    emit(SmartAssistantChatLoading(currentMessages));

    try {
      final request = ChatRequest(query: text);
      final response = await _repository.sendMessage(request);

      final aiMessage = ChatMessage(
        id: _uuid.v4(),
        text: response.answer,
        isUser: false,
        timestamp: DateTime.now(),
      );

      currentMessages = List<ChatMessage>.from(currentMessages)..add(aiMessage);
      emit(SmartAssistantChatSuccess(currentMessages));
    } catch (e) {
      emit(SmartAssistantChatFailure(currentMessages, e.toString()));
    }
  }
}
