import 'package:flutter/material.dart';
import 'package:magic_epaper_app/screens/display_selection_screen.dart';
import 'package:provider/provider.dart';
import 'models/app_state.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => MyAppState(),
      child: MaterialApp(
        title: 'Magic E-Paper App',
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        ),
        home: const DisplaySelectionScreen(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
