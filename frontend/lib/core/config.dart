/// Override with `--dart-define=API_BASE_URL=https://...` (NFR-03: HTTPS in production).
/// 10.0.2.2 is the host machine as seen from the Android emulator.
const apiBaseUrl = String.fromEnvironment(
  'API_BASE_URL',
  defaultValue: 'http://10.0.2.2:8000/api/v1',
);
