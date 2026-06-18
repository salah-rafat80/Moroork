// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'welcoming_response.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

WelcomingResponse _$WelcomingResponseFromJson(Map<String, dynamic> json) {
  return _WelcomingResponse.fromJson(json);
}

/// @nodoc
mixin _$WelcomingResponse {
  String get message => throw _privateConstructorUsedError;
  String get status => throw _privateConstructorUsedError;

  /// Serializes this WelcomingResponse to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of WelcomingResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $WelcomingResponseCopyWith<WelcomingResponse> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $WelcomingResponseCopyWith<$Res> {
  factory $WelcomingResponseCopyWith(
    WelcomingResponse value,
    $Res Function(WelcomingResponse) then,
  ) = _$WelcomingResponseCopyWithImpl<$Res, WelcomingResponse>;
  @useResult
  $Res call({String message, String status});
}

/// @nodoc
class _$WelcomingResponseCopyWithImpl<$Res, $Val extends WelcomingResponse>
    implements $WelcomingResponseCopyWith<$Res> {
  _$WelcomingResponseCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of WelcomingResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? message = null, Object? status = null}) {
    return _then(
      _value.copyWith(
            message: null == message
                ? _value.message
                : message // ignore: cast_nullable_to_non_nullable
                      as String,
            status: null == status
                ? _value.status
                : status // ignore: cast_nullable_to_non_nullable
                      as String,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$WelcomingResponseImplCopyWith<$Res>
    implements $WelcomingResponseCopyWith<$Res> {
  factory _$$WelcomingResponseImplCopyWith(
    _$WelcomingResponseImpl value,
    $Res Function(_$WelcomingResponseImpl) then,
  ) = __$$WelcomingResponseImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String message, String status});
}

/// @nodoc
class __$$WelcomingResponseImplCopyWithImpl<$Res>
    extends _$WelcomingResponseCopyWithImpl<$Res, _$WelcomingResponseImpl>
    implements _$$WelcomingResponseImplCopyWith<$Res> {
  __$$WelcomingResponseImplCopyWithImpl(
    _$WelcomingResponseImpl _value,
    $Res Function(_$WelcomingResponseImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of WelcomingResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? message = null, Object? status = null}) {
    return _then(
      _$WelcomingResponseImpl(
        message: null == message
            ? _value.message
            : message // ignore: cast_nullable_to_non_nullable
                  as String,
        status: null == status
            ? _value.status
            : status // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$WelcomingResponseImpl implements _WelcomingResponse {
  const _$WelcomingResponseImpl({required this.message, required this.status});

  factory _$WelcomingResponseImpl.fromJson(Map<String, dynamic> json) =>
      _$$WelcomingResponseImplFromJson(json);

  @override
  final String message;
  @override
  final String status;

  @override
  String toString() {
    return 'WelcomingResponse(message: $message, status: $status)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$WelcomingResponseImpl &&
            (identical(other.message, message) || other.message == message) &&
            (identical(other.status, status) || other.status == status));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, message, status);

  /// Create a copy of WelcomingResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$WelcomingResponseImplCopyWith<_$WelcomingResponseImpl> get copyWith =>
      __$$WelcomingResponseImplCopyWithImpl<_$WelcomingResponseImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$WelcomingResponseImplToJson(this);
  }
}

abstract class _WelcomingResponse implements WelcomingResponse {
  const factory _WelcomingResponse({
    required final String message,
    required final String status,
  }) = _$WelcomingResponseImpl;

  factory _WelcomingResponse.fromJson(Map<String, dynamic> json) =
      _$WelcomingResponseImpl.fromJson;

  @override
  String get message;
  @override
  String get status;

  /// Create a copy of WelcomingResponse
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$WelcomingResponseImplCopyWith<_$WelcomingResponseImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
