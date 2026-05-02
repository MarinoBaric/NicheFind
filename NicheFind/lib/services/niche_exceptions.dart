enum NicheErrorKind { offline, badRequest, server, parse, unknown }

class NicheException implements Exception {
  final NicheErrorKind kind;
  final String message;
  final String? details;

  const NicheException(this.kind, this.message, {this.details});

  factory NicheException.offline() => const NicheException(
        NicheErrorKind.offline,
        "You're offline. Connect to the internet and try again.",
      );

  factory NicheException.badRequest({String? details}) => NicheException(
        NicheErrorKind.badRequest,
        "Something's off with the request. Try adjusting your answers.",
        details: details,
      );

  factory NicheException.server({String? details}) => NicheException(
        NicheErrorKind.server,
        'DeepSeek is having a moment. Give it a few seconds and retry.',
        details: details,
      );

  factory NicheException.parse({String? details}) => NicheException(
        NicheErrorKind.parse,
        "We got a response we couldn't read. Try again?",
        details: details,
      );

  factory NicheException.unknown({String? details}) => NicheException(
        NicheErrorKind.unknown,
        'Something went wrong. Please try again.',
        details: details,
      );

  @override
  String toString() => 'NicheException($kind): $message';
}
