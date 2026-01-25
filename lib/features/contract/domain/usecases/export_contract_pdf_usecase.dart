import '../repositories/contract_repository.dart';

/// Use case to export contract as PDF
class ExportContractPdfUsecase {
  final ContractRepository repository;

  ExportContractPdfUsecase(this.repository);

  Future<List<int>> call(int contractId) async {
    return await repository.exportContractPdf(contractId);
  }
}
