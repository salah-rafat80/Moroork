// dart format width=80
// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:get_it/get_it.dart' as _i174;
import 'package:injectable/injectable.dart' as _i526;
import 'package:traffic/core/api/api_client.dart' as _i827;
import 'package:traffic/core/api/token_storage.dart' as _i649;
import 'package:traffic/core/features/payment/data/repositories/payment_repository.dart'
    as _i535;
import 'package:traffic/core/features/payment/presentation/cubits/payment_cubit.dart'
    as _i478;
import 'package:traffic/core/theme/theme_cubit.dart' as _i487;
import 'package:traffic/features/auth/data/repositories/auth_repository.dart'
    as _i192;
import 'package:traffic/features/auth/presentation/cubits/auth_cubit.dart'
    as _i882;
import 'package:traffic/features/driving_license/data/repositories/driving_license_repository.dart'
    as _i296;
import 'package:traffic/features/driving_license/data/repositories/driving_renewal_repository.dart'
    as _i977;
import 'package:traffic/features/driving_license/presentation/cubits/driving_license_cubit.dart'
    as _i783;
import 'package:traffic/features/driving_license/presentation/cubits/driving_renewal_cubit.dart'
    as _i93;
import 'package:traffic/features/driving_license/presentation/cubits/driving_replacement_cubit.dart'
    as _i841;
import 'package:traffic/features/driving_license/presentation/screens/document_upload/widgets/first_license_booking_helper.dart'
    as _i840;
import 'package:traffic/features/examiner_dashboard/data/repositories/examiner_repository.dart'
    as _i624;
import 'package:traffic/features/examiner_dashboard/presentation/cubits/examiner_cubit.dart'
    as _i677;
import 'package:traffic/features/home/bloc/home_search_bloc.dart' as _i608;
import 'package:traffic/features/home/services/home_search_service.dart'
    as _i862;
import 'package:traffic/features/orders/data/repositories/service_requests_repository.dart'
    as _i1034;
import 'package:traffic/features/orders/presentation/cubits/my_orders_cubit.dart'
    as _i329;
import 'package:traffic/features/orders/presentation/cubits/order_details_cubit.dart'
    as _i1040;
import 'package:traffic/features/profile/data/repositories/profile_repository.dart'
    as _i1041;
import 'package:traffic/features/profile/presentation/cubits/change_password_cubit.dart'
    as _i590;
import 'package:traffic/features/profile/presentation/cubits/profile_cubit.dart'
    as _i313;
import 'package:traffic/features/smart_assistant/bloc/smart_assistant_chat_bloc.dart'
    as _i751;
import 'package:traffic/features/smart_assistant/data/datasources/smart_assistant_remote_data_source.dart'
    as _i460;
import 'package:traffic/features/smart_assistant/data/repositories/smart_assistant_repository_impl.dart'
    as _i45;
import 'package:traffic/features/smart_assistant/domain/repositories/smart_assistant_repository.dart'
    as _i25;
import 'package:traffic/features/vehicle_license/data/repositories/vehicle_license_repository.dart'
    as _i281;
import 'package:traffic/features/vehicle_license/presentation/cubits/vehicle_license_cubit.dart'
    as _i819;
import 'package:traffic/features/vehicle_license/presentation/cubits/vehicle_renewal_cubit.dart'
    as _i756;
import 'package:traffic/features/vehicle_license/presentation/cubits/vehicle_replacement_cubit.dart'
    as _i266;
import 'package:traffic/features/vehicle_license/violations_inquiry/data/repositories/vehicle_violation_license_repository.dart'
    as _i250;
import 'package:traffic/features/violations_inquiry/data/repositories/violations_repository.dart'
    as _i887;
import 'package:traffic/features/violations_inquiry/presentation/cubits/violations_cubit.dart'
    as _i296;

