import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../core/database/app_database.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/widgets/duo_button.dart';
import '../../../../core/widgets/duo_widgets.dart';
import '../../../devotions/presentation/providers/devotions_providers.dart';
import '../../../devotions/presentation/widgets/note_editor_sheet.dart';
import '../../../reading_plan/presentation/widgets/reading_heatmap.dart';
import '../providers/prayer_providers.dart';
import '../widgets/prayer_widgets.dart';

enum _Section { progress, prayer, journal }

/// Aba 4 — Oração & Progresso.
class ProgressPrayerScreen extends ConsumerStatefulWidget {
  const ProgressPrayerScreen({super.key});

  @override
  ConsumerState<ProgressPrayerScreen> createState() => _ProgressPrayerScreenState();
}

class _ProgressPrayerScreenState extends ConsumerState<ProgressPrayerScreen> {
  _Section _section = _Section.progress;
  bool _showAnswered = false;

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: const Text('Oração & Progresso'),
          actions: [
            IconButton(
              tooltip: 'Configurações',
              icon: const Icon(Icons.settings_rounded),
              onPressed: () => context.push(AppRoutes.settings),
            ),
          ],
        ),
        body: ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
          children: [
            DuoSegmented<_Section>(
              segments: const {
                _Section.progress: 'Leituras',
                _Section.prayer: 'Oração',
                _Section.journal: 'Diário',
              },
              selected: _section,
              onChanged: (s) => setState(() => _section = s),
            ),
            const SizedBox(height: 16),
            ...switch (_section) {
              _Section.progress => [const ReadingHeatmap()],
              _Section.prayer => _prayerSection(),
              _Section.journal => _journalSection(),
            },
          ],
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        floatingActionButton: _section == _Section.prayer
            ? Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: DuoButton(
                  label: 'Novo pedido de oração',
                  icon: Icons.add_rounded,
                  style: DuoButtonStyle.primary,
                  onPressed: () => showPrayerForm(context),
                ),
              )
            : null,
      );

  List<Widget> _prayerSection() {
    final requests = ref.watch(_showAnswered ? answeredPrayersProvider : activePrayersProvider);
    return [
      Row(
        children: [
          ChoiceChip(
            label: const Text('Em oração', style: TextStyle(fontWeight: FontWeight.w800)),
            selected: !_showAnswered,
            onSelected: (_) => setState(() => _showAnswered = false),
          ),
          const SizedBox(width: 8),
          ChoiceChip(
            label: const Text('Respondidas', style: TextStyle(fontWeight: FontWeight.w800)),
            selected: _showAnswered,
            onSelected: (_) => setState(() => _showAnswered = true),
          ),
        ],
      ),
      const SizedBox(height: 16),
      AsyncView<List<PrayerRequest>>(
        value: requests,
        builder: (items) => items.isEmpty
            ? EmptyState(
                icon: _showAnswered ? Icons.emoji_events_rounded : Icons.volunteer_activism_rounded,
                title: _showAnswered ? 'Nenhuma oração respondida ainda' : 'Seu caderno de oração está vazio',
                message: _showAnswered
                    ? 'Quando Deus responder, marque o pedido como respondido e registre o testemunho.'
                    : 'Cadastre pedidos pela família, pela igreja e por quem precisa de intercessão.',
              )
            : Column(children: [for (final r in items) PrayerCard(request: r)]),
      ),
    ];
  }

  List<Widget> _journalSection() => [
        AsyncView<List<VerseNoteWithBook>>(
          value: ref.watch(allNotesProvider),
          builder: (notes) => notes.isEmpty
              ? const EmptyState(
                  icon: Icons.edit_note_rounded,
                  title: 'Seu diário devocional',
                  message: 'Na leitura da Bíblia, toque em um versículo e escolha '
                      '"Criar nota devocional" para registrar o que Deus falou com você.',
                )
              : Column(
                  children: [
                    for (final n in notes)
                      NoteTile(
                        note: n.note,
                        reference: n.reference,
                        onOpenReference: () => context.push(AppRoutes.reader(n.book.id, n.note.chapter)),
                      ),
                  ],
                ),
        ),
      ];
}
