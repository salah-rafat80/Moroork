import 'package:dio/dio.dart';
import '../../../../core/api/api_client.dart';
import '../../../../core/api/api_error_handler.dart';
import '../../../../core/api/api_result.dart';
import '../models/staff_appointment_model.dart';
import 'package:injectable/injectable.dart';

@lazySingleton
class ExaminerRepository {
  final ApiClient _apiClient;
  ExaminerRepository(this._apiClient);

  Future<ApiResult<List<StaffAppointmentModel>>> getAppointments() async {
    try {
      final response = await _apiClient.dio.get('/Staff');
      final Map<String, dynamic>? data = response.data is Map<String, dynamic>
          ? response.data as Map<String, dynamic>
          : null;
      

      
      if (data != null && data['isSuccess'] == true) {
        final List list = data['details'] is List ? data['details'] as List : [];
        return ApiResult.success(
          list.map((e) => StaffAppointmentModel.fromJson(e as Map<String, dynamic>)).toList(),
        );
      }
      return ApiResult.failure('فشل في جلب البيانات');
    } on DioException catch (e) {
      ApiErrorHandler.logError('GetStaffAppointments', e);
      return ApiResult.failure(ApiErrorHandler.extractMessage(e));
    } catch (e) {
      return ApiResult.failure('حدث خطأ غير متوقع.');
    }
  }

  Future<ApiResult<void>> submitResult({
    required String requestNumber,
    required bool passed,
  }) async {
    try {
      final response = await _apiClient.dio.post(
        '/Staff/submit',
        data: {
          'RequestNumber': requestNumber,
          'passed': passed,
        },
      );
      
      final Map<String, dynamic>? data = response.data is Map<String, dynamic> 
          ? response.data as Map<String, dynamic> 
          : null;

      if (data != null && data['isSuccess'] == true) {
        return ApiResult.success();
      }
      return ApiResult.failure(data?['message']?.toString() ?? 'فشل في إرسال النتيجة');
    } on DioException catch (e) {
      ApiErrorHandler.logError('SubmitStaffResult', e);
      return ApiResult.failure(ApiErrorHandler.extractMessage(e));
    } catch (e) {
      return ApiResult.failure('حدث خطأ غير متوقع.');
    }
  }
}
