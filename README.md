# Studio Butterfly IT - Task Assessment (Flutter)

## Sms Console (Flutter Assessment)
> This app is a simple "Sms Console" built for the task assessment.


## Screenshots

## Download APK

## Requirements

- Flutter: latest stable (Flutter 3.44.2)
- Dart: 3.12.2 (Latest)

## Setup (Run Locally)

1. Install Flutter SDK and setup Android Studio / VS Code.
2. Get packages:

```bash
flutter pub get
```

3. Run the app:

```bash
flutter run
```

## API Used

- Base API: `env.dart`

## State Management Choice (Why Riverpod)

This project uses `flutter_riverpod`:

- `Riverpod` for built-in dependency injection.
  Reason: it has more built-in dependency injection features.
- `Riverpod` AsyncNotifier and AsyncValue.
  Reason: it is simple. in Bloc/Cubit i need to build more classes/state class.
- `Riverpod` Auto-Dispose and cache invalidation.
  Reason: when we send a sms we refresh the list for valid cost. in bloc it need more wiring [event/emit/listen].
`
## Project Architecture (Folder Structure)
The project follows a lightweight Clean Architecture style, without a separate `domain` layer:

- `data`: models (Equatable, double as entities) + data sources + repository interfaces & implementations
- `provider`: all Riverpod providers (state, DI, and what would otherwise be use cases)
- `presentation`: UI only (`ConsumerWidget`/`ConsumerStatefulWidget`)

Main folders (high level):

```text
lib/
  core/                  # network client, error,theme
    theme/
    network/
    utils/
  data/
    datasource/          # SMS remote, theme local (Hive)
    models/              # SmsCostRowModel, SmsSendResultModel
    repositories/        # interfaces + impls (sms, theme)
  provider/               # Riverpod providers
    sms/
    theme/
    core_providers.dart
  presentation/
    sms/
      widgets/
    theme/
  Service/                # Service class
    local_storage.dart
  main.dart
```
 

## Local Storage / Offline Approach (Hive)

We use `hive` + `hive_flutter` for local persistence:

- **Base cache (API response)**:
  Stored as auth token and refresh token in Hive (`LocalStorage`).


  ## Main Screens

- A Simple SMS send form page user can see as home screen 
- History page user can see all sent sms.
- Cost BreakDown Pgae

 ## Known Limitations

- Without Active backend API, working too much difficult.