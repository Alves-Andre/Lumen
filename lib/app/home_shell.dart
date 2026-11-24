import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../core/router/app_router.dart';
import '../core/theme/duo_colors.dart';
import '../features/dashboard/presentation/providers/home_widget_sync.dart';
import '../features/reading_plan/presentation/providers/reading_plan_providers.dart';
import '../features/recitatives/presentation/providers/recitatives_providers.dart';

/// Estrutura das 4 abas, com barra inferior no estilo Duolingo.
class HomeShell extends ConsumerStatefulWidget {
  const HomeShell({super.key, required this.shell});

  final StatefulNavigationShell shell;

  @override
  ConsumerState<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends ConsumerState<HomeShell> {
  late final AppLifecycleListener _lifecycle;
  StreamSubscription<Uri?>? _widgetLaunches;

  @override
  void initState() {
    super.initState();
    // Ofensiva, projeção e lembranças dependem do dia: recalcula ao voltar ao app.
    _lifecycle = AppLifecycleListener(onResume: () {
      ref
        ..invalidate(streakStatusProvider)
        ..invalidate(readingProjectionProvider)
        ..invalidate(weekActivityProvider)
        ..invalidate(recitativeMemoriesProvider)
        ..invalidate(nextPendingRecitativeProvider);
    });
    _widgetLaunches = listenWidgetLaunches(ref, _openFromWidget);
  }

  /// Abre a tela pedida por um toque no widget da tela inicial.
  void _openFromWidget(Uri uri) {
    if (!mounted) return;
    final q = uri.queryParameters;
    switch (uri.host) {
      case 'ler':
        final book = int.tryParse(q['livro'] ?? '');
        final chapter = int.tryParse(q['cap'] ?? '');
        if (book != null && chapter != null) {
          context.push(AppRoutes.reader(book, chapter, plan: q['plano'] == '1'));
        }
      case 'recitativo':
        final id = q['id'];
        if (id != null && id.isNotEmpty) context.push(AppRoutes.recitative(id));
      default:
        widget.shell.goBranch(0);
    }
  }

  @override
  void dispose() {
    _widgetLaunches?.cancel();
    _lifecycle.dispose();
    super.dispose();
  }

  void _select(int index) =>
      widget.shell.goBranch(index, initialLocation: index == widget.shell.currentIndex);

  @override
  Widget build(BuildContext context) {
    final c = DuoColors.of(context);
    const items = [
      (Icons.home_rounded, 'Hoje'),
      (Icons.menu_book_rounded, 'Bíblia'),
      (Icons.record_voice_over_rounded, 'Recitativos'),
      (Icons.volunteer_activism_rounded, 'Oração'),
    ];
    return Scaffold(
      body: widget.shell,
      bottomNavigationBar: DecoratedBox(
        decoration: BoxDecoration(
          color: c.background,
          border: Border(top: BorderSide(color: c.border, width: 2)),
        ),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              children: [
                for (var i = 0; i < items.length; i++)
                  Expanded(
                    child: _NavItem(
                      icon: items[i].$1,
                      label: items[i].$2,
                      selected: widget.shell.currentIndex == i,
                      onTap: () => _select(i),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({required this.icon, required this.label, required this.selected, required this.onTap});

  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = DuoColors.of(context);
    return Semantics(
      selected: selected,
      button: true,
      label: label,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          padding: const EdgeInsets.symmetric(vertical: 6),
          decoration: BoxDecoration(
            color: selected ? c.primary.soft : Colors.transparent,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: selected ? c.primary.fill : Colors.transparent, width: 2),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 28, color: selected ? c.primary.fill : c.textFaint),
              const SizedBox(height: 2),
              Text(
                label.toUpperCase(),
                maxLines: 1,
                overflow: TextOverflow.fade,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.4,
                  color: selected ? c.primary.fill : c.textFaint,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
