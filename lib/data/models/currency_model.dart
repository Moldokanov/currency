class Currency {
  final String code;
  final String name;
  final double rate;
  final List<double> historyRates;

  Currency({
    required this.code,
    required this.name,
    required this.rate,
    required this.historyRates,
  });

  factory Currency.fromJson(Map<String, dynamic> json) {
    return Currency(
      code: json['code'],
      name: json['name'],
      rate: json['rate'].toDouble(),
      historyRates: List<double>.from(json['historyRates'] ?? []),
    );
  }
}
