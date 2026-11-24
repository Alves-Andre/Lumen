import 'dart:math';

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../core/database/app_database.dart';
import '../../../../core/theme/duo_colors.dart';
import '../../../../core/widgets/duo_button.dart';
import '../../../../core/widgets/duo_widgets.dart';
import '../../domain/services/memorization_helper.dart';
import '../providers/recitatives_providers.dart';

/// Treino de memorização em 3 níveis, no formato de "lição" do Duolingo.
class MemorizationScreen extends ConsumerStatefulWidget {
  const MemorizationScreen({super.key, required this.id});

  final String id;

  @override
  ConsumerState<MemorizationScreen> createState() => _MemorizationScreenState();
}

class _MemorizationScreenState extends ConsumerState<MemorizationScreen> {
  MemorizationLevel _level = MemorizationLevel.reading;
  final Set<int> _revealed = {};
  bool _hints = false;
  int? _seed;

  void _setLevel(MemorizationLevel level) => setState(() {
        _level = level;
        _revealed.clear();
      });

  Future<void> _finish(RecitativeWithBook item) async {
    HapticFeedback.mediumImpact();
    await showDialog<void>(
      context: context,
      builder: (ctx) {
        final c = DuoColors.of(ctx);
        return AlertDialog(
          icon: Icon(Icons.emoji_events_rounded, color: c.gold.fill, size: 64),
          title: const Text('Muito bem!', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.w800)),
          content: Text(
            'Você completou os 3 níveis de ${item.reference}. '
            'Repita o treino nos próximos dias até o culto.',
            textAlign: TextAlign.center,
          ),
          actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          actions: [
            DuoButton(label: 'Concluir', style: DuoButtonStyle.success, onPressed: () => Navigator.pop(ctx)),
          ],
        );
      },
    );
    if (mounted) context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final c = DuoColors.of(context);
    final item = ref.watch(recitativeByIdProvider(widget.id));

    return Scaffold(
      body: SafeArea(
        child: AsyncView<RecitativeWithBook?>(
          value: item,
          builder: (data) {
            if (data == null) return const Center(child: Text('Recitativo não encontrado.'));
            final stage = MemorizationHelper.buildStage(data.recitative.verseTextSnapshot, _level, seed: _seed);
            final hiddenIdx = [for (var i = 0; i < stage.tokens.length; i++) if (stage.tokens[i].hidden) i];
            final revealedCount = hiddenIdx.where(_revealed.contains).length;
            final isLast = _level == MemorizationLevel.challenge;
            final progress = (_level.index + (hiddenIdx.isEmpty ? 1 : revealedCount / hiddenIdx.length) * 0.999) /
                MemorizationLevel.values.length;

            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(8, 8, 16, 0),
                  child: Row(
                    children: [
                      IconButton(
                        tooltip: 'Sair do treino',
                        icon: Icon(Icons.close_rounded, color: c.textFaint, size: 30),
                        onPressed: () => context.pop(),
                      ),
                      Expanded(child: DuoProgressBar(value: progress)),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.all(20),
                    children: [
                      Text(
                        'Nível ${_level.index + 1} · ${_level.label}',
                        style: TextStyle(color: c.gold.shadow, fontWeight: FontWeight.w800, fontSize: 14),
                      ),
                      const SizedBox(height: 6),
                      Text(data.reference, style: Theme.of(context).textTheme.headlineSmall),
                      const SizedBox(height: 6),
                      Text(
                        switch (_level) {
                          MemorizationLevel.reading => 'Leia o verso em voz alta três vezes, com atenção.',
                          MemorizationLevel.lightGaps => 'Recite completando as lacunas. Toque para conferir.',
                          MemorizationLevel.challenge => 'Agora quase sem apoio. Toque só quando precisar.',
                        },
                        style: TextStyle(color: c.textMuted),
                      ),
                      const SizedBox(height: 24),
                      Wrap(
                        spacing: 6,
                        runSpacing: 10,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          for (var i = 0; i < stage.tokens.length; i++)
                            _TokenView(
                              token: stage.tokens[i],
                              revealed: _revealed.contains(i),
                              hint: _hints,
                              onTap: () {
                                HapticFeedback.selectionClick();
                                setState(() => _revealed.add(i));
                              },
                            ),
                        ],
                      ),
                      if (hiddenIdx.isNotEmpty) ...[
                        const SizedBox(height: 24),
                        Text(
                          '$revealedCount de ${hiddenIdx.length} palavras reveladas',
                          style: TextStyle(color: c.textMuted, fontWeight: FontWeight.w700),
                        ),
                        SwitchListTile(
                          contentPadding: EdgeInsets.zero,
                          value: _hints,
                          onChanged: (v) => setState(() => _hints = v),
                          title: const Text('Mostrar primeira letra', style: TextStyle(fontWeight: FontWeight.w700)),
                        ),
                        Row(
                          children: [
                            TextButton.icon(
                              onPressed: () => setState(() => _revealed.addAll(hiddenIdx)),
                              icon: const Icon(Icons.visibility_rounded),
                              label: const Text('Revelar tudo'),
                            ),
                            const Spacer(),
                            TextButton.icon(
                              onPressed: () => setState(() {
                                _seed = Random().nextInt(1 << 31);
                                _revealed.clear();
                              }),
                              icon: const Icon(Icons.shuffle_rounded),
                              label: const Text('Outras lacunas'),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                  decoration: BoxDecoration(border: Border(top: BorderSide(color: c.border, width: 2))),
                  child: Row(
                    children: [
                      if (_level != MemorizationLevel.reading) ...[
                        Expanded(
                          child: DuoButton(
                            label: 'Voltar',
                            style: DuoButtonStyle.neutral,
                            onPressed: () => _setLevel(MemorizationLevel.values[_level.index - 1]),
                          ),
                        ),
                        const SizedBox(width: 12),
                      ],
                      Expanded(
                        flex: 2,
                        child: DuoButton(
                          label: isLast ? 'Concluir treino' : 'Próximo nível',
                          style: DuoButtonStyle.success,
                          onPressed: isLast
                              ? () => _finish(data)
                              : () => _setLevel(MemorizationLevel.values[_level.index + 1]),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _TokenView extends StatelessWidget {
  const _TokenView({required this.token, required this.revealed, required this.hint, required this.onTap});

  final MemorizationToken token;
  final bool revealed;
  final bool hint;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = DuoColors.of(context);
    const style = TextStyle(fontSize: 22, height: 1.4, fontWeight: FontWeight.w600);
    if (!token.hidden) return Text(token.display(), style: style);

    final shown = revealed ? token.word : (hint ? token.firstLetterHint : MemorizationToken.placeholder);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (token.prefix.isNotEmpty) Text(token.prefix, style: style),
        Semantics(
          button: !revealed,
          label: revealed ? token.word : 'Palavra oculta, toque para revelar',
          child: GestureDetector(
            onTap: revealed ? null : onTap,
            child: DuoTile(
              radius: 12,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
              color: revealed ? c.success.soft : c.card,
              borderColor: revealed ? c.success.fill : c.border,
              shadowColor: revealed ? c.success.shadow : c.border,
              child: Text(
                shown,
                style: style.copyWith(
                  color: revealed ? c.success.shadow : c.textFaint,
                  fontWeight: FontWeight.w800,
                  letterSpacing: revealed ? 0 : 1,
                ),
              ),
            ),
          ),
        ),
        if (token.suffix.isNotEmpty) Text(token.suffix, style: style),
      ],
    );
  }
}
