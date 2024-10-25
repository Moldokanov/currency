import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../data/models/currency_model.dart';

class CurrencyListItem extends StatefulWidget {
  final List<Currency> currencies;

  const CurrencyListItem({required this.currencies});

  @override
  _CurrencyListItemState createState() => _CurrencyListItemState();
}

class _CurrencyListItemState extends State<CurrencyListItem> {
  Currency? _selectedCurrency1;
  Currency? _selectedCurrency2;
  TextEditingController _amountController = TextEditingController();
  String _convertedAmount = '';
  bool _showChart = true;

  @override
  void initState() {
    super.initState();
    if (widget.currencies.isNotEmpty) {
      _selectedCurrency1 = widget.currencies[0];
      _selectedCurrency2 = widget.currencies.length > 1
          ? widget.currencies[1]
          : widget.currencies[0];
    }
  }

  void _convertAmount() {
    if (_selectedCurrency1 != null &&
        _selectedCurrency2 != null &&
        _amountController.text.isNotEmpty) {
      double amount = double.tryParse(_amountController.text) ?? 0.0;
      double rate1 = _selectedCurrency1!.rate;
      double rate2 = _selectedCurrency2!.rate;

      double convertedValue = (amount / rate1) * rate2;

      setState(() {
        _convertedAmount =
            '${_amountController.text} ${_selectedCurrency1!.code} = ${convertedValue.toStringAsFixed(2)} ${_selectedCurrency2!.code}';
      });
    } else {
      setState(() {
        _convertedAmount = '';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_selectedCurrency1 != null &&
        !widget.currencies.contains(_selectedCurrency1)) {
      _selectedCurrency1 = widget.currencies[0];
    }

    if (_selectedCurrency2 != null &&
        !widget.currencies.contains(_selectedCurrency2)) {
      _selectedCurrency2 = widget.currencies.length > 1
          ? widget.currencies[1]
          : widget.currencies[0];
    }

    return Card(
      margin: EdgeInsets.symmetric(vertical: 6, horizontal: 8),
      elevation: 2,
      child: Column(
        children: [
          ListTile(
            leading: CircleAvatar(
              backgroundColor: Theme.of(context).primaryColor,
              child: Text(
                _selectedCurrency1?.code.substring(0, 1) ?? '',
                style: TextStyle(color: Colors.white),
              ),
            ),
            title: Text(
              '${_selectedCurrency1?.code ?? ''} - ${_selectedCurrency2?.code ?? ''}',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).textTheme.bodyText1!.color,
              ),
            ),
            subtitle: Text(
              'Курс: ${_selectedCurrency1?.rate.toStringAsFixed(2) ?? ''} - ${_selectedCurrency2?.rate.toStringAsFixed(2) ?? ''}',
              style: TextStyle(
                color: Theme.of(context).textTheme.bodyText2!.color,
              ),
            ),
          ),
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: TextField(
              controller: _amountController,
              decoration: InputDecoration(
                labelText: 'Введите сумму в ${_selectedCurrency1?.code ?? ''}',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              onChanged: (value) => _convertAmount(),
            ),
          ),
          if (_convertedAmount.isNotEmpty)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                _convertedAmount,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).primaryColor,
                ),
              ),
            ),
          if (_showChart &&
              _selectedCurrency1 != null &&
              _selectedCurrency2 != null &&
              _selectedCurrency1!.historyRates.isNotEmpty &&
              _selectedCurrency2!.historyRates.isNotEmpty)
            Container(
              height: 200,
              padding: EdgeInsets.all(8.0),
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    getDrawingHorizontalLine: (value) {
                      return FlLine(
                        color: Colors.grey.withOpacity(0.2),
                        strokeWidth: 1,
                      );
                    },
                  ),
                  borderData: FlBorderData(
                    show: true,
                    border: Border.all(
                      color: Theme.of(context).primaryColor.withOpacity(0.5),
                      width: 1,
                    ),
                  ),
                  titlesData: FlTitlesData(
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          return Text(
                            'День ${value.toInt() + 1}',
                            style: TextStyle(
                              color: Theme.of(context)
                                  .textTheme
                                  .bodyText2!
                                  .color
                                  ?.withOpacity(0.6),
                              fontSize: 10,
                            ),
                          );
                        },
                        reservedSize: 22,
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          return Text(
                            value.toStringAsFixed(2),
                            style: TextStyle(
                              color: Theme.of(context)
                                  .textTheme
                                  .bodyText2!
                                  .color
                                  ?.withOpacity(0.6),
                              fontSize: 10,
                            ),
                          );
                        },
                        reservedSize: 40,
                      ),
                    ),
                    rightTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    topTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                  ),
                  lineBarsData: [
                    LineChartBarData(
                      spots: _selectedCurrency1!.historyRates
                          .asMap()
                          .entries
                          .map((entry) =>
                              FlSpot(entry.key.toDouble(), entry.value))
                          .toList(),
                      isCurved: true,
                      color: Colors.blue,
                      barWidth: 3,
                      dotData: FlDotData(show: false),
                      belowBarData: BarAreaData(
                        show: true,
                        color: Colors.blue.withOpacity(0.2),
                      ),
                    ),
                    LineChartBarData(
                      spots: _selectedCurrency2!.historyRates
                          .asMap()
                          .entries
                          .map((entry) =>
                              FlSpot(entry.key.toDouble(), entry.value))
                          .toList(),
                      isCurved: true,
                      color: Colors.red,
                      barWidth: 3,
                      dotData: FlDotData(show: false),
                      belowBarData: BarAreaData(
                        show: true,
                        color: Colors.red.withOpacity(0.2),
                      ),
                    ),
                  ],
                  minY: [
                        _selectedCurrency1!.historyRates.reduce(
                            (value, element) =>
                                value < element ? value : element),
                        _selectedCurrency2!.historyRates.reduce(
                            (value, element) =>
                                value < element ? value : element),
                      ].reduce((value, element) =>
                          value < element ? value : element) -
                      1,
                  maxY: [
                        _selectedCurrency1!.historyRates.reduce(
                            (value, element) =>
                                value > element ? value : element),
                        _selectedCurrency2!.historyRates.reduce(
                            (value, element) =>
                                value > element ? value : element),
                      ].reduce((value, element) =>
                          value > element ? value : element) +
                      1,
                ),
              ),
            )
          else if (_showChart)
            Padding(
              padding: EdgeInsets.all(8.0),
              child: Text(
                'Нет доступных исторических данных',
                style: TextStyle(
                  color: Theme.of(context).textTheme.bodyText2!.color,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
