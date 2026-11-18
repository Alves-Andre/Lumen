import 'package:intl/intl.dart';

import 'day_utils.dart';

final _fullDate = DateFormat("EEEE, d 'de' MMMM 'de' y", 'pt_BR');
final _shortDate = DateFormat("d 'de' MMM", 'pt_BR');
final _monthYear = DateFormat('MMMM y', 'pt_BR');
final _weekdayShort = DateFormat('EEE', 'pt_BR');

String capitalize(String s) => s.isEmpty ? s : '${s[0].toUpperCase()}${s.substring(1)}';

/// "Domingo, 22 de novembro de 2026".
String fullDate(DateTime d) => capitalize(_fullDate.format(d));

/// "22 de nov."
String shortDate(DateTime d) => _shortDate.format(d);

/// "Novembro 2026".
String monthYear(DateTime d) => capitalize(_monthYear.format(d));

String weekdayShort(DateTime d) => capitalize(_weekdayShort.format(d));

/// "hoje", "amanhã", "em 4 dias", "ontem", "há 3 dias".
String relativeDay(DateTime date, [DateTime? now]) {
  final diff = daysBetween(now ?? DateTime.now(), date);
  return switch (diff) {
    0 => 'hoje',
    1 => 'amanhã',
    -1 => 'ontem',
    > 1 => 'em $diff dias',
    _ => 'há ${-diff} dias',
  };
}

/// "1.189".
String thousands(int v) => NumberFormat.decimalPattern('pt_BR').format(v);

String greeting([DateTime? now]) {
  final h = (now ?? DateTime.now()).hour;
  if (h < 12) return 'Bom dia';
  if (h < 18) return 'Boa tarde';
  return 'Boa noite';
}
