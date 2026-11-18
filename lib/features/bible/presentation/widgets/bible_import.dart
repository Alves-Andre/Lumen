import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../core/database/app_database.dart';
import '../../../../core/database/seed/bible_seed_service.dart';
import '../../../../core/providers/database_providers.dart';
import '../../../../core/theme/duo_colors.dart';
import '../../../../core/widgets/duo_button.dart';
import '../providers/bible_providers.dart';

/// Passo a passo + botão para importar o .json de uma versão da Bíblia.
/// Usado na boas-vindas (ARC obrigatória) e nas Configurações (NVI / substituir).
class BibleImportPanel extends ConsumerStatefulWidget {
  const BibleImportPanel({super.key, required this.translation, this.replace = false, this.onImported});

  final BibleTranslation translation;

  /// Substitui o texto já instalado da versão.
  final bool replace;
  final VoidCallback? onImported;

  @override
  ConsumerState<BibleImportPanel> createState() => _BibleImportPanelState();
}

class _BibleImportPanelState extends ConsumerState<BibleImportPanel> {
  double? _progress;
  String? _error;
  bool _copied = false;

  bool get _busy => _progress != null;

  Future<void> _import() async {
    setState(() {
      _error = null;
      _progress = 0;
    });
    try {
      final imported = await ref.read(bibleSeedServiceProvider).pickAndImport(
            widget.translation,
            replace: widget.replace,
            onProgress: (p) {
              if (mounted) setState(() => _progress = p);
            },
          );
      if (!mounted) return;
      setState(() => _progress = null);
      if (!imported) return;
      ref
        ..invalidate(availableTranslationsProvider)
        ..invalidate(allBooksProvider);
      widget.onImported?.call();
    } on BibleSeedException catch (e) {
      if (mounted) {
        setState(() {
          _progress = null;
          _error = e.message;
        });
      }
    } on Exception catch (e) {
      if (mounted) {
        setState(() {
          _progress = null;
          _error = 'Não foi possível importar: $e';
        });
      }
    }
  }

  Future<void> _copyLink() async {
    await Clipboard.setData(ClipboardData(text: widget.translation.downloadUrl));
    if (mounted) setState(() => _copied = true);
  }

  @override
  Widget build(BuildContext context) {
    final c = DuoColors.of(context);
    final t = widget.translation;

    Widget step(int n, Widget content) => Padding(
          padding: const EdgeInsets.only(bottom: 14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 28,
                height: 28,
                alignment: Alignment.center,
                decoration: BoxDecoration(color: c.primary.soft, shape: BoxShape.circle),
                child: Text('$n', style: TextStyle(color: c.primary.fill, fontWeight: FontWeight.w800)),
              ),
              const SizedBox(width: 12),
              Expanded(child: content),
            ],
          ),
        );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        step(
          1,
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Baixe o arquivo ${t.sourceFileName} (${t.fullName})', style: const TextStyle(fontWeight: FontWeight.w800)),
              const SizedBox(height: 6),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: c.neutral.soft,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: c.border, width: 2),
                ),
                child: SelectableText(t.downloadUrl, style: TextStyle(color: c.textMuted, fontSize: 12)),
              ),
              TextButton.icon(
                onPressed: _copyLink,
                icon: Icon(_copied ? Icons.check_rounded : Icons.copy_rounded, size: 18),
                label: Text(_copied ? 'Link copiado: cole no navegador' : 'Copiar link'),
              ),
            ],
          ),
        ),
        step(
          2,
          const Text(
            'Toque abaixo e escolha o arquivo baixado (geralmente na pasta Downloads).',
            style: TextStyle(fontWeight: FontWeight.w700),
          ),
        ),
        step(
          3,
          Text(
            'Aguarde alguns segundos. A importação acontece uma única vez e depois tudo funciona sem internet.',
            style: TextStyle(color: c.textMuted),
          ),
        ),
        if (_busy) ...[
          LinearProgressIndicator(value: _progress == 0 ? null : _progress, minHeight: 8, borderRadius: BorderRadius.circular(8)),
          const SizedBox(height: 8),
          Text(
            _progress == 0 ? 'Lendo o arquivo…' : 'Importando… ${((_progress ?? 0) * 100).round()}%',
            textAlign: TextAlign.center,
            style: TextStyle(color: c.textMuted, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 12),
        ],
        if (_error != null) ...[
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: c.danger.soft, borderRadius: BorderRadius.circular(12)),
            child: Text(_error!, style: TextStyle(color: c.danger.fill, fontWeight: FontWeight.w700)),
          ),
          const SizedBox(height: 12),
        ],
        DuoButton(
          label: widget.replace ? 'Selecionar arquivo e substituir' : 'Selecionar arquivo da ${t.abbrev}',
          icon: Icons.file_open_rounded,
          style: DuoButtonStyle.primary,
          onPressed: _busy ? null : _import,
        ),
      ],
    );
  }
}
