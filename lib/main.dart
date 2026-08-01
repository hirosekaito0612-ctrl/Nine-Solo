import 'package:flutter/material.dart';

import 'models/quit_data.dart';
import 'screens/home_screen.dart';
import 'screens/onboarding_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const YameNyanApp());
}

ThemeData buildTheme(Brightness brightness) {
  final ColorScheme scheme = ColorScheme.fromSeed(
    seedColor: const Color(0xFF3BB27A),
    brightness: brightness,
  );
  return ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    scaffoldBackgroundColor:
        brightness == Brightness.light ? const Color(0xFFF3F6F1) : null,
    fontFamily: 'sans-serif',
  );
}

class YameNyanApp extends StatelessWidget {
  const YameNyanApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ヤメにゃん',
      debugShowCheckedModeBanner: false,
      theme: buildTheme(Brightness.light),
      darkTheme: buildTheme(Brightness.dark),
      home: const _Root(),
    );
  }
}

/// 起動時に保存データを読み込み、オンボーディング済みかどうかで画面を分岐する。
class _Root extends StatefulWidget {
  const _Root();

  @override
  State<_Root> createState() => _RootState();
}

class _RootState extends State<_Root> {
  QuitData? _data;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final QuitData d = await QuitData.load();
    if (!mounted) return;
    setState(() {
      _data = d;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    final QuitData data = _data!;
    if (!data.onboarded) {
      return OnboardingScreen(
        data: data,
        onDone: () => setState(() {}),
      );
    }
    return HomeScreen(
      data: data,
      onReset: () => setState(() {}),
    );
  }
}
