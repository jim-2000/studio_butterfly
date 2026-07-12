import '../models/theme_mode_model.dart';

/// No `Either<Failure, T>` here, unlike the SMS repository: a local
/// preference read/write has no user-facing error state worth designing for
/// (deliberate scope decision — see AI-USAGE.md / README "what was cut").
abstract class ThemeRepository {
  AppThemeMode getThemeMode();
  Future<void> setThemeMode(AppThemeMode mode);
}
