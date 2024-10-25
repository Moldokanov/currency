import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/models/currency_model.dart';
import '../../data/repositories/currency_repository.dart';
import '../../logic/bloc/currency_bloc.dart';
import '../widgets/currency_list_item.dart';

class HomeScreen extends StatefulWidget {
  final Function toggleTheme;
  final bool isDarkTheme;

  const HomeScreen({required this.toggleTheme, required this.isDarkTheme});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Currency? selectedCurrency1;
  Currency? selectedCurrency2;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          CurrencyBloc(CurrencyRepository())..add(FetchCurrencies()),
      child: Scaffold(
        appBar: AppBar(
          title: Text('Курсы валют'),
          actions: [
            IconButton(
              icon:
                  Icon(widget.isDarkTheme ? Icons.light_mode : Icons.dark_mode),
              onPressed: () => widget.toggleTheme(),
            ),
          ],
        ),
        body: BlocBuilder<CurrencyBloc, CurrencyState>(
          builder: (context, state) {
            if (state is CurrencyLoading) {
              return Center(child: CircularProgressIndicator());
            } else if (state is CurrencyLoaded) {
              return Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: DropdownButton<Currency>(
                            isExpanded: true,
                            hint: Text('Выберите валюту 1'),
                            value: selectedCurrency1,
                            onChanged: (currency) {
                              setState(() {
                                selectedCurrency1 = currency;
                              });
                            },
                            items: state.currencies.map((currency) {
                              return DropdownMenuItem(
                                value: currency,
                                child: Text(currency.code),
                              );
                            }).toList(),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: DropdownButton<Currency>(
                            isExpanded: true,
                            hint: Text('Выберите валюту 2'),
                            value: selectedCurrency2,
                            onChanged: (currency) {
                              setState(() {
                                selectedCurrency2 = currency;
                              });
                            },
                            items: state.currencies.map((currency) {
                              return DropdownMenuItem(
                                value: currency,
                                child: Text(currency.code),
                              );
                            }).toList(),
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (selectedCurrency1 != null && selectedCurrency2 != null)
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: CurrencyListItem(
                        currencies: [selectedCurrency1!, selectedCurrency2!],
                      ),
                    ),
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.all(16.0),
                      itemCount: state.currencies.length,
                      itemBuilder: (context, index) {
                        return CurrencyListItem(
                          currencies: [state.currencies[index]],
                        );
                      },
                    ),
                  ),
                ],
              );
            } else if (state is CurrencyError) {
              return Center(child: Text(state.message));
            } else {
              return Container();
            }
          },
        ),
      ),
    );
  }
}
