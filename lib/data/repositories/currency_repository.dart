import '../models/currency_model.dart';
import '../providers/currency_api_provider.dart';

class CurrencyRepository {
  final CurrencyApiProvider _apiProvider = CurrencyApiProvider();

  Future<List<Currency>> getCurrencies() {
    return _apiProvider.fetchCurrencies();
  }
}
