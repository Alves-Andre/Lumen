// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'devotions_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(allNotes)
final allNotesProvider = AllNotesProvider._();

final class AllNotesProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<VerseNoteWithBook>>,
          List<VerseNoteWithBook>,
          Stream<List<VerseNoteWithBook>>
        >
    with
        $FutureModifier<List<VerseNoteWithBook>>,
        $StreamProvider<List<VerseNoteWithBook>> {
  AllNotesProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'allNotesProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$allNotesHash();

  @$internal
  @override
  $StreamProviderElement<List<VerseNoteWithBook>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<VerseNoteWithBook>> create(Ref ref) {
    return allNotes(ref);
  }
}

String _$allNotesHash() => r'785751fc4e6d8a782dedaa83b191250690109c84';
