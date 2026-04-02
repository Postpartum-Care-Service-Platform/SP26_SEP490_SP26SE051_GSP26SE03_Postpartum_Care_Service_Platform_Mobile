import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/datasources/wallet_remote_datasource.dart';
import 'wallet_state.dart';

class WalletCubit extends Cubit<WalletState> {
  final WalletRemoteDataSource remoteDataSource;

  WalletCubit({required this.remoteDataSource}) : super(WalletInitial());

  Future<void> loadWallet() async {
    emit(WalletLoading());
    try {
      final walletResult = await remoteDataSource.getMyWallet();
      final transactionsResult = await remoteDataSource.getMyWalletTransactions();
      
      transactionsResult.sort((a, b) => (b.createdAt ?? DateTime.now()).compareTo(a.createdAt ?? DateTime.now()));
      
      emit(WalletLoaded(wallet: walletResult, transactions: transactionsResult));
    } catch (e) {
      emit(WalletError(e.toString()));
    }
  }
}
