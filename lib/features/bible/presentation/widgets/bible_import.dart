import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../core/constants/bible_constants.dart';
import '../../../../core/database/app_database.dart';
import '../../../../core/database/seed/bible_seed_service.dart';
import '../../../../core/providers/database_providers.dart';
import '../../../../core/theme/duo_colors.dart';
import '../../../../core/widgets/duo_button.dart';
import '../providers/bible_providers.dart';

/// Passo a passo + botão para importar o .json de uma tradução da Bíblia.
///
/// * [translation] do catálogo: mostra o link de download quando o arquivo
///   existe no repositório de origem; senão pede um arquivo próprio.
/// * [translation] `null`: tradução personalizada ("Outra"), com sigla e nome.
class BibleImportPanel extends ConsumerStatefulWidget {
  const BibleImportPanel({super.key, this.translation, this.replace = false, this.onImported});

  final BibleTranslation? translation;

  /// Substitui o texto já instalado da tradução.
  final bool replace;
  final ValueChanged<BibleTranslation>? onImported;

  @override
  ConsumerState<BibleImportPanel> createState() => _BibleImportPanelState();
}

class _BibleImportPanelState extends ConsumerState<BibleImportPanel> {
  final _abbrev = TextEditingController();
  final _name = TextEditingController();
  double? _progress;
  String? _error;
  bool _copied = false;

  bool get _busy => _progress != null;
  bool get _isCustom => widget.translation == null;

  @override
  void dispose() {
    _abbrev.dispose();
    _name.dispose();
    super.dispose();
  }

  BibleTranslation? _target() {
    final fixed = widget.translation;
    if (fixed != null) return fixed;
    final abbrev = _abbrev.text.trim();
    final name = _name.text.trim();
    if (abbrev.isEmpty || name.isEmpty) {
      setState(() => _error = 'Informe a sigla e o nome da tradução.');
      return null;
    }
    if (abbrev.length > 10) {
      setState(() => _error = 'Use uma sigla curta (até 10 letras), ex.: NBV.');
      return null;
    }
    return BibleTranslation.custom(abbrev: abbrev, fullName: name);
  }

  Future<void> _import() async {
    final target = _target();
    if (target == null) return;
    setState(() {
      _error = null;
      _progress = 0;
    });
    try {
      final imported = await ref.read(bibleSeedServiceProvider).pickAndImport(
            target,
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
      widget.onImported?.call(target);
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

  Future<void> _copyLink(String url) async {
    await Clipboard.setData(ClipboardData(text: url));
    if (mounted) setState(() => _copied = true);
  }

  @override
  Widget build(BuildContext context) {
    final c = DuoColors.of(context);
    final t = widget.translation;
    final url = t?.downloadUrl;

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

    final Widget firstStep;
    if (url != null) {
      firstStep = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Baixe o arquivo ${t!.sourceFileName} (${t.fullName})', style: const TextStyle(fontWeight: FontWeight.w800)),
          const SizedBox(height: 6),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: c.neutral.soft,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: c.border, width: 2),
            ),
            child: SelectableText(url, style: TextStyle(color: c.textMuted, fontSize: 12)),
          ),
          TextButton.icon(
            onPressed: () => _copyLink(url),
            icon: Icon(_copied ? Icons.check_rounded : Icons.copy_rounded, size: 18),
            label: Text(_copied ? 'Link copiado: cole no navegador' : 'Copiar link'),
          ),
        ],
      );
    } else {
      firstStep = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            t == null ? 'Tenha o arquivo .json da tradução' : 'Tenha o arquivo .json da ${t.abbrev} (${t.fullName})',
            style: const TextStyle(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 4),
          Text(
            'Esta tradução não está no repositório de origem: use um arquivo próprio no mesmo formato '
            '(lista com os 66 livros, cada um com "name" e "chapters"), como os de ${BibleConstants.biblesSourcePage}.',
            style: TextStyle(color: c.textMuted, fontSize: 13, height: 1.35),
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (_isCustom) ...[
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 110,
                child: TextField(
                  controller: _abbrev,
                  enabled: !_busy,
                  textCapitalization: TextCapitalization.characters,
                  maxLength: 10,
                  decoration: const InputDecoration(labelText: 'Sigla', hintText: 'NBV', counterText: ''),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: _name,
                  enabled: !_busy,
                  textCapitalization: TextCapitalization.words,
                  maxLength: 80,
                  decoration: const InputDecoration(
                    labelText: 'Nome da tradução',
                    hintText: 'Nova Bíblia Viva',
                    counterText: '',
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
        ],
        step(1, firstStep),
        step(
          2,
          const Text(
            'Toque abaixo e escolha o arquivo (geralmente na pasta Downloads ou no app Arquivos).',
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
          label: widget.replace
              ? 'Selecionar arquivo e substituir'
              : (t == null ? 'Selecionar arquivo' : 'Selecionar arquivo da ${t.abbrev}'),
          icon: Icons.file_open_rounded,
          style: DuoButtonStyle.primary,
          onPressed: _busy ? null : _import,
        ),
      ],
    );
  }
}

/// Abre o [BibleImportPanel] numa folha inferior. Retorna a tradução importada
/// (ou `null` se o usuário fechar sem importar).
Future<BibleTranslation?> showBibleImportSheet(
  BuildContext context, {
  BibleTranslation? translation,
  bool replace = false,
}) =>
    showModalBottomSheet<BibleTranslation>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (sheetContext) => Padding(
        padding: EdgeInsets.fromLTRB(20, 0, 20, 20 + MediaQuery.viewInsetsOf(sheetContext).bottom),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                translation == null
                    ? 'Importar outra tradução'
                    : '${replace ? 'Substituir' : 'Importar'} ${translation.abbrev}',
                style: Theme.of(sheetContext).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              BibleImportPanel(
                translation: translation,
                replace: replace,
                onImported: (t) => Navigator.of(sheetContext).pop(t),
              ),
            ],
          ),
        ),
      ),
    );
