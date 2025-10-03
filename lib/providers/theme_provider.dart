import 'package:flutter/material.dart';

class ThemeProvider with ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.light;

  ThemeMode get themeMode => _themeMode;
  bool get isDarkMode => _themeMode == ThemeMode.dark;

  void toggleTheme(bool isDark) {
    _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
  }

  void setTheme(ThemeMode mode) {
    _themeMode = mode;
    notifyListeners();
  }
}

class AppThemes {
  static final ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    primaryColor: const Color(0xFF88844D),
    scaffoldBackgroundColor: const Color(0xFFF7F2E4),
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFFF7F2E4),
      elevation: 0,
      iconTheme: IconThemeData(color: Color(0xFF88844D)),
      titleTextStyle: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: Color(0xFF88844D),
      ),
    ),
    cardColor: Colors.white,
    cardTheme: CardTheme(
      color: Colors.white,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: Color(0xFF88844D)),
      bodyMedium: TextStyle(color: Color(0xFF88844D)),
      titleMedium: TextStyle(color: Color(0xFF88844D)),
      titleSmall: TextStyle(color: Color(0xFF88844D)),
    ),
    iconTheme: const IconThemeData(color: Color(0xFF88844D)),
    listTileTheme: ListTileThemeData(
      tileColor: Colors.white,
      textColor: const Color(0xFF88844D),
      iconColor: const Color(0xFF88844D),
    ),
    dialogBackgroundColor: const Color(0xFFF7F2E4),
    switchTheme: SwitchThemeData(
      thumbColor: MaterialStateProperty.all(const Color(0xFF88844D)),
      trackColor: MaterialStateProperty.all(const Color(0xFFBEC092).withOpacity(0.5)),
    ),
  );

  static final ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    primaryColor: const Color(0xFFBEC092),
    scaffoldBackgroundColor: const Color(0xFF121212),
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF1E1E1E),
      elevation: 0,
      iconTheme: IconThemeData(color: Color(0xFFBEC092)),
      titleTextStyle: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: Color(0xFFBEC092),
      ),
    ),
    cardColor: const Color(0xFF1E1E1E),
    cardTheme: CardTheme(
      color: const Color(0xFF1E1E1E),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: Colors.white),
      bodyMedium: TextStyle(color: Colors.white70),
      titleMedium: TextStyle(color: Colors.white),
      titleSmall: TextStyle(color: Colors.white70),
    ),
    iconTheme: const IconThemeData(color: Color(0xFFBEC092)),
    listTileTheme: const ListTileThemeData(
      tileColor: Color(0xFF1E1E1E),
      textColor: Colors.white,
      iconColor: Color(0xFFBEC092),
    ),
    dialogBackgroundColor: const Color(0xFF1E1E1E),
    switchTheme: SwitchThemeData(
      thumbColor: MaterialStateProperty.all(const Color(0xFFBEC092)),
      trackColor: MaterialStateProperty.all(const Color(0xFF88844D).withOpacity(0.5)),
    ),
  );
}