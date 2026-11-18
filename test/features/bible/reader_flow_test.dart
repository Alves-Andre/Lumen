import 'package:devocional/core/database/app_database.dart';
import 'package:devocional/core/providers/database_providers.dart';
import 'package:devocional/core/router/app_router.dart';
import 'package:devocional/core/theme/app_theme.dart';
import 'package:devocional/features/bible/presentation/providers/bible_providers.dart';
import 'package:devocional/features/dashboard/presentation/providers/home_widget_sync.dart';
import 'package:drift/drift.dart' hide isNull;
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:material_ui/material_ui.dart';

Future<AppDatabase> _seededDb() async {
  final db = AppDatabase.forTesting(NativeDatabase.memory());
  await db.batch((b) {
    b.insert(
      db.books,
      const BooksCompanion(
        id: Value(1),
        name: Value('Gênesis'),
        abbrev: Value('Gn'),
        testament: Value('AT'),
        chaptersCount: Value(50),
      ),
    );
    b.insertAll(db.verses, [
      for (var c = 1; c <= 4; c++)
        VersesCompanion(
          bookId: const Value(1),
          chapter: Value(c),
          verse: const Value(1),
          verseText: Value('Texto $c.'),
        ),
    ]);
  });
  return db;
}

void main() {
  setUpAll(() => initializeDateFormatting('pt_BR'));

  test('describeSession agrupa por livro na ordem de leitura', () {
    const gn = Book(id: 1, name: 'Gênesis', abbrev: 'Gn', testament: 'AT', chaptersCount: 50);
    const ex = Book(id: 2, name: 'Êxodo', abbrev: 'Êx', testament: 'AT', chaptersCount: 40);
    expect(
      describeSession([(bookId: 1, chapter: 49), (bookId: 1, chapter: 50), (bookId: 2, chapter: 1)], {1: gn, 2: ex}),
      'Gênesis 49-50, Êxodo 1',
    );
  });

  testWidgets('"Concluir e ir para" registra cada capítulo; o resumo só aparece ao parar', (tester) async {
    final db = await tester.runAsync(_seededDb);
    addTearDown(db!.close);
    final container = ProviderContainer(
      overrides: [
        appDatabaseProvider.overrideWithValue(db),
        availableTranslationsProvider.overrideWith((ref) async => [BibleTranslation.arc]),
      homeWidgetSupportedProvider.overrideWithValue(false),
      ],
    );
    addTearDown(container.dispose);
    final router = container.read(routerProvider);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp.router(theme: AppTheme.light(), routerConfig: router),
      ),
    );
    // Deixa o banco (I/O real) responder entre os quadros do relógio simulado.
    // (Sem pumpAndSettle: o indicador de carregamento é uma animação infinita.)
    Future<void> settle() async {
      for (var i = 0; i < 8; i++) {
        await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 100)));
        await tester.pump(const Duration(milliseconds: 400));
      }
    }

    router.go(AppRoutes.reader(1, 1));
    await settle();

    Future<void> tapButton(String label) async {
      final finder = find.text(label.toUpperCase());
      await tester.ensureVisible(finder);
      await tester.tap(finder);
      await settle();
    }

    await tapButton('Concluir e ir para Gênesis 2');
    expect(find.text('Capítulo 2'), findsOneWidget);
    expect(find.textContaining('capítulos lidos!'), findsNothing); // sem comemoração no meio

    await tapButton('Concluir e ir para Gênesis 3');
    expect(find.text('Capítulo 3'), findsOneWidget);

    await tapButton('Concluir e parar');
    expect(find.text('3 capítulos lidos!'), findsOneWidget);
    expect(find.text('Gênesis 1-3'), findsOneWidget);

    final logs = await tester.runAsync(() => db.select(db.readingLogs).get());
    expect(logs!.map((l) => l.chapter).toList()..sort(), [1, 2, 3]);

    await tester.pumpWidget(const SizedBox.shrink());
  });
}
