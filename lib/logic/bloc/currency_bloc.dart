import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repositories/currency_repository.dart';
import '../../data/models/currency_model.dart';

abstract class CurrencyEvent {}

class FetchCurrencies extends CurrencyEvent {}

abstract class CurrencyState {}

class CurrencyLoading extends CurrencyState {}

class CurrencyLoaded extends CurrencyState {
  final List<Currency> currencies;

  CurrencyLoaded(this.currencies);
}

class CurrencyError extends CurrencyState {
  final String message;

  CurrencyError(this.message);
}

class CurrencyBloc extends Bloc<CurrencyEvent, CurrencyState> {
  final CurrencyRepository _repository;

  CurrencyBloc(this._repository) : super(CurrencyLoading()) {
    on<FetchCurrencies>(_onFetchCurrencies);
  }

  Future<void> _onFetchCurrencies(
      FetchCurrencies event, Emitter<CurrencyState> emit) async {
    emit(CurrencyLoading());
    try {
      final currencies = await _repository.getCurrencies();
      emit(CurrencyLoaded(currencies));
    } catch (e) {
      print('Ошибка: $e');
      emit(CurrencyError('Не удалось получить валюты: $e'));
    }
  }
}
