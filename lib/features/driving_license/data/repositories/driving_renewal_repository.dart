import 'package:dio/dio.dart';

import '../../../../core/api/api_client.dart';
import '../../../../core/api/api_error_handler.dart';
import '../../../../core/api/api_result.dart';
import '../models/driving_renewal_model.dart';
import '../../../../core/api/request_id_manager.dart';
import '../../../../core/utils/date_time_formatter.dart';
import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';

@lazySingleton
class DrivingRenewalRepository {
  final ApiClient _apiClient;

  const DrivingRenewalRepository(this._apiClient);

  Future<ApiResult<List<LocationLookupModel>>> fetchGovernorates() async {
    try {
      final Response<Object?> response = await _apiClient.dio.get<Object?>('/governorates');
      final List<LocationLookupModel> items = _parseLocations(response.data);
      if (items.isEmpty) {
        return ApiResult<List<LocationLookupModel>>.failure(
          'تعذر تحميل المحافظات حالياً.',
        );
      }
      return ApiResult<List<LocationLookupModel>>.success(items);
    } on DioException catch (error) {
      ApiErrorHandler.logError('FetchGovernorates', error);
      return ApiResult<List<LocationLookupModel>>.failure(
        ApiErrorHandler.extractMessage(error, fallback: 'تعذر تحميل المحافظات.'),
      );
    } catch (_) {
      return ApiResult<List<LocationLookupModel>>.failure('حدث خطأ غير متوقع.');
    }
  }

  Future<ApiResult<List<LocationLookupModel>>> fetchTrafficUnits({
    required String governorateId,
  }) async {
    try {
      final Response<Object?> response = await _apiClient.dio.get<Object?>(
        '/governorates/$governorateId/traffic-units',
      );
      final List<LocationLookupModel> items = _parseLocations(response.data);
      if (items.isEmpty) {
        return ApiResult<List<LocationLookupModel>>.failure(
          'لا توجد وحدات مرور متاحة لهذه المحافظة.',
        );
      }
      return ApiResult<List<LocationLookupModel>>.success(items);
    } on DioException catch (error) {
      ApiErrorHandler.logError('FetchTrafficUnits', error);
      return ApiResult<List<LocationLookupModel>>.failure(
        ApiErrorHandler.extractMessage(error, fallback: 'تعذر تحميل وحدات المرور.'),
      );
    } catch (_) {
      return ApiResult<List<LocationLookupModel>>.failure('حدث خطأ غير متوقع.');
    }
  }

  Future<ApiResult<List<AppointmentSlotModel>>> fetchAvailableSlots({
    required DateTime date,
    required AppointmentType type,
    required String trafficUnitId,
  }) async {
    try {
      final Response<Object?> response = await _apiClient.dio.get<Object?>(
        '/appointments/available-slots',
        queryParameters: <String, Object?>{
          'date': _formatDate(date),
          'type': type.apiValue,
          'trafficUnitId': trafficUnitId,
        },
      );

      final List<AppointmentSlotModel> slots = _parseSlots(response.data)
          .where((AppointmentSlotModel slot) => slot.isAvailable)
          .toList(growable: false);

      return ApiResult<List<AppointmentSlotModel>>.success(slots);
    } on DioException catch (error) {
      ApiErrorHandler.logError('FetchAvailableSlots', error);
      return ApiResult<List<AppointmentSlotModel>>.failure(
        ApiErrorHandler.extractMessage(error, fallback: 'تعذر تحميل المواعيد المتاحة.'),
      );
    } catch (_) {
      return ApiResult<List<AppointmentSlotModel>>.failure('حدث خطأ غير متوقع.');
    }
  }

