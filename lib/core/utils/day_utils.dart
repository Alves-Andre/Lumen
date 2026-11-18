/// Funções de data "por dia de calendário", imunes a horário de verão.
library;

typedef Clock = DateTime Function();

/// Meia-noite local do dia de [d].
DateTime dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);

/// Soma [days] dias de calendário (aceita negativos).
DateTime addDays(DateTime d, int days) => DateTime(d.year, d.month, d.day + days);

/// Diferença em dias de calendário: positivo quando [to] é posterior a [from].
int daysBetween(DateTime from, DateTime to) => DateTime.utc(to.year, to.month, to.day)
    .difference(DateTime.utc(from.year, from.month, from.day))
    .inDays;

/// Domingo da semana de [d] (semana brasileira: domingo a sábado).
DateTime startOfWeek(DateTime d) => addDays(dateOnly(d), -(d.weekday % 7));

bool isSameDay(DateTime a, DateTime b) => a.year == b.year && a.month == b.month && a.day == b.day;

/// dd/MM/yyyy sem depender da inicialização de locale do `intl`.
String formatDateBr(DateTime d) {
  String two(int v) => v.toString().padLeft(2, '0');
  return '${two(d.day)}/${two(d.month)}/${d.year}';
}
