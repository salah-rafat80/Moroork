import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/api/api_client.dart';
import '../../../../core/api/api_error_handler.dart';
import '../../../../core/api/api_result.dart';
import '../models/vehicle_license_model.dart';
import '../models/vehicle_license_finalize_model.dart';
import '../models/vehicle_type_model.dart';
import '../models/issue_replacement_response_model.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/api/request_id_manager.dart';
import '../../../driving_license/data/models/driving_renewal_model.dart';
import 'package:flutter/foundation.dart';

@lazySingleton
class VehicleLicenseRepository {
  final ApiClient _apiClient;

  VehicleLicenseRepository(this._apiClient);

  /// Fetches vehicle types from GET /VehicleTypes.
  /// Returns rich VehicleTypeModel list with cascading brands/models.
  Future<ApiResult<List<VehicleTypeModel>>> getVehicleTypes() async {
    try {
      final response = await _apiClient.dio.get('/VehicleTypes');
      final data = response.data;

      List<dynamic> items = [];
      if (data is List) {
        items = data;
      } else if (data is Map<String, dynamic> && data['details'] is List) {
        items = data['details'] as List;
      }

      if (items.isNotEmpty) {
        return ApiResult.success(
          items
              .map((e) => VehicleTypeModel.fromJson(e as Map<String, dynamic>))
              .toList(),
        );
      }

      return ApiResult.failure('لا توجد بيانات لأنواع المركبات');
    } on DioException catch (e) {
      ApiErrorHandler.logError('GetVehicleTypes', e);
      return ApiResult.failure(ApiErrorHandler.extractMessage(e));
    } catch (e) {
      return ApiResult.failure('حدث خطأ غير متوقع.');
    }
  }

