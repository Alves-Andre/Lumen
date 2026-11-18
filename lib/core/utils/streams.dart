/// Emite [compute] imediatamente e novamente a cada evento de [changes].
Stream<T> recomputeOn<T>(Stream<Object?> changes, Future<T> Function() compute) async* {
  yield await compute();
  await for (final _ in changes) {
    yield await compute();
  }
}
