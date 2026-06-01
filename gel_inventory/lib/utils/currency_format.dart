import 'package:intl/intl.dart';

final _currencyFmt = NumberFormat.currency(symbol: '₱', decimalDigits: 2);
final _numberFmt = NumberFormat('#,##0.##');

String formatCurrency(double amount) => _currencyFmt.format(amount);
String formatNumber(num value) => _numberFmt.format(value);
