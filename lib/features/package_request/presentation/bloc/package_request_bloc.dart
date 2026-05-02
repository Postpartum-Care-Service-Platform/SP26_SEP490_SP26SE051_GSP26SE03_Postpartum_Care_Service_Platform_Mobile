import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/package_request_repository.dart';
import '../../../package/domain/entities/package_entity.dart';
import '../../../package/domain/repositories/package_repository.dart';
import '../../../care_plan/domain/repositories/care_plan_repository.dart';
import '../../../care_plan/domain/entities/care_plan_entity.dart';
import 'package_request_event.dart';
import 'package_request_state.dart';

class PackageRequestBloc
    extends Bloc<PackageRequestEvent, PackageRequestState> {
  final PackageRequestRepository repository;
  final PackageRepository packageRepository;
  final CarePlanRepository carePlanRepository;

  PackageRequestBloc({
    required this.repository,
    required this.packageRepository,
    required this.carePlanRepository,
  }) : super(PackageRequestInitial()) {
    on<LoadPackageRequests>(_onLoadPackageRequests);
    on<LoadPackageRequestDetail>(_onLoadDetail);
    on<CreatePackageRequestEvent>(_onCreate);
    on<ApprovePackageRequest>(_onApprove);
    on<RejectPackageRequest>(_onReject);
    on<RequestRevisionPackageRequest>(_onRequestRevision);
  }

  Future<void> _onLoadPackageRequests(
      LoadPackageRequests event, Emitter<PackageRequestState> emit) async {
    emit(PackageRequestLoading());
    try {
      final requests = await repository.getAll();
      
      // Try to load packages to map images, but don't fail if this part fails
      List<PackageEntity> packages = [];
      try {
        packages = await packageRepository.getPackages();
      } catch (e) {
        // Log or ignore image mapping error
      }

      // Map images from packages to requests
      final updatedRequests = requests.map((req) {
        final pkg = packages.where((p) => p.id == req.basePackageId).firstOrNull;
        if (pkg != null && pkg.imageUrl != null) {
          return req.copyWith(basePackageImageUrl: pkg.imageUrl);
        }
        return req;
      }).toList();

      emit(PackageRequestsLoaded(updatedRequests));
    } catch (e) {
      emit(PackageRequestError(e.toString()));
    }
  }

  Future<void> _onLoadDetail(
      LoadPackageRequestDetail event, Emitter<PackageRequestState> emit) async {
    emit(PackageRequestLoading());
    try {
      var request = await repository.getById(event.id);
      PackageEntity? customPackage;
      List<CarePlanEntity>? customCarePlans;
      
      // Try to load packages to map images
      try {
        final packages = await packageRepository.getPackages();
        final pkg =
            packages.where((p) => p.id == request.basePackageId).firstOrNull;
        if (pkg != null && pkg.imageUrl != null) {
          request = request.copyWith(basePackageImageUrl: pkg.imageUrl);
        }
      } catch (e) {
        // Ignore image mapping error
      }

      if (request.packageId != null) {
        try {
          customPackage = await packageRepository.getPackageById(request.packageId!);
          customCarePlans = await carePlanRepository.getCarePlanDetailsByPackage(request.packageId!);
        } catch (e) {
          // ignore custom package errors
        }
      }

      emit(PackageRequestDetailLoaded(
        request,
        customPackage: customPackage,
        customCarePlans: customCarePlans,
      ));
    } catch (e) {
      emit(PackageRequestError(e.toString()));
    }
  }

  Future<void> _onCreate(
      CreatePackageRequestEvent event, Emitter<PackageRequestState> emit) async {
    emit(PackageRequestActionLoading());
    try {
      final request = await repository.create(event.request);
      emit(PackageRequestCreated(request));
    } catch (e) {
      emit(PackageRequestError(e.toString()));
    }
    // Refresh the list
    add(const LoadPackageRequests());
  }

  Future<void> _onApprove(
      ApprovePackageRequest event, Emitter<PackageRequestState> emit) async {
    emit(PackageRequestActionLoading());
    try {
      await repository.approve(event.id);
      emit(const PackageRequestActionSuccess('Đã chấp nhận gói dịch vụ'));
    } catch (e) {
      emit(PackageRequestError(e.toString()));
    }
  }

  Future<void> _onReject(
      RejectPackageRequest event, Emitter<PackageRequestState> emit) async {
    emit(PackageRequestActionLoading());
    try {
      await repository.reject(event.id);
      emit(const PackageRequestActionSuccess('Đã từ chối gói dịch vụ'));
    } catch (e) {
      emit(PackageRequestError(e.toString()));
    }
  }

  Future<void> _onRequestRevision(RequestRevisionPackageRequest event,
      Emitter<PackageRequestState> emit) async {
    emit(PackageRequestActionLoading());
    try {
      await repository.requestRevision(event.id, event.feedback);
      emit(const PackageRequestActionSuccess('Đã gửi yêu cầu chỉnh sửa'));
    } catch (e) {
      emit(PackageRequestError(e.toString()));
    }
  }
}
