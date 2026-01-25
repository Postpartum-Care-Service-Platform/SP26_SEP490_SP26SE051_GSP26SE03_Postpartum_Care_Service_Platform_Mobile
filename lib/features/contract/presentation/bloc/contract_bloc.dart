import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/get_contract_by_booking_id_usecase.dart';
import '../../domain/usecases/export_contract_pdf_usecase.dart';
import 'contract_event.dart';
import 'contract_state.dart';

/// Contract BLoC
class ContractBloc extends Bloc<ContractEvent, ContractState> {
  final GetContractByBookingIdUsecase getContractByBookingIdUsecase;
  final ExportContractPdfUsecase exportContractPdfUsecase;

  ContractBloc({
    required this.getContractByBookingIdUsecase,
    required this.exportContractPdfUsecase,
  }) : super(ContractInitial()) {
    on<ContractLoadByBookingId>(_onLoadByBookingId);
    on<ContractExportPdf>(_onExportPdf);
  }

  Future<void> _onLoadByBookingId(
    ContractLoadByBookingId event,
    Emitter<ContractState> emit,
  ) async {
    emit(ContractLoading());
    try {
      final contract = await getContractByBookingIdUsecase(event.bookingId);
      emit(ContractLoaded(contract));
    } catch (e) {
      emit(ContractError(e.toString()));
    }
  }

  Future<void> _onExportPdf(
    ContractExportPdf event,
    Emitter<ContractState> emit,
  ) async {
    emit(ContractLoading());
    try {
      final pdfBytes = await exportContractPdfUsecase(event.contractId);
      emit(ContractPdfExported(
        pdfBytes: pdfBytes,
        contractId: event.contractId,
      ));
    } catch (e) {
      emit(ContractError(e.toString()));
    }
  }
}