  Future<ApiResult<AppointmentBookingResponseModel>> bookAppointment({
    required AppointmentBookingRequestModel request,
  }) async {
    try {
      // Enforce Request ID for Booking
      final effectiveRequestNumber = request.requestNumber ?? RequestIdManager().currentRequestId;
      
      if (effectiveRequestNumber == null || effectiveRequestNumber.isEmpty) {
        debugPrint('BookAppointment: FAILED - Request ID is missing.');
        return ApiResult<AppointmentBookingResponseModel>.failure(
          'لا يمكن حجز موعد بدون رقم طلب. يرجى إتمام الخطوات السابقة أولاً.',
        );
      }

      debugPrint('BookAppointment: Sending Booking with Request ID = $effectiveRequestNumber');

      // Create a new request object with the effective request number
      final finalRequest = AppointmentBookingRequestModel(
        governorateId: request.governorateId,
        trafficUnitId: request.trafficUnitId,
        type: request.type,
        serviceTypeOverride: request.serviceTypeOverride,
        date: request.date,
        startTime: request.startTime,
        requestNumber: effectiveRequestNumber,
      );

      debugPrint('BookAppointment Request Body: ${finalRequest.toJson()}');

      final Response<Object?> response = await _apiClient.dio.post<Object?>(
        '/appointments/book',
        data: finalRequest.toJson(),
      );

      final AppointmentBookingResponseModel parsed =
          _parseBookingResponse(response.data);
          
      final extractedId = RequestIdManager().extractId(response.data);
      if (extractedId != null) {
        RequestIdManager().updateRequestId(extractedId);
      }

      if (parsed.serviceNumber.isEmpty || parsed.applicationId.isEmpty) {
        return ApiResult<AppointmentBookingResponseModel>.failure(
          'تم الحجز لكن لم يتم استلام بيانات الموعد كاملة.',
        );
      }

      return ApiResult<AppointmentBookingResponseModel>.success(parsed);
    } on DioException catch (error) {
      final String? errorCode = _extractErrorCode(error.response?.data);
      if (errorCode == 'INVALID_SERVICE_TYPE') {
        final ApiResult<AppointmentBookingResponseModel>? retryResult =
            await _retryBookWithServiceTypeFallbacks(request);
        if (retryResult != null) {
          return retryResult;
        }
      }

      ApiErrorHandler.logError('BookAppointment', error);
      return ApiResult<AppointmentBookingResponseModel>.failure(
        _mapBookingError(error),
      );
    } catch (_) {
      return ApiResult<AppointmentBookingResponseModel>.failure('حدث خطأ غير متوقع.');
    }
  }

  Future<ApiResult<AppointmentBookingResponseModel>?>
      _retryBookWithServiceTypeFallbacks(
    AppointmentBookingRequestModel request,
  ) async {
    final List<String> candidates = _serviceTypeCandidates(request.type);

    for (final String candidate in candidates) {
      if (candidate == request.serviceTypeOverride ||
          candidate == request.type.serviceTypeValue) {
        continue;
      }

      try {
        final AppointmentBookingRequestModel fallbackRequest =
            AppointmentBookingRequestModel(
          governorateId: request.governorateId,
          trafficUnitId: request.trafficUnitId,
          type: request.type,
          serviceTypeOverride: candidate,
          date: request.date,
          startTime: request.startTime,
          requestNumber: request.requestNumber,
        );

        debugPrint('BookAppointment Retry Body: ${fallbackRequest.toJson()}');

        final Response<Object?> retryResponse = await _apiClient.dio.post<Object?>(
          '/appointments/book',
          data: fallbackRequest.toJson(),
        );

        final AppointmentBookingResponseModel parsed =
            _parseBookingResponse(retryResponse.data);
        if (parsed.serviceNumber.isEmpty || parsed.applicationId.isEmpty) {
          return ApiResult<AppointmentBookingResponseModel>.failure(
            'تم الحجز لكن لم يتم استلام بيانات الموعد كاملة.',
          );
        }

        return ApiResult<AppointmentBookingResponseModel>.success(parsed);
      } on DioException catch (retryError) {
        ApiErrorHandler.logError('BookAppointmentRetryServiceType', retryError);
        if (_extractErrorCode(retryError.response?.data) !=
            'INVALID_SERVICE_TYPE') {
          return ApiResult<AppointmentBookingResponseModel>.failure(
            _mapBookingError(retryError),
          );
        }
      }
    }

    return null;
  }

