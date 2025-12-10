/// Central place for app-wide configuration constants.
/// Update `BASE_URL` via `--dart-define=BASE_URL=<your-url>` when building.
const String BASE_URL = String.fromEnvironment(
  'BASE_URL',
  defaultValue: 'http://localhost:8080',
);

