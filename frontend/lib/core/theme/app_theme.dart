import 'package:flutter/material.dart';

/// 8-pt spacing scale. Use these instead of magic numbers.
abstract final class Spacing {
  static const xs = 4.0;
  static const sm = 8.0;
  static const md = 16.0;
  static const lg = 24.0;
  static const xl = 32.0;
}

abstract final class AppRadius {
  static const field = 12.0;
  static const card = 16.0;
  static const pill = 999.0;
}

/// Minimum touch target (Material / WCAG 2.5.5 guidance).
const kMinTapTarget = 48.0;

/// Semantic colours the Material scheme has no slot for: the status language
/// of the app (paid / late / partial / expiring ...). Read it with
/// `context.appColors`. Every pair keeps text-on-container contrast >= 4.5:1.
@immutable
class AppColors extends ThemeExtension<AppColors> {
  const AppColors({
    required this.success,
    required this.successContainer,
    required this.warning,
    required this.warningContainer,
    required this.danger,
    required this.dangerContainer,
    required this.neutral,
    required this.neutralContainer,
    required this.cardShadow,
  });

  final Color success;
  final Color successContainer;
  final Color warning;
  final Color warningContainer;
  final Color danger;
  final Color dangerContainer;
  final Color neutral;
  final Color neutralContainer;
  final Color cardShadow;

  static const light = AppColors(
    success: Color(0xFF1E7A4A),
    successContainer: Color(0xFFE3F1E8),
    warning: Color(0xFF9A5B00),
    warningContainer: Color(0xFFFCEFD2),
    danger: Color(0xFFB3261E),
    dangerContainer: Color(0xFFFBE3E0),
    neutral: Color(0xFF6B5A50),
    neutralContainer: Color(0xFFEFE8E2),
    cardShadow: Color(0x142B1B14),
  );

  static const dark = AppColors(
    success: Color(0xFF7FD3A1),
    successContainer: Color(0xFF173626),
    warning: Color(0xFFF2C063),
    warningContainer: Color(0xFF3F2E0C),
    danger: Color(0xFFFFA39B),
    dangerContainer: Color(0xFF4A1C18),
    neutral: Color(0xFFC9B9AE),
    neutralContainer: Color(0xFF362B25),
    cardShadow: Color(0x00000000),
  );

  @override
  AppColors copyWith({
    Color? success,
    Color? successContainer,
    Color? warning,
    Color? warningContainer,
    Color? danger,
    Color? dangerContainer,
    Color? neutral,
    Color? neutralContainer,
    Color? cardShadow,
  }) => AppColors(
    success: success ?? this.success,
    successContainer: successContainer ?? this.successContainer,
    warning: warning ?? this.warning,
    warningContainer: warningContainer ?? this.warningContainer,
    danger: danger ?? this.danger,
    dangerContainer: dangerContainer ?? this.dangerContainer,
    neutral: neutral ?? this.neutral,
    neutralContainer: neutralContainer ?? this.neutralContainer,
    cardShadow: cardShadow ?? this.cardShadow,
  );

  @override
  AppColors lerp(AppColors? other, double t) {
    if (other == null) return this;
    return AppColors(
      success: Color.lerp(success, other.success, t)!,
      successContainer: Color.lerp(
        successContainer,
        other.successContainer,
        t,
      )!,
      warning: Color.lerp(warning, other.warning, t)!,
      warningContainer: Color.lerp(
        warningContainer,
        other.warningContainer,
        t,
      )!,
      danger: Color.lerp(danger, other.danger, t)!,
      dangerContainer: Color.lerp(dangerContainer, other.dangerContainer, t)!,
      neutral: Color.lerp(neutral, other.neutral, t)!,
      neutralContainer: Color.lerp(
        neutralContainer,
        other.neutralContainer,
        t,
      )!,
      cardShadow: Color.lerp(cardShadow, other.cardShadow, t)!,
    );
  }
}

extension AppThemeContext on BuildContext {
  AppColors get appColors => Theme.of(this).extension<AppColors>()!;
}

