/// "Romanos 8", "Romanos 8:28" ou "Romanos 8:28-30".
String formatReference(String bookName, int chapter, [int? verseStart, int? verseEnd]) {
  if (verseStart == null) return '$bookName $chapter';
  if (verseEnd == null || verseEnd == verseStart) return '$bookName $chapter:$verseStart';
  return '$bookName $chapter:$verseStart-$verseEnd';
}

/// Capítulos compactados em intervalos: [1, 2, 3, 5, 7, 8] → "1-3, 5, 7-8".
String formatChapterRanges(Iterable<int> chapters) {
  final sorted = chapters.toSet().toList()..sort();
  final parts = <String>[];
  var i = 0;
  while (i < sorted.length) {
    var j = i;
    while (j + 1 < sorted.length && sorted[j + 1] == sorted[j] + 1) {
      j++;
    }
    parts.add(i == j ? '${sorted[i]}' : '${sorted[i]}-${sorted[j]}');
    i = j + 1;
  }
  return parts.join(', ');
}
