import 'package:apple_required_reasons_api_generator/home_page.dart';
import 'package:flutter/material.dart';

void main() => runApp(const App());

final class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
        home: const HomePage(),
        theme: ThemeData.light(),
        darkTheme: ThemeData.dark(),
      );
}