abstract final class AppTheme {
  /// Terracotta from the design mockups.
  static const _seed = Color(0xFFC4451F);

  static ThemeData light() => _build(Brightness.light);
  static ThemeData dark() => _build(Brightness.dark);

  static ColorScheme _scheme(Brightness brightness) {
    final base = ColorScheme.fromSeed(seedColor: _seed, brightness: brightness);
    if (brightness == Brightness.light) {
      return base.copyWith(
        primary: _seed,
        onPrimary: Colors.white,
        primaryContainer: const Color(0xFFFBE6DE),
        onPrimaryContainer: const Color(0xFF7A2410),
        secondary: const Color(0xFF2F4B3C), // deep green: occupancy, "ok"
        onSecondary: Colors.white,
        secondaryContainer: const Color(0xFFE3F1E8),
        onSecondaryContainer: const Color(0xFF173626),
        tertiary: const Color(0xFFD99A1B),
        surface: const Color(0xFFFAF6F2), // warm cream page background
        onSurface: const Color(0xFF2B1B14),
        onSurfaceVariant: const Color(0xFF6B5A50),
        surfaceContainerLowest: Colors.white,
        surfaceContainerLow: Colors.white,
        surfaceContainer: const Color(0xFFF4EEE9),
        surfaceContainerHigh: const Color(0xFFEFE8E2),
        outline: const Color(0xFF8C7A6F),
        outlineVariant: const Color(0xFFE8DDD5),
        error: const Color(0xFFB3261E),
        errorContainer: const Color(0xFFFBE3E0),
        onErrorContainer: const Color(0xFF7A1812),
      );
    }
    return base.copyWith(
      primary: const Color(0xFFF08A63),
      onPrimary: const Color(0xFF4A1405),
      primaryContainer: const Color(0xFF6B2411),
      onPrimaryContainer: const Color(0xFFFFDCD0),
      secondary: const Color(0xFF8CC6A6),
      secondaryContainer: const Color(0xFF173626),
      onSecondaryContainer: const Color(0xFFCDEBDA),
      surface: const Color(0xFF1C1512),
      onSurface: const Color(0xFFF1E6DF),
      onSurfaceVariant: const Color(0xFFC9B9AE),
      surfaceContainerLowest: const Color(0xFF17110E),
      surfaceContainerLow: const Color(0xFF261D19),
      surfaceContainer: const Color(0xFF2B211C),
      surfaceContainerHigh: const Color(0xFF362B25),
      outlineVariant: const Color(0xFF4A3D35),
    );
  }