  List<String> _serviceTypeCandidates(AppointmentType type) {
    switch (type) {
      case AppointmentType.medical:
        return const <String>['كشف طبي', 'Medical'];
      case AppointmentType.theory:
        return const <String>[
          'اختبار إشارات نظري',
          'إشارات',
          'Theory',
          'اختبار نظري',
        ];
      case AppointmentType.driving:
        return const <String>[
          'قيادة عملي',
          'اختبار قيادة عملي',
          'Driving',
          'فحص فني',
          'Technical',
        ];
      case AppointmentType.technical:
        return const <String>['فحص فني', 'Technical'];
    }
  }

  Future<ApiResult<RenewalResponseModel>> submitRenewalRequest({
    required RenewalRequestModel request,
  }) async {
    try {
      final FormData formData = FormData.fromMap(request.toJson());

      final Response<Object?> response = await _apiClient.dio.post<Object?>(
        '/DrivingLicense/renewal-request',
        data: formData,
        options: Options(contentType: 'multipart/form-data'),
      );

      final data = response.data;
      final extractedId = RequestIdManager().extractId(data);
      if (extractedId != null) {
        RequestIdManager().updateRequestId(extractedId);
        return ApiResult<RenewalResponseModel>.success(RenewalResponseModel(requestNumber: extractedId));
      }

      final RenewalResponseModel parsed = _parseRenewalResponse(data);
      if (parsed.requestNumber.isEmpty) {
        return ApiResult<RenewalResponseModel>.failure(
          'لم يتم استلام رقم طلب التجديد من الخادم.',
        );
      }

      return ApiResult<RenewalResponseModel>.success(parsed);
    } on DioException catch (error) {
      ApiErrorHandler.logError('DrivingRenewalRequest', error);
      return ApiResult<RenewalResponseModel>.failure(
        _mapRenewalError(error),
      );
    } catch (_) {
      return ApiResult<RenewalResponseModel>.failure('حدث خطأ غير متوقع.');
    }
  }

  RenewalResponseModel _parseRenewalResponse(Object? rawData) {
    if (rawData is Map<String, Object?>) {
      if (rawData['details'] is Map<String, Object?>) {
        return RenewalResponseModel.fromJson(
          rawData['details']! as Map<String, Object?>,
        );
      }
      return RenewalResponseModel.fromJson(rawData);
    }

    return const RenewalResponseModel(requestNumber: '');
  }

  Future<ApiResult<FinalizeRenewalResponseModel>> finalizeRenewal({
    required String requestNumber,
    required FinalizeRenewalRequestModel request,
  }) async {
    try {
      final Response<Object?> response = await _apiClient.dio.post<Object?>(
        '/DrivingLicense/finalize-renewal/$requestNumber',
        data: request.toJson(),
      );

      final FinalizeRenewalResponseModel parsed =
          _parseFinalizeRenewalResponse(response.data);
          
      final extractedId = RequestIdManager().extractId(response.data);
      if (extractedId != null) {
        RequestIdManager().updateRequestId(extractedId);
      }

      final bool hasRequestNumber = parsed.requestNumber.trim().isNotEmpty;
      final bool hasLicenseNumber = parsed.drivingLicenseNumber.trim().isNotEmpty;
      if (!hasRequestNumber && !hasLicenseNumber) {
        return ApiResult<FinalizeRenewalResponseModel>.failure(
          'لم يتم استلام بيانات الطلب بعد استكمال التجديد من الخادم.',
        );
      }

      return ApiResult<FinalizeRenewalResponseModel>.success(parsed);
    } on DioException catch (error) {
      ApiErrorHandler.logError('FinalizeRenewal', error);
      return ApiResult<FinalizeRenewalResponseModel>.failure(
        _mapFinalizeRenewalError(error),
      );
    } catch (_) {
      return ApiResult<FinalizeRenewalResponseModel>.failure(
        'حدث خطأ غير متوقع.',
      );
    }
  }

