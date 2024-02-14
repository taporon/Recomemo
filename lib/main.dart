import 'package:RecoMemo/top_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:showcaseview/showcaseview.dart';

void main() => runApp(
  ProviderScope(
    child: ShowCaseWidget(
      builder: Builder(
          builder : (context)=> const MyApp(),
      ),
    ),
  ),
);

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'RecoMemo',
      debugShowCheckedModeBanner: false,
      // ダークテーマをアプリケーションのメインテーマとして設定
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        colorScheme: lightColorScheme,
        appBarTheme: AppBarTheme(
          backgroundColor: lightColorScheme.primary,
          foregroundColor: lightColorScheme.onPrimary,
        ),
        tabBarTheme: TabBarTheme(
          labelColor: lightColorScheme.onSecondary,
          unselectedLabelColor: lightColorScheme.onPrimary.withOpacity(0.7),
          indicator: UnderlineTabIndicator(
            borderSide: BorderSide(color: lightColorScheme.secondaryContainer, width: 2.0),
          ),
        ),
      ),
      // アプリケーションを常にダークモードで表示する
      home: const TopPage(),
    );
  }
}

const lightColorScheme = ColorScheme(
  brightness: Brightness.light,
  primary: Color(0xFF476810),
  onPrimary: Color(0xFFFFFFFF),
  primaryContainer: Color(0xFFC7F089),
  onPrimaryContainer: Color(0xFF121F00),
  secondary: Color(0xFF586249),
  onSecondary: Color(0xFFFFFFFF),
  secondaryContainer: Color(0xFFDCE7C7),
  onSecondaryContainer: Color(0xFF161E0A),
  tertiary: Color(0xFF396662),
  onTertiary: Color(0xFFFFFFFF),
  tertiaryContainer: Color(0xFFBCECE6),
  onTertiaryContainer: Color(0xFF00201E),
  error: Color(0xFFBA1A1A),
  errorContainer: Color(0xFFFFDAD6),
  onError: Color(0xFFFFFFFF),
  onErrorContainer: Color(0xFF410002),
  background: Color(0xFFFEFCF5),
  onBackground: Color(0xFF1B1C18),
  surface: Color(0xFFFEFCF5),
  onSurface: Color(0xFF1B1C18),
  surfaceVariant: Color(0xFFE1E4D5),
  onSurfaceVariant: Color(0xFF45483D),
  outline: Color(0xFF75786C),
  onInverseSurface: Color(0xFFF2F1E9),
  inverseSurface: Color(0xFF30312C),
  inversePrimary: Color(0xFFACD370),
  shadow: Color(0xFF000000),
  surfaceTint: Color(0xFF476810),
  outlineVariant: Color(0xFFC5C8B9),
  scrim: Color(0xFF000000),
);

