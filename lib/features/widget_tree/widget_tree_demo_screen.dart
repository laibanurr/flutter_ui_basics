// WIDGET TREE DEMO
// Goal: demonstrate the widget tree hierarchy visually
// and prove that widgets are just nested configuration objects.

import 'package:flutter/material.dart';

// StatelessWidget: a widget whose configuration never changes after creation.
// Flutter calls build() and the result is final until this widget
// is replaced in the tree entirely.
// Use when: no internal mutable state is needed.
class WidgetTreeDemoScreen extends StatelessWidget {
  const WidgetTreeDemoScreen({super.key});

  // build() is called by the Element managing this widget's position.
  // It returns a widget — which becomes a subtree in the widget tree.
  // Flutter NEVER calls build() directly — the Element does.
  @override
  Widget build(BuildContext context) {
    // Scaffold implements the basic Material Design visual layout structure.
    // Think of it as the Activity layout root — it provides slots:
    // appBar, body, floatingActionButton, drawer, bottomNavigationBar, etc.
    return Scaffold(
      appBar: AppBar(
        // Theme.of(context) walks UP the Element tree from this widget's
        // position until it finds a Theme ancestor (inserted by MaterialApp)
        // This is dependency injection via the tree —
        // no singleton, no service locator.
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Widget Tree Anatomy'),
      ),

      // The body is itself a widget — a Center widget.
      // Every layout instruction in Flutter is a widget.
      // There is no XML, no separate layout system.
      body: const _TreeDemoBody(),
    );
  }
}

// Private widget (prefixed with _): not accessible outside this file.
// Extract widgets into private classes to keep build() methods readable.
// This is a core Flutter best practice — keep build() shallow.
// A build() that nests more than 3-4 levels deep should be refactored.
class _TreeDemoBody extends StatelessWidget {
  const _TreeDemoBody();

  @override
  Widget build(BuildContext context) {
    // Column: a layout widget that arranges children vertically.
    // It is a MultiChildRenderObjectWidget — meaning it directly
    // contributes to the RenderObject tree and performs layout.
    return Column(
      // mainAxisAlignment controls positioning along the main axis.
      // For Column, main axis = vertical.
      mainAxisAlignment: MainAxisAlignment.center,

      // children is a List<Widget> — each child is a blueprint.
      // Flutter instantiates Elements for each and manages them independently.
      children: [
        // A simple Text widget. Immutable. Stateless.
        // Its only job: describe "render this string in this style."
        const Text(
          'I am a Widget — just a blueprint.',
          // TextStyle is also immutable configuration — not a rendered object.
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),

        // SizedBox: a layout widget that creates a fixed-size box.
        // Commonly used for spacing. More explicit and readable than Padding
        // when you just need a gap between elements.
        const SizedBox(height: 24),

        // Container is Flutter's most flexible single-child layout widget.
        // It combines: padding, margin, decoration, size constraints, alignment
        // Android analogy: a FrameLayout with a background
        // drawable, margins, and padding.
        Container(
          // Padding inside the container's boundary.
          padding: const EdgeInsets.all(16),

          // BoxDecoration describes the visual style of the Container's box.
          // The Container itself has no visual — BoxDecoration provides it.
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primaryContainer,
            // BorderRadius clips the corners.
            // Applied to the decoration, not the widget.
            borderRadius: BorderRadius.circular(12),
          ),

          // The single child of this Container.
          child: const Text(
            'I am inside a Container — \nalso just a blueprint.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16),
          ),
        ),

        const SizedBox(height: 24),

        // This widget intentionally demonstrates context usage.
        // We call a method — also valid Flutter style for extracting
        // widget subtrees when you need to pass local variables.
        _buildContextDemo(context),
      ],
    );
  }

  // A private method returning a Widget.
  // Use methods for small, simple extractions.
  // Use classes (like _TreeDemoBody above) for anything with complexity.
  // The tradeoff: class widgets get their own Element and can be
  // individually diffed by Flutter. Method results are inlined
  // into the parent's build output — no separate Element.
  Widget _buildContextDemo(BuildContext context) {
    // TextTheme provides pre-configured text styles from the active theme.
    // Accessed via context — proving context is a tree-position pointer
    // that lets you reach inherited data from ancestors.
    final textTheme = Theme.of(context).textTheme;

    return Text(
      "Theme accessed via BuildContext\n(a pointer to my Element's position)",
      textAlign: TextAlign.center,
      // bodyMedium is a Ma//terial 3 text style.
      style: textTheme.bodyMedium,
    );
  }
}