  FinalizeRenewalResponseModel _parseFinalizeRenewalResponse(Object? rawData) {
    if (rawData is Map<String, Object?>) {
      if (rawData['details'] is Map<String, Object?>) {
        return FinalizeRenewalResponseModel.fromJson(
          rawData['details']! as Map<String, Object?>,
        );
      }
      return FinalizeRenewalResponseModel.fromJson(rawData);
    }

    return const FinalizeRenewalResponseModel(
      id: 0,
      requestNumber: '',
      drivingLicenseNumber: '',
      category: '',
      governorate: '',
      licensingUnit: '',
      issueDate: '',
      expiryDate: '',
      status: '',
      citizenName: '',
    );
  }

  String _mapFinalizeRenewalError(DioException error) {
    final int? statusCode = error.response?.statusCode;
    if (statusCode == null) {
      return ApiErrorHandler.extractMessage(error);
    }

    const Map<int, String> statusMessages = <int, String>{
      400: 'بيانات استكمال التجديد غير صحيحة أو ناقصة.',
      401: 'يجب تسجيل الدخول لاستكمال طلب التجديد.',
      403: 'ليس لديك صلاحية لاستكمال خدمة تجديد رخصة القيادة.',
      404: 'لم يتم العثور على طلب التجديد المطلوب.',
      500: 'حدث خطأ في الخادم أثناء استكمال طلب التجديد.',
    };

    final String fallback = statusMessages[statusCode] ??
        'فشل استكمال طلب التجديد. (HTTP $statusCode)';

    return ApiErrorHandler.extractMessage(error, fallback: fallback);
  }

  String _mapRenewalError(DioException error) {
    final int? statusCode = error.response?.statusCode;
    if (statusCode == null) {
      return ApiErrorHandler.extractMessage(error);
    }

    // Renewal endpoint docs define success only; these are HTTP fallback meanings.
    const Map<int, String> statusMessages = <int, String>{
      400: 'بيانات طلب التجديد غير صحيحة أو ناقصة.',
      401: 'يجب تسجيل الدخول لإرسال طلب التجديد.',
      403: 'ليس لديك صلاحية لاستخدام خدمة تجديد رخصة القيادة.',
      404: 'لم يتم العثور على بيانات الرخصة المطلوبة للتجديد.',
      409: 'لا يمكن إنشاء طلب تجديد جديد بسبب تعارض مع حالة الطلب الحالي.',
      500: 'حدث خطأ في الخادم أثناء تنفيذ طلب التجديد.',
    };

    final String fallback = statusMessages[statusCode] ??
        'فشل إرسال طلب التجديد. (HTTP $statusCode)';

    return ApiErrorHandler.extractMessage(error, fallback: fallback);
  }

  List<LocationLookupModel> _parseLocations(Object? rawData) {
    final List<Object?> rows = _extractRows(rawData);
    return rows
        .whereType<Map<String, Object?>>()
        .map(LocationLookupModel.fromJson)
        .where((LocationLookupModel item) => item.id.isNotEmpty && item.name.isNotEmpty)
        .toList(growable: false);
  }

  List<AppointmentSlotModel> _parseSlots(Object? rawData) {
    final List<Object?> rows = _extractRows(rawData);
    final List<AppointmentSlotModel> mapped = <AppointmentSlotModel>[];

    for (final Object? row in rows) {
      if (row is String && row.isNotEmpty) {
        mapped.add(
          AppointmentSlotModel(
            startTime: row,
            endTime: null,
            isAvailable: true,
          ),
        );
      } else if (row is Map) {
        mapped.add(AppointmentSlotModel.fromJson(Map<String, Object?>.from(row)));
      }
    }

    return mapped
        .where((AppointmentSlotModel slot) => slot.startTime.isNotEmpty)
        .toList(growable: false);
  }