extension GetItInjectableX on _i174.GetIt {
  // initializes the registration of main-scope dependencies inside of GetIt
  _i174.GetIt init({
    String? environment,
    _i526.EnvironmentFilter? environmentFilter,
  }) {
    final gh = _i526.GetItHelper(this, environment, environmentFilter);
    gh.lazySingleton<_i649.TokenStorage>(() => _i649.TokenStorage());
    gh.lazySingleton<_i487.ThemeCubit>(() => _i487.ThemeCubit());
    gh.lazySingleton<_i862.HomeSearchService>(() => _i862.HomeSearchService());
    gh.lazySingleton<_i827.ApiClient>(
      () => _i827.ApiClient(gh<_i649.TokenStorage>()),
    );
    gh.lazySingleton<_i192.AuthRepository>(
      () =>
          _i192.AuthRepository(gh<_i827.ApiClient>(), gh<_i649.TokenStorage>()),
    );
    gh.lazySingleton<_i535.PaymentRepository>(
      () => _i535.PaymentRepository(gh<_i827.ApiClient>()),
    );
    gh.lazySingleton<_i296.DrivingLicenseRepository>(
      () => _i296.DrivingLicenseRepository(gh<_i827.ApiClient>()),
    );
    gh.lazySingleton<_i977.DrivingRenewalRepository>(
      () => _i977.DrivingRenewalRepository(gh<_i827.ApiClient>()),
    );
    gh.lazySingleton<_i624.ExaminerRepository>(
      () => _i624.ExaminerRepository(gh<_i827.ApiClient>()),
    );
    gh.lazySingleton<_i1034.ServiceRequestsRepository>(
      () => _i1034.ServiceRequestsRepository(gh<_i827.ApiClient>()),
    );
    gh.lazySingleton<_i1041.ProfileRepository>(
      () => _i1041.ProfileRepository(gh<_i827.ApiClient>()),
    );
    gh.lazySingleton<_i281.VehicleLicenseRepository>(
      () => _i281.VehicleLicenseRepository(gh<_i827.ApiClient>()),
    );
    gh.lazySingleton<_i250.VehicleViolationLicenseRepository>(
      () => _i250.VehicleViolationLicenseRepository(gh<_i827.ApiClient>()),
    );
    gh.lazySingleton<_i887.ViolationsRepository>(
      () => _i887.ViolationsRepository(gh<_i827.ApiClient>()),
    );
    gh.factory<_i783.DrivingLicenseCubit>(
      () => _i783.DrivingLicenseCubit(
        repository: gh<_i296.DrivingLicenseRepository>(),
        profileRepository: gh<_i1041.ProfileRepository>(),
      ),
    );
    gh.factory<_i841.DrivingReplacementCubit>(
      () => _i841.DrivingReplacementCubit(gh<_i296.DrivingLicenseRepository>()),
    );
    gh.factory<_i296.ViolationsCubit>(
      () => _i296.ViolationsCubit(gh<_i887.ViolationsRepository>()),
    );
    gh.factory<_i819.VehicleLicenseCubit>(
      () => _i819.VehicleLicenseCubit(
        gh<_i281.VehicleLicenseRepository>(),
        gh<_i1041.ProfileRepository>(),
      ),
    );
    gh.factory<_i608.HomeSearchBloc>(
      () => _i608.HomeSearchBloc(gh<_i862.HomeSearchService>()),
    );
    gh.factory<_i590.ChangePasswordCubit>(
      () => _i590.ChangePasswordCubit(gh<_i1041.ProfileRepository>()),
    );
    gh.factory<_i313.ProfileCubit>(
      () => _i313.ProfileCubit(gh<_i1041.ProfileRepository>()),
    );
    gh.lazySingleton<_i977.DrivingLicenseRenewalDataHandler>(
      () => _i977.DrivingLicenseRenewalDataHandler(
        gh<_i977.DrivingRenewalRepository>(),
      ),
    );
    gh.factory<_i266.VehicleReplacementCubit>(
      () => _i266.VehicleReplacementCubit(gh<_i281.VehicleLicenseRepository>()),
    );
    gh.factory<_i882.AuthCubit>(
      () => _i882.AuthCubit(
        authRepository: gh<_i192.AuthRepository>(),
        drivingLicenseRepository: gh<_i296.DrivingLicenseRepository>(),
      ),
    );
    gh.factory<_i677.ExaminerCubit>(
      () => _i677.ExaminerCubit(gh<_i624.ExaminerRepository>()),
    );
    gh.factory<_i756.VehicleRenewalCubit>(
      () => _i756.VehicleRenewalCubit(gh<_i281.VehicleLicenseRepository>()),
    );
    gh.factory<_i478.PaymentCubit>(
      () => _i478.PaymentCubit(gh<_i535.PaymentRepository>()),
    );
    gh.lazySingleton<_i460.SmartAssistantRemoteDataSource>(
      () => _i460.SmartAssistantRemoteDataSourceImpl(gh<_i827.ApiClient>()),
    );
    gh.factory<_i93.DrivingRenewalCubit>(
      () => _i93.DrivingRenewalCubit(
        dataHandler: gh<_i977.DrivingLicenseRenewalDataHandler>(),
        profileRepository: gh<_i1041.ProfileRepository>(),
      ),
    );
    gh.factory<_i329.MyOrdersCubit>(
      () => _i329.MyOrdersCubit(gh<_i1034.ServiceRequestsRepository>()),
    );
    gh.factory<_i840.FirstLicenseBookingHelper>(
      () => _i840.FirstLicenseBookingHelper(
        gh<_i977.DrivingLicenseRenewalDataHandler>(),
      ),
    );
    gh.factory<_i25.SmartAssistantRepository>(
      () => _i45.SmartAssistantRepositoryImpl(
        gh<_i460.SmartAssistantRemoteDataSource>(),
      ),
    );
    gh.factory<_i1040.OrderDetailsCubit>(
      () => _i1040.OrderDetailsCubit(
        gh<_i840.FirstLicenseBookingHelper>(),
        gh<_i1034.ServiceRequestsRepository>(),
      ),
    );
    gh.factory<_i751.SmartAssistantChatBloc>(
      () => _i751.SmartAssistantChatBloc(gh<_i25.SmartAssistantRepository>()),
    );
    return this;
  }
}
