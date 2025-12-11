import 'package:flutter/foundation.dart';

/// Central place for app-wide configuration constants.
/// Use `--dart-define=BASE_URL=<your-url>` to override per run.
/// Defaults:
/// - Web: http://localhost:8080
/// - Android emulator: http://10.0.2.2:8080
const String _defaultBaseUrl =
    kIsWeb ? 'http://localhost:8080' : 'http://10.0.2.2:8080';

// ignore: constant_identifier_names
const String BASE_URL = String.fromEnvironment(
  'BASE_URL',
  defaultValue: _defaultBaseUrl,
);

/// Full todos endpoint base.
// ignore: constant_identifier_names
const String TODOS_BASE_URL = '$BASE_URL/api/v1/todos';

