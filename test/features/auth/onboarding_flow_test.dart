import 'package:devocional/app/startup_gate.dart';
import 'package:devocional/core/database/app_database.dart';
import 'package:devocional/core/providers/app_providers.dart';
import 'package:devocional/core/providers/database_providers.dart';
import 'package:devocional/core/router/app_router.dart';
import 'package:devocional/core/settings/app_settings.dart';
import 'package:devocional/core/theme/app_theme.dart';
import 'package:devocional/features/auth/presentation/providers/auth_providers.dart';
import 'package:devocional/features/dashboard/presentation/providers/home_widget_sync.dart';
import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:material_ui/material_ui.dart';
import 'package:supabase_flutter/supabase_flutter.dart' show User;

const _userId = '33333333-3333-4333-8333-333333333333';

void main() {
  setUpAll(() => initializeDateFormatting('pt_BR'));

  testWidgets('primeiro login sem perfil: onboarding salva nome, idade e igreja e libera o app', (tester) async {
    // Tela de celular (o formulário inteiro visível).
    tester.view
      ..physicalSize = const Size(1080, 2400)
      ..devicePixelRatio = 2.5;
    addTearDown(tester.view.reset);
    final db = await tester.runAsync(() async {
      final db = AppDatabase.forTesting(NativeDatabase.memory());
      await db.into(db.books).insert(
            BooksCompanion.insert(id: const Value(1), name: 'Gênesis', abbrev: 'Gn', testament: 'AT', chaptersCount: 50),
          );
      return db;
    });
    addTearDown(db!.close);

    final container = ProviderContainer(
      overrides: [
        appDatabaseProvider.overrideWithValue(db),
        availableTranslationsProvider.overrideWith((ref) async => [BibleTranslation.arc]),
        homeWidgetSupportedProvider.overrideWithValue(false),
        notificationSyncProvider.overrideWith((ref) async {}),
        cloudEnabledProvider.overrideWithValue(true),
        authUserProvider.overrideWith(
          (ref) => Stream.value(const User(
            id: _userId,
            appMetadata: {},
            userMetadata: {},
            aud: 'authenticated',
            email: 'maria@exemplo.com',
            createdAt: '2026-11-23T10:00:00Z',
          )),
        ),
      ],
    );
    addTearDown(container.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp.router(
          theme: AppTheme.light(),
          routerConfig: container.read(routerProvider),
          builder: (context, child) => StartupGate(child: child!),
        ),
      ),
    );
    Future<void> settle() async {
      for (var i = 0; i < 8; i++) {
        await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 80)));
        await tester.pump(const Duration(milliseconds: 300));
      }
    }

    await settle();
    expect(find.text('Conte um pouco sobre você'), findsOneWidget);
    expect(find.text('Conta: maria@exemplo.com'), findsOneWidget);

    // Validação: nada preenchido.
    await tester.tap(find.text('COMEÇAR'));
    await tester.pump();
    expect(find.text('Informe seu nome.'), findsOneWidget);
    expect(find.text('Informe sua idade.'), findsOneWidget);

    await tester.enterText(find.widgetWithText(TextFormField, 'Nome'), 'Maria da Silva');
    await tester.enterText(find.widgetWithText(TextFormField, 'Idade'), '17');
    await tester.tap(find.text('Congregação Cristã no Brasil (CCB)'));
    await tester.pump();
    await tester.tap(find.text('COMEÇAR'));
    await settle();

    final profile = await tester.runAsync(() => db.syncDao.getProfile(_userId));
    expect(profile!.fullName, 'Maria da Silva');
    expect(profile.age, 17);
    expect(profile.churchName, 'Congregação Cristã no Brasil (CCB)');
    expect(profile.isSynced, isFalse, reason: 'sem nuvem disponível, fica pendente para enviar depois');
    expect(await tester.runAsync(() => db.settingsDao.getValue(AppSettings.kUserName)), 'Maria');

    // O app foi liberado (tela "Hoje").
    expect(find.text('Conte um pouco sobre você'), findsNothing);
    expect(find.textContaining('Maria'), findsWidgets);
  });
}
