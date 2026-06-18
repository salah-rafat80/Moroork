import 'package:freezed_annotation/freezed_annotation.dart';

part 'chat_response.freezed.dart';
part 'chat_response.g.dart';

@freezed
class ChatResponse with _$ChatResponse {
  const factory ChatResponse({
    required String answer,
    @Default([]) List<dynamic> sources,
    String? source,
    @Default(false) bool inserted,
    String? error,
  }) = _ChatResponse;

  factory ChatResponse.fromJson(Map<String, dynamic> json) => _$ChatResponseFromJson(json);
}
