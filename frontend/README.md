# HausMaster Frontend (Flutter, Android)

Feature-slice layout under `lib/`:

- `core/` – theme, HTTP client (Dio), secure token storage, XAF formatting, l10n
- `features/<name>/` – `data/`, `domain/`, `presentation/` per feature
  (auth, properties, rent, bills, payments)

## Next: add dependencies (needs network)

```
flutter pub add flutter_riverpod riverpod_annotation dio retrofit flutter_secure_storage intl
flutter pub add --dev riverpod_generator build_runner retrofit_generator
flutter run
```

Backend from the Android emulator: `http://10.0.2.2:8000/api/v1`.
