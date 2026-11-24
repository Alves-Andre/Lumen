import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:home_widget/home_widget.dart';

import '../../../../core/database/app_database.dart';
import '../../../../core/utils/formatters.dart';
import '../../../bible/presentation/providers/bible_providers.dart';
import '../../../reading_plan/presentation/providers/plan_providers.dart';
import '../../../reading_plan/presentation/providers/reading_plan_providers.dart';
import '../../../recitatives/presentation/providers/recitatives_providers.dart';

/// Nome da classe Kotlin do widget (android/app/src/main/kotlin/.../DevocionalWidgetProvider.kt).
const _androidWidget = 'DevocionalWidgetProvider';

/// Widget só existe no Android. Testes sobrescrevem para `false` (sem plugin nativo).
final homeWidgetSupportedProvider = Provider<bool>(
  (ref) => !kIsWeb && defaultTargetPlatform == TargetPlatform.android,
);

/// Mantém o widget da tela inicial atualizado. Ativado pelo StartupGate.
final homeWidgetSyncProvider = Provider<void>((ref) {
  if (!ref.watch(homeWidgetSupportedProvider)) return;
  Timer? debounce;
  void schedule() {
    debounce?.cancel();
    debounce = Timer(const Duration(milliseconds: 600), () => unawaited(_push(ref)));
  }

  ref.listen(streakStatusProvider, (_, _) => schedule(), fireImmediately: true);
  ref.listen(continueReadingProvider, (_, _) => schedule());
  ref.listen(planProgressProvider, (_, _) => schedule());
  ref.listen(nextPendingRecitativeProvider, (_, _) => schedule());
  ref.onDispose(() => debounce?.cancel());
});

String _isoDay(DateTime d) =>
    '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

Future<void> _push(Ref ref) async {
  final streak = ref.read(streakStatusProvider).value;
  final cont = ref.read(continueReadingProvider).value;
  final plan = ref.read(planProgressProvider).value;
  final recitative = ref.read(nextPendingRecitativeProvider).value;
  final books = ref.read(allBooksProvider).value ?? const <Book>[];
  final bookNames = {for (final b in books) b.id: b.name};

  String? nextLabel;
  String? nextUri;
  final planNext = plan != null && plan.todayRemaining.isNotEmpty ? plan.todayRemaining.first : null;
  if (planNext != null && bookNames[planNext.bookId] != null) {
    nextLabel = 'Plano · ${bookNames[planNext.bookId]} ${planNext.chapter}';
    nextUri = WidgetLinks.reader(planNext.bookId, planNext.chapter, plan: true);
  } else if (cont != null) {
    nextLabel = 'Continuar: ${cont.label}';
    nextUri = WidgetLinks.reader(cont.book.id, cont.chapter);
  }

  String? recitativeLabel;
  String? recitativeUri;
  if (recitative != null) {
    final date = recitative.recitative.serviceDate;
    recitativeLabel = '${recitative.shortReference} · ${weekdayShort(date)}, ${date.day}/${date.month}';
    recitativeUri = WidgetLinks.recitative(recitative.recitative.id);
  }

  final days = streak?.currentStreak ?? 0;
  await Future.wait([
    HomeWidget.saveWidgetData<String>('streak', '$days'),
    HomeWidget.saveWidgetData<String>('streak_suffix', days == 1 ? 'dia' : 'dias'),
    HomeWidget.saveWidgetData<String>('shields', '${streak?.shields ?? 0}'),
    HomeWidget.saveWidgetData<String>('read_today_date', streak?.readToday == true ? _isoDay(DateTime.now()) : ''),
    HomeWidget.saveWidgetData<String>('next_label', nextLabel),
    HomeWidget.saveWidgetData<String>('next_uri', nextUri),
    HomeWidget.saveWidgetData<String>('recitative_label', recitativeLabel),
    HomeWidget.saveWidgetData<String>('recitative_uri', recitativeUri),
  ]);
  await HomeWidget.updateWidget(androidName: _androidWidget);
}

/// Links `devocional://…` usados pelos toques no widget.
abstract final class WidgetLinks {
  static String reader(int bookId, int chapter, {bool plan = false}) =>
      'devocional://ler?livro=$bookId&cap=$chapter${plan ? '&plano=1' : ''}';

  static String recitative(String id) => 'devocional://recitativo?id=$id';
}

/// Toque no widget com o app aberto ou fechado. Chama [open] com o link recebido.
StreamSubscription<Uri?>? listenWidgetLaunches(WidgetRef ref, void Function(Uri uri) open) {
  if (!ref.read(homeWidgetSupportedProvider)) return null;
  HomeWidget.initiallyLaunchedFromHomeWidget().then((uri) {
    if (uri != null) open(uri);
  });
  return HomeWidget.widgetClicked.listen((uri) {
    if (uri != null) open(uri);
  });
}
