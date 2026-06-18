import 'package:freezed_annotation/freezed_annotation.dart';

part 'welcoming_response.freezed.dart';
part 'welcoming_response.g.dart';

@freezed
class WelcomingResponse with _$WelcomingResponse {
  const factory WelcomingResponse({
    required String message,
    required String status,
  }) = _WelcomingResponse;

  factory WelcomingResponse.fromJson(Map<String, dynamic> json) => _$WelcomingResponseFromJson(json);
}