  /// Fetches insurance companies from GET /VehicleLicense/insurance-companies.
  Future<ApiResult<List<InsuranceCompanyModel>>> getInsuranceCompanies() async {
    try {
      final response = await _apiClient.dio.get(
        '/VehicleLicense/insurance-companies',
      );
      final data = response.data;

      List<dynamic> items = [];
      if (data is List) {
        items = data;
      } else if (data is Map<String, dynamic>) {
        final details = data['details'];
        if (details is List) {
          items = details;
        }
      }

      return ApiResult.success(
        items
            .map((e) => InsuranceCompanyModel.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
    } on DioException catch (e) {
      ApiErrorHandler.logError('GetInsuranceCompanies', e);
      return ApiResult.failure(ApiErrorHandler.extractMessage(e));
    } catch (e) {
      return ApiResult.failure('حدث خطأ غير متوقع.');
    }
  }

  /// Requests the issuance of a replacement for a vehicle license.
  Future<ApiResult<IssueReplacementResponseModel>> issueReplacement({
    required String licenseNumber,
    required String replacementType,
    required int method,
    String? governorate,
    String? city,
    String? details,
  }) async {
    try {
      final Map<String, dynamic> body = {
        'replacementtype': replacementType,
        'replacementType': replacementType,
        'delivery': <String, dynamic>{
          'method': method,
        }
      };

      if (method == 2) {
        (body['delivery'] as Map<String, dynamic>)['address'] = {
          'governorate': governorate,
          'city': city,
          'details': details,
        };
      }

      final response = await _apiClient.dio.post(
        '/VehicleLicense/issue-replacement/$licenseNumber',
        data: body,
      );

      final data = response.data;
      if (data is Map<String, dynamic>) {
        final isSuccess = data['isSuccess'] as bool? ?? false;
        if (isSuccess && data['details'] != null && data['details'] is Map) {
          return ApiResult.success(IssueReplacementResponseModel.fromJson(data['details'] as Map<String, dynamic>));
        } else if (isSuccess) {
          return ApiResult.success(IssueReplacementResponseModel.fromJson(data));
        }
        
        // Handle fallback if data isn't wrapped
        if (!data.containsKey('isSuccess')) {
          return ApiResult.success(IssueReplacementResponseModel.fromJson(data));
        }
        
        return ApiResult.failure(data['message']?.toString() ?? 'لم يتم استلام تفاصيل طلب بدل الفاقد/التالف.');
      }

      return ApiResult.failure('استجابة غير متوقعة من الخادم.');
    } on DioException catch (e) {
      ApiErrorHandler.logError('IssueReplacement', e);
      return ApiResult.failure(ApiErrorHandler.extractMessage(e));
    } catch (e) {
      return ApiResult.failure('حدث خطأ غير متوقع.');
    }
  }

  /// Uploads documents for First-Time Vehicle License Issuance using multipart/form-data.
  Future<ApiResult<String>> uploadDocuments({
    required String vehicleType,
    required String brand,
    required String model,
    required String ownershipProofPath,
    required String vehicleDataCertificatePath,
    required String idCardPath,
    required String insuranceCompanyId,
    String? insuranceCertificatePath,
    String? customClearancePath,
  }) async {
    try {
      final dataMap = {
        'VehicleType': vehicleType,
        'Brand': brand,
        'Model': model,
        'OwnershipProof': await MultipartFile.fromFile(ownershipProofPath),
        'VehicleDataCertificate': await MultipartFile.fromFile(
          vehicleDataCertificatePath,
        ),
        'IdCard': await MultipartFile.fromFile(idCardPath),
        'InsuranceCompanyId': insuranceCompanyId,
      };

      if (insuranceCertificatePath != null &&
          insuranceCertificatePath.isNotEmpty) {
        dataMap['InsuranceCertificate'] = await MultipartFile.fromFile(
          insuranceCertificatePath,
        );
      }
      if (customClearancePath != null && customClearancePath.isNotEmpty) {
        dataMap['CustomClearance'] = await MultipartFile.fromFile(
          customClearancePath,
        );
      }

      final formData = FormData.fromMap(dataMap);

      final response = await _apiClient.dio.post(
        '/VehicleLicense/upload-documents',
        data: formData,
        options: Options(contentType: 'multipart/form-data'),
      );

      final data = response.data;
      if (data is Map<String, dynamic>) {
        final extractedId = RequestIdManager().extractId(data);
        if (extractedId != null) {
          RequestIdManager().updateRequestId(extractedId);
          return ApiResult.success(extractedId);
        }
      }

      return ApiResult.failure(
        'لم يتم استلام رقم الطلب. الرجاء المحاولة مرة أخرى.',
      );
    } on DioException catch (e) {
      ApiErrorHandler.logError('VehicleLicenseUploadDocuments', e);
      return ApiResult.failure(ApiErrorHandler.extractMessage(e));
    } catch (e) {
      return ApiResult.failure('حدث خطأ غير متوقع.');
    }
  }

  /// Finalizes the vehicle license application.
  Future<ApiResult<VehicleLicenseFinalizeResponseModel>> finalizeLicense({
    required String requestNumber,
    required int method, // 1 for pickup, 2 for home delivery
    String? governorate,
    String? city,
    String? details,
  }) async {
    try {
      final Map<String, dynamic> body = {'method': method};

      if (method == 2) {
        body['address'] = {
          'governorate': governorate,
          'city': city,
          'details': details,
        };
      }

      final response = await _apiClient.dio.post(
        '/VehicleLicense/finalize/$requestNumber',
        data: body,
      );

      final data = response.data;
      if (data is Map<String, dynamic>) {
        final isSuccess = data['isSuccess'] as bool? ?? false;
        if (isSuccess && data['details'] != null) {
          final details = data['details'] as Map<String, dynamic>? ?? {};

          // Extract and cache request number
          final extractedId = RequestIdManager().extractId(data);
          if (extractedId != null) {
            RequestIdManager().updateRequestId(extractedId);
          }

          // Build the finalize response
          final finalizeResponse = VehicleLicenseFinalizeResponseModel.fromJson(
            details,
          );

          // If requestNumber is empty in details, fall back to the one we sent
          return ApiResult.success(
            finalizeResponse.requestNumber.isEmpty
                ? VehicleLicenseFinalizeResponseModel(
                    requestNumber: requestNumber,
                    fees: finalizeResponse.fees,
                  )
                : finalizeResponse,
          );
        } else if (isSuccess) {
          return ApiResult.success(
            VehicleLicenseFinalizeResponseModel(
              requestNumber: requestNumber,
            ),
          );
        }

        return ApiResult.failure(
          data['message']?.toString() ?? 'لم يتم استلام بيانات الرخصة النهائية',
        );
      }

      return ApiResult.failure('لم يتم استلام بيانات الرخصة النهائية');
    } on DioException catch (e) {
      ApiErrorHandler.logError('FinalizeVehicleLicense', e);
      return ApiResult.failure(ApiErrorHandler.extractMessage(e));
    } catch (e) {
      return ApiResult.failure('حدث خطأ غير متوقع.');
    }
  }

  /// Renews a vehicle license.
  /// POST /VehicleLicense/renew (multipart/form-data with VehicleLicenseNumber)
  Future<ApiResult<IssueReplacementResponseModel>> renewVehicleLicense({
    required String licenseNumber,
  }) async {
    try {
      final formData = FormData.fromMap({
        'VehicleLicenseNumber': licenseNumber,
      });

      final response = await _apiClient.dio.post(
        '/VehicleLicense/renew',
        data: formData,
        options: Options(contentType: 'multipart/form-data'),
      );

      final data = response.data;
      if (data is Map<String, dynamic>) {
        final isSuccess = data['isSuccess'] as bool? ?? false;
        final details = data['details'];

        if (isSuccess && details != null && details is Map<String, dynamic>) {
          // Cache request number
          final extractedId = RequestIdManager().extractId(data);
          if (extractedId != null) {
            RequestIdManager().updateRequestId(extractedId);
          }
          return ApiResult.success(IssueReplacementResponseModel.fromJson(details));
        }

        if (data.containsKey('requestNumber')) {
          return ApiResult.success(IssueReplacementResponseModel.fromJson(data));
        }

        return ApiResult.failure(data['message']?.toString() ?? 'فشل طلب تجديد رخصة المركبة.');
      }

      return ApiResult.failure('استجابة غير متوقعة من الخادم.');
    } on DioException catch (e) {
      ApiErrorHandler.logError('RenewVehicleLicense', e);
      return ApiResult.failure(ApiErrorHandler.extractMessage(e));
    } catch (e) {
      return ApiResult.failure('حدث خطأ غير متوقع.');
    }
  }

  /// Finalizes the vehicle license renewal.
  /// POST /VehicleLicense/finalize-renewal/{requestNumber}
  Future<ApiResult<IssueReplacementResponseModel>> finalizeVehicleRenewal({
    required String requestNumber,
    required int method,
    String? governorate,
    String? city,
    String? details,
  }) async {
    try {
      final Map<String, dynamic> body = {'method': method};

      if (method == 2) {
        body['address'] = {
          'governorate': governorate,
          'city': city,
          'details': details,
        };
      }

      final response = await _apiClient.dio.post(
        '/VehicleLicense/finalize-renewal/$requestNumber',
        data: body,
      );

      final data = response.data;
      if (data is Map<String, dynamic>) {
        final isSuccess = data['isSuccess'] as bool? ?? false;
        final detailsData = data['details'];

        if (isSuccess && detailsData != null && detailsData is Map<String, dynamic>) {
          return ApiResult.success(IssueReplacementResponseModel.fromJson(detailsData));
        }

        if (data.containsKey('requestNumber')) {
          return ApiResult.success(IssueReplacementResponseModel.fromJson(data));
        }

        return ApiResult.failure(data['message']?.toString() ?? 'فشل استكمال تجديد رخصة المركبة.');
      }

      return ApiResult.failure('استجابة غير متوقعة من الخادم.');
    } on DioException catch (e) {
      ApiErrorHandler.logError('FinalizeVehicleRenewal', e);
      return ApiResult.failure(ApiErrorHandler.extractMessage(e));
    } catch (e) {
      return ApiResult.failure('حدث خطأ غير متوقع.');
    }
  }

  Future<ApiResult<AppointmentBookingResponseModel>> bookAppointment({
    required AppointmentBookingRequestModel request,
  }) async {
    try {
      // Enforce Request ID for Booking
      final effectiveRequestNumber = (request.requestNumber == null || request.requestNumber!.isEmpty)
          ? RequestIdManager().currentRequestId
          : request.requestNumber;
      
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

      final response = await _apiClient.dio.post(
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

        final retryResponse = await _apiClient.dio.post(
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

  String? _extractErrorCode(Object? rawData) {
    if (rawData is Map) {
      final Object? rawCode = rawData['errorCode'] ?? rawData['code'];
      if (rawCode != null) {
        return rawCode.toString();
      }
    }
    return null;
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

  Future<ApiResult<List<LocationLookupModel>>> fetchGovernorates() async {
    try {
      final response = await _apiClient.dio.get('/governorates');
      final data = response.data;
      if (data is Map<String, dynamic> && data['isSuccess'] == true) {
        final List<dynamic> details = data['details'] as List<dynamic>;
        return ApiResult.success(
          details
              .map((e) => LocationLookupModel.fromJson(e as Map<String, Object?>))
              .toList(),
        );
      }
      return ApiResult.failure('فشل تحميل المحافظات');
    } on DioException catch (e) {
      return ApiResult.failure(ApiErrorHandler.extractMessage(e));
    } catch (e) {
      return ApiResult.failure('حدث خطأ غير متوقع');
    }
  }

  Future<ApiResult<List<LocationLookupModel>>> fetchTrafficUnits(
      String governorateId) async {
    try {
      final response =
          await _apiClient.dio.get('/governorates/$governorateId/traffic-units');
      final data = response.data;
      if (data is Map<String, dynamic> && data['isSuccess'] == true) {
        final List<dynamic> details = data['details'] as List<dynamic>;
        return ApiResult.success(
          details
              .map((e) => LocationLookupModel.fromJson(e as Map<String, Object?>))
              .toList(),
        );
      }
      return ApiResult.failure('فشل تحميل وحدات المرور');
    } on DioException catch (e) {
      return ApiResult.failure(ApiErrorHandler.extractMessage(e));
    } catch (e) {
      return ApiResult.failure('حدث خطأ غير متوقع');
    }
  }

  Future<ApiResult<List<AppointmentSlotModel>>> fetchAvailableSlots(
      DateTime date, String type, String trafficUnitId) async {
    try {
      final dateStr =
          "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
      final response = await _apiClient.dio.get(
        '/appointments/available-slots',
        queryParameters: {'date': dateStr, 'type': type, 'trafficUnitId': trafficUnitId},
      );
      final data = response.data;
      if (data is Map<String, dynamic> && data['isSuccess'] == true) {
        final rawDetails = data['details'];
        List<dynamic> rawSlots = [];
        if (rawDetails is List) {
          rawSlots = rawDetails;
        } else if (rawDetails is Map) {
          final nestedData = rawDetails['data'] ?? rawDetails['slots'] ?? rawDetails['items'];
          if (nestedData is List) {
            rawSlots = nestedData;
          }
        }

        final List<AppointmentSlotModel> slots = [];
        for (final item in rawSlots) {
          if (item is String) {
            if (item.isNotEmpty) {
              slots.add(
                AppointmentSlotModel(
                  startTime: item,
                  endTime: null,
                  isAvailable: true,
                ),
              );
            }
          } else if (item is Map) {
            final parsed = AppointmentSlotModel.fromJson(Map<String, Object?>.from(item));
            if (parsed.startTime.isNotEmpty) {
              slots.add(parsed);
            }
          }
        }
        final filteredSlots = slots.where((slot) => slot.isAvailable).toList();
        return ApiResult.success(filteredSlots);
      }
      return ApiResult.failure('فشل تحميل المواعيد المتاحة');
    } on DioException catch (e) {
      return ApiResult.failure(ApiErrorHandler.extractMessage(e));
    } catch (e) {
      return ApiResult.failure('حدث خطأ غير متوقع');
    }
  }

  /// Fetches all vehicle licenses for the authenticated citizen.
  Future<ApiResult<List<VehicleLicenseModel>>> getMyLicenses() async {
    try {
      final response = await _apiClient.dio.get('/VehicleLicense/my-licenses');

      final data = response.data;

      if (data is Map<String, dynamic>) {
        final isSuccess = data['isSuccess'] as bool? ?? false;
        if (isSuccess && data['details'] != null && data['details'] is List) {
          final licenses = (data['details'] as List)
              .map(
                (item) =>
                    VehicleLicenseModel.fromJson(item as Map<String, dynamic>),
              )
              .toList();
          
          // Removed: repository.saveLicensesLocal(licenses);
          // We no longer store them locally per user request.

          return ApiResult.success(licenses);
        }
        return ApiResult.failure(
          data['message']?.toString() ?? 'حدث خطأ في استرجاع الرخص.',
        );
      }

      if (data is List) {
        final licenses = data
            .map(
              (item) =>
                  VehicleLicenseModel.fromJson(item as Map<String, dynamic>),
            )
            .toList();
        return ApiResult.success(licenses);
      }

      return ApiResult.success([]);
    } on DioException catch (e) {
      ApiErrorHandler.logError('GetMyVehicleLicenses', e);
      return ApiResult.failure(ApiErrorHandler.extractMessage(e));
    } catch (e) {
      return ApiResult.failure('حدث خطأ غير متوقع.');
    }
  }

  // --- Local Storage ---
  static const String _storageKey = 'cached_vehicle_licenses';

  Future<void> saveLicensesLocal(List<VehicleLicenseModel> licenses) async {
    final prefs = await SharedPreferences.getInstance();
    final String encoded = jsonEncode(licenses.map((l) => l.toJson()).toList());
    await prefs.setString(_storageKey, encoded);
  }

  Future<List<VehicleLicenseModel>> getLocalLicenses() async {
    final prefs = await SharedPreferences.getInstance();
    final String? encoded = prefs.getString(_storageKey);
    if (encoded == null || encoded.isEmpty) return [];

    try {
      final List<dynamic> decoded = jsonDecode(encoded);
      return decoded
          .map(
            (item) =>
                VehicleLicenseModel.fromJson(item as Map<String, dynamic>),
          )
          .toList();
    } catch (e) {
      return [];
    }
  }
}
