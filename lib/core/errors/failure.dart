sealed class Failure {
  const Failure(this.message);
  final String message;
}

class UnsupportedFormatFailure extends Failure {
  const UnsupportedFormatFailure(String extension)
    : super('Format non supporté : $extension');
}

class ParsingFailure extends Failure {
  const ParsingFailure(super.message);
}

class StorageFailure extends Failure {
  const StorageFailure(super.message);
}
