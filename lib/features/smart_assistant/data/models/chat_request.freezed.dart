// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'chat_request.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

ChatRequest _$ChatRequestFromJson(Map<String, dynamic> json) {
  return _ChatRequest.fromJson(json);
}

/// @nodoc
mixin _$ChatRequest {
  String get query => throw _privateConstructorUsedError;
  String get userLanguage => throw _privateConstructorUsedError;
  bool get includeSources => throw _privateConstructorUsedError;
  int get topK => throw _privateConstructorUsedError;
  bool get optimizeQuery => throw _privateConstructorUsedError;

  /// Serializes this ChatRequest to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ChatRequest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ChatRequestCopyWith<ChatRequest> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ChatRequestCopyWith<$Res> {
  factory $ChatRequestCopyWith(
    ChatRequest value,
    $Res Function(ChatRequest) then,
  ) = _$ChatRequestCopyWithImpl<$Res, ChatRequest>;
  @useResult
  $Res call({
    String query,
    String userLanguage,
    bool includeSources,
    int topK,
    bool optimizeQuery,
  });
}

/// @nodoc
class _$ChatRequestCopyWithImpl<$Res, $Val extends ChatRequest>
    implements $ChatRequestCopyWith<$Res> {
  _$ChatRequestCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ChatRequest
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? query = null,
    Object? userLanguage = null,
    Object? includeSources = null,
    Object? topK = null,
    Object? optimizeQuery = null,
  }) {
    return _then(
      _value.copyWith(
            query: null == query
                ? _value.query
                : query // ignore: cast_nullable_to_non_nullable
                      as String,
            userLanguage: null == userLanguage
                ? _value.userLanguage
                : userLanguage // ignore: cast_nullable_to_non_nullable
                      as String,
            includeSources: null == includeSources
                ? _value.includeSources
                : includeSources // ignore: cast_nullable_to_non_nullable
                      as bool,
            topK: null == topK
                ? _value.topK
                : topK // ignore: cast_nullable_to_non_nullable
                      as int,
            optimizeQuery: null == optimizeQuery
                ? _value.optimizeQuery
                : optimizeQuery // ignore: cast_nullable_to_non_nullable
                      as bool,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$ChatRequestImplCopyWith<$Res>
    implements $ChatRequestCopyWith<$Res> {
  factory _$$ChatRequestImplCopyWith(
    _$ChatRequestImpl value,
    $Res Function(_$ChatRequestImpl) then,
  ) = __$$ChatRequestImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String query,
    String userLanguage,
    bool includeSources,
    int topK,
    bool optimizeQuery,
  });
}

/// @nodoc
class __$$ChatRequestImplCopyWithImpl<$Res>
    extends _$ChatRequestCopyWithImpl<$Res, _$ChatRequestImpl>
    implements _$$ChatRequestImplCopyWith<$Res> {
  __$$ChatRequestImplCopyWithImpl(
    _$ChatRequestImpl _value,
    $Res Function(_$ChatRequestImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ChatRequest
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? query = null,
    Object? userLanguage = null,
    Object? includeSources = null,
    Object? topK = null,
    Object? optimizeQuery = null,
  }) {
    return _then(
      _$ChatRequestImpl(
        query: null == query
            ? _value.query
            : query // ignore: cast_nullable_to_non_nullable
                  as String,
        userLanguage: null == userLanguage
            ? _value.userLanguage
            : userLanguage // ignore: cast_nullable_to_non_nullable
                  as String,
        includeSources: null == includeSources
            ? _value.includeSources
            : includeSources // ignore: cast_nullable_to_non_nullable
                  as bool,
        topK: null == topK
            ? _value.topK
            : topK // ignore: cast_nullable_to_non_nullable
                  as int,
        optimizeQuery: null == optimizeQuery
            ? _value.optimizeQuery
            : optimizeQuery // ignore: cast_nullable_to_non_nullable
                  as bool,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$ChatRequestImpl implements _ChatRequest {
  const _$ChatRequestImpl({
    required this.query,
    this.userLanguage = 'auto',
    this.includeSources = false,
    this.topK = 5,
    this.optimizeQuery = true,
  });

  factory _$ChatRequestImpl.fromJson(Map<String, dynamic> json) =>
      _$$ChatRequestImplFromJson(json);

  @override
  final String query;
  @override
  @JsonKey()
  final String userLanguage;
  @override
  @JsonKey()
  final bool includeSources;
  @override
  @JsonKey()
  final int topK;
  @override
  @JsonKey()
  final bool optimizeQuery;

  @override
  String toString() {
    return 'ChatRequest(query: $query, userLanguage: $userLanguage, includeSources: $includeSources, topK: $topK, optimizeQuery: $optimizeQuery)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ChatRequestImpl &&
            (identical(other.query, query) || other.query == query) &&
            (identical(other.userLanguage, userLanguage) ||
                other.userLanguage == userLanguage) &&
            (identical(other.includeSources, includeSources) ||
                other.includeSources == includeSources) &&
            (identical(other.topK, topK) || other.topK == topK) &&
            (identical(other.optimizeQuery, optimizeQuery) ||
                other.optimizeQuery == optimizeQuery));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    query,
    userLanguage,
    includeSources,
    topK,
    optimizeQuery,
  );

  /// Create a copy of ChatRequest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ChatRequestImplCopyWith<_$ChatRequestImpl> get copyWith =>
      __$$ChatRequestImplCopyWithImpl<_$ChatRequestImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ChatRequestImplToJson(this);
  }
}

abstract class _ChatRequest implements ChatRequest {
  const factory _ChatRequest({
    required final String query,
    final String userLanguage,
    final bool includeSources,
    final int topK,
    final bool optimizeQuery,
  }) = _$ChatRequestImpl;

  factory _ChatRequest.fromJson(Map<String, dynamic> json) =
      _$ChatRequestImpl.fromJson;

  @override
  String get query;
  @override
  String get userLanguage;
  @override
  bool get includeSources;
  @override
  int get topK;
  @override
  bool get optimizeQuery;

  /// Create a copy of ChatRequest
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ChatRequestImplCopyWith<_$ChatRequestImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