  static ThemeData _build(Brightness brightness) {
    final scheme = _scheme(brightness);
    final colors = brightness == Brightness.light
        ? AppColors.light
        : AppColors.dark;
    final fieldBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppRadius.field),
      borderSide: BorderSide(color: scheme.outlineVariant),
    );
    final textTheme = Typography.material2021().black
        .apply(bodyColor: scheme.onSurface, displayColor: scheme.onSurface)
        .copyWith(
          // Bold, tight headings like the mockups.
          headlineLarge: const TextStyle(
            fontWeight: FontWeight.w800,
            letterSpacing: -0.5,
          ),
          headlineMedium: const TextStyle(
            fontWeight: FontWeight.w800,
            letterSpacing: -0.5,
          ),
          headlineSmall: const TextStyle(
            fontWeight: FontWeight.w700,
            letterSpacing: -0.3,
          ),
          titleLarge: const TextStyle(fontWeight: FontWeight.w700),
          titleMedium: const TextStyle(fontWeight: FontWeight.w700),
          labelLarge: const TextStyle(fontWeight: FontWeight.w600),
        );
    final shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(AppRadius.field),
    );
    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: scheme.surface,
      extensions: [colors],
      visualDensity: VisualDensity.standard,
      textTheme: textTheme.apply(
        bodyColor: scheme.onSurface,
        displayColor: scheme.onSurface,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: scheme.surfaceContainerLowest,
        foregroundColor: scheme.onSurface,
        surfaceTintColor: Colors.transparent,
        scrolledUnderElevation: 0,
        elevation: 0,
        centerTitle: false,
        shape: Border(bottom: BorderSide(color: scheme.outlineVariant)),
        titleTextStyle: TextStyle(
          color: scheme.onSurface,
          fontSize: 18,
          fontWeight: FontWeight.w700,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: brightness == Brightness.light
            ? const Color(0xFFFAF6F2)
            : scheme.surfaceContainerLowest,
        border: fieldBorder,
        enabledBorder: fieldBorder,
        focusedBorder: fieldBorder.copyWith(
          borderSide: BorderSide(color: scheme.primary, width: 2),
        ),
        errorBorder: fieldBorder.copyWith(
          borderSide: BorderSide(color: scheme.error),
        ),
        focusedErrorBorder: fieldBorder.copyWith(
          borderSide: BorderSide(color: scheme.error, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: Spacing.md,
          vertical: 16,
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size.fromHeight(52),
          shape: shape,
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(kMinTapTarget, 48),
          foregroundColor: scheme.onSurface,
          side: BorderSide(color: scheme.outlineVariant, width: 1.5),
          shape: shape,
          textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          minimumSize: const Size(kMinTapTarget, kMinTapTarget),
          textStyle: const TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: scheme.primary,
        foregroundColor: scheme.onPrimary,
        elevation: 3,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.card),
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 1,
        shadowColor: colors.cardShadow,
        surfaceTintColor: Colors.transparent,
        color: scheme.surfaceContainerLow,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.card),
          side: BorderSide(color: scheme.outlineVariant),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: scheme.surfaceContainerLowest,
        selectedColor: scheme.primary,
        secondarySelectedColor: scheme.primary,
        side: BorderSide(color: scheme.outlineVariant),
        shape: const StadiumBorder(),
        labelStyle: TextStyle(
          color: scheme.onSurface,
          fontWeight: FontWeight.w600,
          fontSize: 13,
        ),
        secondaryLabelStyle: TextStyle(
          color: scheme.onPrimary,
          fontWeight: FontWeight.w600,
          fontSize: 13,
        ),
        checkmarkColor: scheme.onPrimary,
        showCheckmark: false,
      ),
      tabBarTheme: TabBarThemeData(
        labelColor: scheme.primary,
        unselectedLabelColor: scheme.onSurfaceVariant,
        indicatorColor: scheme.primary,
        dividerColor: scheme.outlineVariant,
        labelStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
        unselectedLabelStyle: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 14,
        ),
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: scheme.primary,
        linearTrackColor: scheme.outlineVariant,
      ),
      dividerTheme: DividerThemeData(
        color: scheme.outlineVariant,
        space: 1,
        thickness: 1,
      ),
      listTileTheme: ListTileThemeData(iconColor: scheme.onSurfaceVariant),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: shape,
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: scheme.surfaceContainerLowest,
        surfaceTintColor: Colors.transparent,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: scheme.surfaceContainerLowest,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.card + 4),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: scheme.surfaceContainerLowest,
        surfaceTintColor: Colors.transparent,
        indicatorColor: scheme.primaryContainer,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        iconTheme: WidgetStateProperty.resolveWith(
          (s) => IconThemeData(
            color: s.contains(WidgetState.selected)
                ? scheme.primary
                : scheme.onSurfaceVariant,
          ),
        ),
        labelTextStyle: WidgetStateProperty.resolveWith(
          (s) => TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: s.contains(WidgetState.selected)
                ? scheme.primary
                : scheme.onSurfaceVariant,
          ),
        ),
      ),
      navigationRailTheme: NavigationRailThemeData(
        backgroundColor: scheme.surfaceContainerLowest,
        indicatorColor: scheme.primaryContainer,
        selectedIconTheme: IconThemeData(color: scheme.primary),
        selectedLabelTextStyle: TextStyle(
          color: scheme.primary,
          fontWeight: FontWeight.w700,
        ),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.all(Colors.white),
        trackColor: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.selected)
              ? scheme.primary
              : scheme.outline.withValues(alpha: 0.5),
        ),
        trackOutlineColor: WidgetStateProperty.all(Colors.transparent),
      ),
    );
  }
}
