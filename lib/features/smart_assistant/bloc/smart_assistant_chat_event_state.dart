import 'package:equatable/equatable.dart';
import '../data/models/chat_message.dart';

// ── EVENTS ──
sealed class SmartAssistantChatEvent extends Equatable {
  const SmartAssistantChatEvent();

  @override
  List<Object?> get props => [];
}

class WelcomingMessageFetched extends SmartAssistantChatEvent {
  const WelcomingMessageFetched();
}

class MessageSent extends SmartAssistantChatEvent {
  final String text;

  const MessageSent(this.text);

  @override
  List<Object?> get props => [text];
}

// ── STATES ──
sealed class SmartAssistantChatState extends Equatable {
  final List<ChatMessage> messages;

  const SmartAssistantChatState(this.messages);

  @override
  List<Object?> get props => [messages];
}

class SmartAssistantChatInitial extends SmartAssistantChatState {
  const SmartAssistantChatInitial() : super(const []);
}

class SmartAssistantChatLoading extends SmartAssistantChatState {
  const SmartAssistantChatLoading(super.messages);
}

class SmartAssistantChatSuccess extends SmartAssistantChatState {
  const SmartAssistantChatSuccess(super.messages);
}

class SmartAssistantChatFailure extends SmartAssistantChatState {
  final String errorMessage;

  const SmartAssistantChatFailure(super.messages, this.errorMessage);

  @override
  List<Object?> get props => [messages, errorMessage];
}