  AppointmentBookingResponseModel _parseBookingResponse(Object? rawData) {
    if (rawData is Map<String, Object?>) {
      if (rawData['details'] is Map<String, Object?>) {
        return AppointmentBookingResponseModel.fromJson(
          rawData['details']! as Map<String, Object?>,
        );
      }
      return AppointmentBookingResponseModel.fromJson(rawData);
    }

    return const AppointmentBookingResponseModel(
      serviceNumber: '',
      applicationId: '',
      date: '',
      startTime: '',
      status: '',
      type: '',
    );
  }

  List<Object?> _extractRows(Object? rawData) {
    if (rawData is List<Object?>) {
      return rawData;
    }

    if (rawData is Map<String, Object?>) {
      final Object? directData =
          rawData['details'] ?? rawData['data'] ?? rawData['items'] ?? rawData['result'];
      if (directData is List<Object?>) {
        return directData;
      }
      if (directData is Map<String, Object?>) {
        final Object? nestedData = directData['data'] ?? directData['slots'] ?? directData['items'];
        if (nestedData is List<Object?>) {
          return nestedData;
        }
      }
    }

    return const <Object?>[];
  }

  String _mapBookingError(DioException error) {
    final String? detailedMessage = _extractDetailedApiMessage(
      error.response?.data,
    );
    if (detailedMessage != null) {
      return detailedMessage;
    }

    final int? statusCode = error.response?.statusCode;
    final String? code = _extractErrorCode(error.response?.data);

    // API docs for POST /appointments/book define these explicit error codes.
    const Map<String, String> codeMessages = <String, String>{
      'BODY_MISSING': 'بيانات حجز الموعد ناقصة أو غير صحيحة.',
      'INVALID_FORMAT': 'صيغة التاريخ أو الوقت غير صحيحة.',
      'AUTH_ERROR': 'يجب تسجيل الدخول لحجز الموعد.',
      'AUTHZ_ERROR': 'ليس لديك صلاحية لحجز هذا النوع من المواعيد.',
      'SLOT_UNAVAILABLE': 'هذا الموعد لم يعد متاحاً، اختر موعداً آخر.',
      'CITIZEN_BOOKING_CONFLICT': 'لديك موعد آخر في نفس التاريخ والوقت.',
      'SYSTEM_ERROR': 'حدث خطأ في الخادم أثناء حجز الموعد.',
    };

    if (code != null && codeMessages.containsKey(code)) {
      return ApiErrorHandler.extractMessage(error, fallback: codeMessages[code]!);
    }

    const Map<int, String> statusMessages = <int, String>{
      400: 'بيانات حجز الموعد غير صحيحة.',
      401: 'يجب تسجيل الدخول لحجز الموعد.',
      403: 'ليس لديك صلاحية لحجز الموعد.',
      409: 'الموعد المحدد غير متاح حالياً.',
      500: 'حدث خطأ في الخادم أثناء حجز الموعد.',
    };

    final String fallback = statusMessages[statusCode] ?? 'تعذر إتمام حجز الموعد.';
    return ApiErrorHandler.extractMessage(error, fallback: fallback);
  }

