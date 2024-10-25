import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/currency_model.dart';

class CurrencyApiProvider {
  final String _baseUrl = 'https://api.exchangerate-api.com/v4/latest/KGS';
  final String _historyKey = 'currency_history';

  Future<List<Currency>> fetchCurrencies() async {
    try {
      final response = await http.get(Uri.parse(_baseUrl));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);

        if (data.containsKey('rates') &&
            data['rates'] is Map<String, dynamic>) {
          final rates = data['rates'] as Map<String, dynamic>;

          final List<Currency> currencies = rates.entries.map((entry) {
            return Currency(
              code: entry.key,
              name: entry.key,
              rate: double.tryParse(entry.value.toString()) ?? 0.0,
              historyRates: [],
            );
          }).toList();

          await _saveCurrenciesToLocal(rates);
          return _loadCurrenciesWithHistory(currencies);
        } else {
          throw Exception(
              'Неверный формат данных: ставки должны быть в формате Map');
        }
      } else {
        throw Exception('Не удалось загрузить данные: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Ошибка при получении валют: $e');
    }
  }

  Future<void> _saveCurrenciesToLocal(Map<String, dynamic> rates) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? jsonString = prefs.getString(_historyKey);

    Map<String, List<double>> history = jsonString != null
        ? Map<String, List<double>>.from(
            json.decode(jsonString).map((key, value) => MapEntry(
                  key,
                  List<double>.from(value.map((e) => e.toDouble())),
                )),
          )
        : {};

    rates.forEach((code, rate) {
      final double parsedRate = double.tryParse(rate.toString()) ?? 0.0;

      if (!history.containsKey(code)) {
        history[code] = [];
      }

      history[code]!.add(parsedRate);

      if (history[code]!.length > 7) {
        history[code] = history[code]!.sublist(history[code]!.length - 7);
      }
    });

    prefs.setString(_historyKey, json.encode(history));
  }

  Future<List<Currency>> _loadCurrenciesWithHistory(
      List<Currency> currencies) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? jsonString = prefs.getString(_historyKey);

    if (jsonString != null) {
      final Map<String, dynamic> historyData = json.decode(jsonString);

      return currencies.map((currency) {
        final List<dynamic> ratesList =
            historyData[currency.code] as List<dynamic>? ?? [];

        final List<double> historyRates =
            ratesList.map((e) => double.tryParse(e.toString()) ?? 0.0).toList();

        return Currency(
          code: currency.code,
          name: currency.name,
          rate: currency.rate,
          historyRates: historyRates,
        );
      }).toList();
    } else {
      return currencies;
    }
  }
}
