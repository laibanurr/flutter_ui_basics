// ROOT APP CONFIGURATION
// MaterialApp is the top-level widget that provides:
// - Material Design theming
// - Navigation infrastructure (Navigator widget)
// - Localization delegates
// - Media query data
// This widget inserts many inherited widgets above your widget tree
// that child widgets access via BuildContext (e.g., Theme.of(context)).

import 'package:flutter/material.dart';
import 'package:flutter_ui_basics/features/state_lifecycle/state_lifecycle_demo_screen.dart';

class MyApp extends StatelessWidget {
  // 'const' constructor: tells Flutter this widget's configuration
  // will never change. Flutter can cache and reuse it safely.
  // Always use const constructors when a widget has no mutable config.
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // BuildContext here points to the Element for MyApp.
    // At this point in the tree, very few ancestors exist above us.
    return MaterialApp(
      title: 'Flutter Core Foundations',

      // debugShowCheckedModeBanner removes the debug ribbon.
      // Always set false before any screenshot or demo.
      debugShowCheckedModeBanner: false,

      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        // useMaterial3: true is the modern default as of Flutter 3.x.
        // Material 2 is legacy. We always write Material 3.
        useMaterial3: true,
      ),

      // home is the widget displayed at the '/' route.
      home: const StateLifecycleDemoScreen(),
    );
  }
}
