import 'package:intl/intl.dart';

class InvoiceGenerator {
  InvoiceGenerator._();

  static String generate(int sequence) {
    final date = DateFormat('yyyyMMdd').format(DateTime.now());
    final seq  = sequence.toString().padLeft(4, '0');
    return 'INV-$date-$seq';
  }
}