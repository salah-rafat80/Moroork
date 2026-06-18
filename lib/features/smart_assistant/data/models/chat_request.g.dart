// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chat_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ChatRequestImpl _$$ChatRequestImplFromJson(Map<String, dynamic> json) =>
    _$ChatRequestImpl(
      query: json['query'] as String,
      userLanguage: json['userLanguage'] as String? ?? 'auto',
      includeSources: json['includeSources'] as bool? ?? false,
      topK: (json['topK'] as num?)?.toInt() ?? 5,
      optimizeQuery: json['optimizeQuery'] as bool? ?? true,
    );

Map<String, dynamic> _$$ChatRequestImplToJson(_$ChatRequestImpl instance) =>
    <String, dynamic>{
      'query': instance.query,
      'userLanguage': instance.userLanguage,
      'includeSources': instance.includeSources,
      'topK': instance.topK,
      'optimizeQuery': instance.optimizeQuery,
    };