  String? _extractDetailedApiMessage(Object? rawData) {
    if (rawData is! Map) {
      return null;
    }

    final String baseMessage =
        (rawData['message'] ?? rawData['error'] ?? '').toString().trim();
    final Object? rawDetails = rawData['details'];

    if (rawDetails is List) {
      final List<String> reasons = <String>[];
      for (final Object? item in rawDetails) {
        if (item is! Map) {
          continue;
        }

        final String field = (item['field'] ?? '').toString().trim();
        final String reason =
            (item['error'] ?? item['message'] ?? '').toString().trim();
        if (reason.isEmpty) {
          continue;
        }

        if (field.isNotEmpty) {
          reasons.add('$field: $reason');
        } else {
          reasons.add(reason);
        }
      }

      if (reasons.isNotEmpty) {
        if (baseMessage.isNotEmpty) {
          return '$baseMessage\n${reasons.join('\n')}';
        }
        return reasons.join('\n');
      }
    }

    if (baseMessage.isNotEmpty) {
      return baseMessage;
    }

    return null;
  }

  String? _extractErrorCode(Object? rawData) {
    if (rawData is Map) {
      final Object? rawCode = rawData['errorCode'] ?? rawData['code'];
      if (rawCode != null) {
        return rawCode.toString();
      }
    }
    return null;
  }

  String _formatDate(DateTime date) {
    final String month = date.month.toString().padLeft(2, '0');
    final String day = date.day.toString().padLeft(2, '0');
    return '${date.year}-$month-$day';
  }
}

/// Adapter that reads existing UI state snapshot and delegates API operations.

@lazySingleton
class DrivingLicenseRenewalDataHandler {
  final DrivingRenewalRepository _repository;

  const DrivingLicenseRenewalDataHandler(this._repository);

  Future<ApiResult<List<LocationLookupModel>>> fetchGovernoratesForUi() {
    return _repository.fetchGovernorates();
  }

  Future<ApiResult<List<LocationLookupModel>>> fetchTrafficUnitsForUi({
    required String governorateId,
  }) {
    return _repository.fetchTrafficUnits(governorateId: governorateId);
  }

  Future<ApiResult<List<AppointmentSlotModel>>> fetchSlotsForUi({
    required DateTime date,
    required AppointmentType type,
    required String trafficUnitId,
  }) {
    return _repository.fetchAvailableSlots(date: date, type: type, trafficUnitId: trafficUnitId);
  }

  Future<ApiResult<AppointmentBookingResponseModel>> bookAppointmentFromUi({
    required String governorateId,
    required String trafficUnitId,
    required DateTime date,
    required String selectedSlot,
    required AppointmentType type,
    String? requestNumber,
  }) {
    final AppointmentBookingRequestModel request = AppointmentBookingRequestModel(
      governorateId: governorateId,
      trafficUnitId: trafficUnitId,
      type: type,
      date: _formatDate(date),
      startTime: _extractStartTime(selectedSlot),
      requestNumber: requestNumber,
    );

    return _repository.bookAppointment(request: request);
  }

  Future<ApiResult<RenewalResponseModel>> submitRenewalFromUi({
    required RenewalUiSnapshot uiSnapshot,
  }) async {
    final RenewalRequestModel request = RenewalRequestModel.fromUiSnapshot(
      snapshot: uiSnapshot,
    );

    return _repository.submitRenewalRequest(request: request);
  }

  Future<ApiResult<FinalizeRenewalResponseModel>> finalizeRenewalFromUi({
    required String requestNumber,
    required int method,
    String? governorate,
    String? city,
    String? details,
  }) {
    FinalizeRenewalAddressModel? address;
    if (method == 2 && governorate != null && city != null && details != null) {
      address = FinalizeRenewalAddressModel(
        governorate: governorate,
        city: city,
        details: details,
      );
    }

    final FinalizeRenewalRequestModel request = FinalizeRenewalRequestModel(
      method: method,
      address: address,
    );

    return _repository.finalizeRenewal(
      requestNumber: requestNumber,
      request: request,
    );
  }

  String _formatDate(DateTime date) {
    final String month = date.month.toString().padLeft(2, '0');
    final String day = date.day.toString().padLeft(2, '0');
    return '${date.year}-$month-$day';
  }

  String _extractStartTime(String selectedSlot) {
    return DateTimeFormatter.extractRawStartTime(selectedSlot);
  }
}

