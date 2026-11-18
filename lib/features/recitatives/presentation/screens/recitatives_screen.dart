import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../core/database/app_database.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/widgets/duo_button.dart';
import '../../../../core/widgets/duo_widgets.dart';
import '../providers/recitatives_providers.dart';
import '../widgets/recitative_widgets.dart';

enum _Filter { upcoming, history, memories }

/// Aba 3 — Recitativos (Culto de Jovens e Menores).
class RecitativesScreen extends ConsumerStatefulWidget {
  const RecitativesScreen({super.key});

  @override
  ConsumerState<RecitativesScreen> createState() => _RecitativesScreenState();
}

class _RecitativesScreenState extends ConsumerState<RecitativesScreen> {
  _Filter _filter = _Filter.upcoming;

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('Recitativos')),
        body: ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
          children: [
            DuoSegmented<_Filter>(
              segments: const {
                _Filter.upcoming: 'A recitar',
                _Filter.history: 'Recitados',
                _Filter.memories: 'Lembranças',
              },
              selected: _filter,
              onChanged: (f) => setState(() => _filter = f),
            ),
            const SizedBox(height: 16),
            ...switch (_filter) {
              _Filter.upcoming => _list(
                  ref.watch(pendingRecitativesProvider),
                  empty: const EmptyState(
                    icon: Icons.record_voice_over_rounded,
                    title: 'Nenhum recitativo a recitar',
                    message: 'Recebeu um verso para o culto? Cadastre-o e treine a memorização.',
                  ),
                ),
              _Filter.history => _list(
                  ref.watch(recitedRecitativesProvider),
                  empty: const EmptyState(
                    icon: Icons.history_edu_rounded,
                    title: 'Seu histórico aparece aqui',
                    message: 'Marque um recitativo como "Recitado" para guardá-lo no histórico.',
                  ),
                ),
              _Filter.memories => [
                  AsyncView(
                    value: ref.watch(recitativeMemoriesProvider),
                    builder: (result) => result.hasMemories
                        ? Column(children: [for (final m in result.memories) RecitativeMemoryCard(memory: m)])
                        : const EmptyState(
                            icon: Icons.auto_awesome_rounded,
                            title: 'Nenhuma lembrança nesta semana',
                            message: 'Quando houver recitativos de anos anteriores nesta data '
                                '(ou nesta semana), eles aparecerão aqui.',
                          ),
                  ),
                ],
            },
          ],
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        floatingActionButton: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: DuoButton(
            label: 'Novo recitativo',
            icon: Icons.add_rounded,
            style: DuoButtonStyle.gold,
            onPressed: () => context.push(AppRoutes.newRecitative),
          ),
        ),
      );

  List<Widget> _list(AsyncValue<List<RecitativeWithBook>> value, {required Widget empty}) => [
        AsyncView(
          value: value,
          builder: (items) => items.isEmpty
              ? empty
              : Column(children: [for (final item in items) RecitativeTile(item: item)]),
        ),
      ];
}
