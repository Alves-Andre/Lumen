import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../app/home_shell.dart';
import '../../features/bible/presentation/screens/bible_books_screen.dart';
import '../../features/bible/presentation/screens/bible_search_screen.dart';
import '../../features/bible/presentation/screens/chapter_grid_screen.dart';
import '../../features/bible/presentation/screens/reader_screen.dart';
import '../../features/bible/presentation/screens/retroactive_log_screen.dart';
import '../../features/dashboard/presentation/screens/today_screen.dart';
import '../../features/prayer/presentation/screens/progress_prayer_screen.dart';
import '../../features/reading_plan/presentation/screens/reading_plans_screen.dart';
import '../../features/reading_plan/presentation/screens/streak_history_screen.dart';
import '../../features/recitatives/presentation/screens/memorization_screen.dart';
import '../../features/recitatives/presentation/screens/recitative_detail_screen.dart';
import '../../features/recitatives/presentation/screens/recitative_form_screen.dart';
import '../../features/recitatives/presentation/screens/recitatives_screen.dart';
import '../../features/settings/presentation/screens/settings_screen.dart';

/// Caminhos das rotas. Telas de foco (leitura, treino, formulários) ficam fora
/// do shell para ocupar a tela inteira, sem a barra inferior.
abstract final class AppRoutes {
  static const today = '/hoje';
  static const bible = '/biblia';
  static const recitatives = '/recitativos';
  static const prayer = '/oracao';
  static const settings = '/configuracoes';
  static const streak = '/ofensiva';
  static const search = '/busca';
  static const plans = '/planos';
  static const retroactive = '/leitura-retroativa';
  static const newRecitative = '/recitativo/novo';

  static String book(int bookId) => '$bible/livro/$bookId';
  /// [continueSession]: veio de "Próximo capítulo"/"Anterior" e mantém a sessão de leitura.
  /// [verse]: versículo a destacar (vindo da busca). [plan]: leitura guiada pelo plano ativo.
  static String reader(int bookId, int chapter, {bool continueSession = false, int? verse, bool plan = false}) {
    final query = [
      if (continueSession) 'sessao=1',
      if (verse != null) 'v=$verse',
      if (plan) 'plano=1',
    ];
    return '/ler/$bookId/$chapter${query.isEmpty ? '' : '?${query.join('&')}'}';
  }
  static String recitative(int id) => '/recitativo/$id';
  static String editRecitative(int id) => '/recitativo/$id/editar';
  static String train(int id) => '/recitativo/$id/treino';

  static String newRecitativeFrom({required int bookId, required int chapter, required int verse}) =>
      '$newRecitative?livro=$bookId&cap=$chapter&v=$verse';
}

int _intParam(GoRouterState s, String name) => int.parse(s.pathParameters[name]!);

final routerProvider = Provider<GoRouter>((ref) {
  final router = GoRouter(
    initialLocation: AppRoutes.today,
    routes: [
      StatefulShellRoute.indexedStack(
        builder: (context, state, shell) => HomeShell(shell: shell),
        branches: [
          StatefulShellBranch(routes: [
            GoRoute(path: AppRoutes.today, builder: (_, _) => const TodayScreen()),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: AppRoutes.bible,
              builder: (_, _) => const BibleBooksScreen(),
              routes: [
                GoRoute(
                  path: 'livro/:bookId',
                  builder: (_, s) => ChapterGridScreen(bookId: _intParam(s, 'bookId')),
                ),
              ],
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(path: AppRoutes.recitatives, builder: (_, _) => const RecitativesScreen()),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(path: AppRoutes.prayer, builder: (_, _) => const ProgressPrayerScreen()),
          ]),
        ],
      ),
      GoRoute(
        path: '/ler/:bookId/:chapter',
        builder: (_, s) => ReaderScreen(
          // Uma tela nova por capítulo: sem a chave o go_router reaproveita o State
          // (e o botão ficaria preso em "Registrando…" ao avançar).
          key: ValueKey('ler-${s.pathParameters['bookId']}-${s.pathParameters['chapter']}'),
          bookId: _intParam(s, 'bookId'),
          chapter: _intParam(s, 'chapter'),
          continueSession: s.uri.queryParameters['sessao'] == '1',
          highlightVerse: int.tryParse(s.uri.queryParameters['v'] ?? ''),
          planMode: s.uri.queryParameters['plano'] == '1',
        ),
      ),
      GoRoute(path: AppRoutes.retroactive, builder: (_, _) => const RetroactiveLogScreen()),
      GoRoute(path: AppRoutes.settings, builder: (_, _) => const SettingsScreen()),
      GoRoute(path: AppRoutes.streak, builder: (_, _) => const StreakHistoryScreen()),
      GoRoute(path: AppRoutes.search, builder: (_, _) => const BibleSearchScreen()),
      GoRoute(path: AppRoutes.plans, builder: (_, _) => const ReadingPlansScreen()),
      GoRoute(
        path: AppRoutes.newRecitative,
        builder: (_, s) => RecitativeFormScreen(
          initialBookId: int.tryParse(s.uri.queryParameters['livro'] ?? ''),
          initialChapter: int.tryParse(s.uri.queryParameters['cap'] ?? ''),
          initialVerse: int.tryParse(s.uri.queryParameters['v'] ?? ''),
        ),
      ),
      GoRoute(
        path: '/recitativo/:id',
        builder: (_, s) => RecitativeDetailScreen(id: _intParam(s, 'id')),
        routes: [
          GoRoute(path: 'editar', builder: (_, s) => RecitativeFormScreen(editId: _intParam(s, 'id'))),
          GoRoute(path: 'treino', builder: (_, s) => MemorizationScreen(id: _intParam(s, 'id'))),
        ],
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      appBar: AppBar(),
      body: Center(child: Text('Página não encontrada: ${state.uri}')),
    ),
  );
  ref.onDispose(router.dispose);
  return router;
});
