import 'package:material_ui/material_ui.dart';

import '../../../../core/theme/duo_colors.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/duo_button.dart';
import '../../../../core/widgets/duo_widgets.dart';

/// Comemoração ao encerrar uma sessão de leitura, com o resumo do que foi lido
/// (ex.: "Gênesis 1-3").
Future<void> showReadingSummary(
  BuildContext context, {
  required String summary,
  required int chapterCount,
  required int streakDays,
  required int chaptersRead,
  required int totalChapters,
}) async {
  await showGeneralDialog<void>(
    context: context,
    barrierDismissible: false,
    transitionDuration: const Duration(milliseconds: 250),
    pageBuilder: (ctx, _, _) => _ReadingSummary(
      summary: summary,
      chapterCount: chapterCount,
      streakDays: streakDays,
      chaptersRead: chaptersRead,
      totalChapters: totalChapters,
    ),
    transitionBuilder: (_, animation, _, child) => SlideTransition(
      position: Tween(begin: const Offset(0, 1), end: Offset.zero)
          .animate(CurvedAnimation(parent: animation, curve: Curves.easeOutCubic)),
      child: child,
    ),
  );
}

class _ReadingSummary extends StatelessWidget {
  const _ReadingSummary({
    required this.summary,
    required this.chapterCount,
    required this.streakDays,
    required this.chaptersRead,
    required this.totalChapters,
  });

  final String summary;
  final int chapterCount;
  final int streakDays;
  final int chaptersRead;
  final int totalChapters;

  @override
  Widget build(BuildContext context) {
    final c = DuoColors.of(context);
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const Spacer(),
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0.3, end: 1),
                duration: const Duration(milliseconds: 600),
                curve: Curves.elasticOut,
                builder: (_, scale, child) => Transform.scale(scale: scale, child: child),
                child: Container(
                  width: 140,
                  height: 140,
                  decoration: BoxDecoration(
                    color: c.success.fill,
                    shape: BoxShape.circle,
                    border: Border.all(color: c.success.shadow, width: 6),
                  ),
                  child: const Icon(Icons.check_rounded, color: Colors.white, size: 96),
                ),
              ),
              const SizedBox(height: 28),
              Text(
                chapterCount == 1 ? 'Capítulo concluído!' : '$chapterCount capítulos lidos!',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: c.success.fill),
              ),
              const SizedBox(height: 8),
              Text(
                summary,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: c.textMuted),
              ),
              const SizedBox(height: 32),
              Row(
                children: [
                  Expanded(
                    child: DuoStatBox(
                      label: 'Ofensiva',
                      value: '$streakDays ${streakDays == 1 ? 'dia' : 'dias'}',
                      tone: c.streak,
                      icon: Icons.local_fire_department_rounded,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: DuoStatBox(
                      label: 'Jornada',
                      value: '${thousands(chaptersRead)}/${thousands(totalChapters)}',
                      tone: c.success,
                      icon: Icons.auto_stories_rounded,
                    ),
                  ),
                ],
              ),
              const Spacer(),
              DuoButton(
                label: 'Continuar',
                style: DuoButtonStyle.success,
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
