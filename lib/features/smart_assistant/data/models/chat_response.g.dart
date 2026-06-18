// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chat_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ChatResponseImpl _$$ChatResponseImplFromJson(Map<String, dynamic> json) =>
    _$ChatResponseImpl(
      answer: json['answer'] as String,
      sources: json['sources'] as List<dynamic>? ?? const [],
      source: json['source'] as String?,
      inserted: json['inserted'] as bool? ?? false,
      error: json['error'] as String?,
    );

Map<String, dynamic> _$$ChatResponseImplToJson(_$ChatResponseImpl instance) =>
    <String, dynamic>{
      'answer': instance.answer,
      'sources': instance.sources,
      'source': instance.source,
      'inserted': instance.inserted,
      'error': instance.error,
    };
