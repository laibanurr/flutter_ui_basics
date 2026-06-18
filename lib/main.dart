// ENTRY POINT — This is the only job of main.dart.
// It bootstraps the Flutter engine and hands control to our app widget.
// Keep this file minimal. Business logic, routing, UI — none of it lives here.

import 'package:flutter/material.dart';
import 'app.dart'; // We separate app configuration into its own file.

// main() is the Dart VM entry point.
// runApp() inflates the given widget and attaches it to the screen.
// It calls the widget's build() and makes it the root of the widget tree.
void main() {
  runApp(const MyApp());
}