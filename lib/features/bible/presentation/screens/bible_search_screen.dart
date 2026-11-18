import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../core/database/app_database.dart';
import '../../../../core/providers/app_providers.dart';
import '../../../../core/providers/database_providers.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/theme/duo_colors.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/duo_widgets.dart';

/// Busca por palavras na versão de leitura atual (sem diferenciar acentos).
class BibleSearchScreen extends ConsumerStatefulWidget {
  const BibleSearchScreen({super.key});

  @override
  ConsumerState<BibleSearchScreen> createState() => _BibleSearchScreenState();
}

class _BibleSearchScreenState extends ConsumerState<BibleSearchScreen> {
  static const _limit = 300;
  static const _examples = ['amor', 'fé', 'o Senhor é o meu pastor', 'graça', 'Espírito Santo'];

  final _controller = TextEditingController();
  Timer? _debounce;
  String _query = '';
  SearchResult? _result;
  bool _loading = false;

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _onChanged(String value) {
    setState(() {}); // atualiza o botão de limpar
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () => _run(value));
  }

  Future<void> _run(String value) async {
    final query = value.trim();
    if (query.isEmpty) {
      setState(() {
        _query = '';
        _result = null;
      });
      return;
    }
    setState(() => _loading = true);
    final translation = ref.read(readingTranslationProvider);
    final result = await ref.read(appDatabaseProvider).bibleDao.search(translation, query, limit: _limit);
    // Ignora respostas de buscas antigas que chegam depois de uma mais nova.
    if (!mounted || _controller.text.trim() != query) return;
    setState(() {
      _query = query;
      _result = result;
      _loading = false;
    });
  }

  void _useExample(String text) {
    _controller.text = text;
    _run(text);
  }

  @override
  Widget build(BuildContext context) {
    final c = DuoColors.of(context);
    final translation = ref.watch(readingTranslationProvider);
    final result = _result;

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        centerTitle: false,
        title: TextField(
          controller: _controller,
          autofocus: true,
          textInputAction: TextInputAction.search,
          onChanged: _onChanged,
          onSubmitted: _run,
          decoration: InputDecoration(
            hintText: 'Buscar na Bíblia ${translation.abbrev}',
            filled: false,
            border: InputBorder.none,
            enabledBorder: InputBorder.none,
            focusedBorder: InputBorder.none,
            suffixIcon: _controller.text.isEmpty
                ? null
                : IconButton(
                    tooltip: 'Limpar',
                    icon: const Icon(Icons.close_rounded),
                    onPressed: () {
                      _controller.clear();
                      _run('');
                    },
                  ),
          ),
        ),
        bottom: _loading ? const PreferredSize(preferredSize: Size.fromHeight(2), child: LinearProgressIndicator(minHeight: 2)) : null,
      ),
      body: result == null
          ? ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Text('Experimente buscar', style: TextStyle(color: c.textMuted, fontWeight: FontWeight.w700)),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final e in _examples)
                      ActionChip(
                        label: Text(e, style: const TextStyle(fontWeight: FontWeight.w700)),
                        side: BorderSide(color: c.border, width: 2),
                        onPressed: () => _useExample(e),
                      ),
                  ],
                ),
                const SizedBox(height: 20),
                Text(
                  'Acentos e maiúsculas não importam, e palavras incompletas também valem: '
                  '"past" encontra "pastor" e "pastores". Todas as palavras precisam aparecer no versículo.',
                  style: TextStyle(color: c.textMuted, height: 1.4),
                ),
              ],
            )
          : result.hits.isEmpty
              ? EmptyState(
                  icon: Icons.search_off_rounded,
                  title: 'Nada encontrado',
                  message: 'Nenhum versículo da ${translation.abbrev} contém todas as palavras de "$_query".',
                )
              : ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                  itemCount: result.hits.length + 1,
                  separatorBuilder: (_, i) => i == 0 ? const SizedBox(height: 4) : Divider(color: c.border, height: 24),
                  itemBuilder: (context, i) {
                    if (i == 0) {
                      final shown = result.hits.length;
                      return Text(
                        result.total > shown
                            ? '${thousands(result.total)} versículos · mostrando os $shown primeiros'
                            : '${thousands(result.total)} ${result.total == 1 ? 'versículo' : 'versículos'}',
                        style: TextStyle(color: c.textMuted, fontWeight: FontWeight.w800),
                      );
                    }
                    final hit = result.hits[i - 1];
                    return InkWell(
                      borderRadius: BorderRadius.circular(8),
                      onTap: () => context.push(AppRoutes.reader(hit.bookId, hit.chapter, verse: hit.verse)),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(hit.reference, style: TextStyle(fontWeight: FontWeight.w800, color: c.primary.fill)),
                            const SizedBox(height: 4),
                            Text.rich(
                              TextSpan(children: _highlightSpans(hit.highlighted, c)),
                              style: TextStyle(color: c.text, height: 1.45, fontSize: 15),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }

  /// Converte os marcadores do FTS (\u0001…\u0002) em trechos destacados.
  static List<TextSpan> _highlightSpans(String text, DuoColors c) {
    final spans = <TextSpan>[];
    final parts = text.split(SearchHit.markStart);
    spans.add(TextSpan(text: parts.first));
    for (final part in parts.skip(1)) {
      final end = part.indexOf(SearchHit.markEnd);
      if (end == -1) {
        spans.add(TextSpan(text: part));
        continue;
      }
      spans.add(TextSpan(
        text: part.substring(0, end),
        style: TextStyle(fontWeight: FontWeight.w800, backgroundColor: c.gold.soft, color: c.text),
      ));
      spans.add(TextSpan(text: part.substring(end + 1)));
    }
    return spans;
  }
}
