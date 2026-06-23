// KEYS DEMO
// Goal: demonstrate the bug that occurs WITHOUT keys,
// then show how keys fix it — proving why they exist.

import 'package:flutter/material.dart';

class KeysDemoScreen extends StatelessWidget {
  const KeysDemoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor:
              Theme.of(context).colorScheme.inversePrimary,
          title: const Text('Keys Deep Dive'),
          // ─── NOTE: TabBar gives us three tabs to demonstrate
          // each Key type in isolation — cleaner than one long screen.
          bottom: const TabBar(
            tabs: [
              Tab(text: 'The Bug'),
              Tab(text: 'ValueKey'),
              Tab(text: 'GlobalKey'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            _NoBugDemo(),      // Tab 1: shows the bug without keys
            _ValueKeyDemo(),   // Tab 2: fixes it with ValueKey
            _GlobalKeyDemo(),  // Tab 3: demonstrates GlobalKey
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════
// TAB 1: THE BUG — What happens WITHOUT keys
// ═══════════════════════════════════════════════════════

// ─── NOTE: This is the PARENT that owns the list of colored boxes.
// It's Stateful because it needs to remember the current order.
class _NoBugDemo extends StatefulWidget {
  const _NoBugDemo();

  @override
  State<_NoBugDemo> createState() => _NoBugDemoState();
}

class _NoBugDemoState extends State<_NoBugDemo> {
  // The list holds widget instances — their ORDER can be swapped.
  // ⚠ GOTCHA: These are StatefulWidgets with NO keys.
  // Watch what happens to their internal state when we swap order.
  List<Widget> _boxes = [
    const _ColorBox(color: Colors.red, label: 'RED'),
    const _ColorBox(color: Colors.blue, label: 'BLUE'),
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          // ─── NOTE: Explaining the bug before demonstrating it.
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.errorContainer,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              'First tap each box to increment its counter.\n'
              'Then press SWAP and observe what happens\n'
              'to the counter values.',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),

          const SizedBox(height: 24),

          // The two boxes — their ORDER in this list is what we swap.
          ..._boxes,

          const SizedBox(height: 24),

          FilledButton(
            onPressed: () {
              setState(() {
                // ═══ WHY: reversing the list swaps visual order.
                // Watch the COUNTERS after this — they stay with
                // their POSITION, not with their COLOR.
                // That IS the bug.
                _boxes = _boxes.reversed.toList();
              });
            },
            child: const Text('SWAP ORDER (watch the counters)'),
          ),
        ],
      ),
    );
  }
}

// A colored box that tracks how many times it's been tapped.
// ⚠ GOTCHA: This is Stateful — it owns its own counter.
// This internal state is what gets "lost" during the swap bug.
class _ColorBox extends StatefulWidget {
  const _ColorBox({
    super.key,
    required this.color,
    required this.label,
  });

  final Color color;
  final String label;

  @override
  State<_ColorBox> createState() => _ColorBoxState();
}

class _ColorBoxState extends State<_ColorBox> {
  // ─── NOTE: This counter lives on the State object.
  // It is NOT tied to the color or label — it's just a number
  // the State object remembers. This is what causes the bug.
  int _tapCount = 0;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => setState(() => _tapCount++),
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          // ─── NOTE: color comes from the WIDGET (config).
          // tapCount comes from the STATE (memory).
          // After the swap bug: color updates, tapCount doesn't.
          // This proves State is matched by position, not by widget.
          color: widget.color,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              widget.label,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            Text(
              'Taps: $_tapCount',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════
// TAB 2: THE FIX — ValueKey solves the position-matching bug
// ═══════════════════════════════════════════════════════

class _ValueKeyDemo extends StatefulWidget {
  const _ValueKeyDemo();

  @override
  State<_ValueKeyDemo> createState() => _ValueKeyDemoState();
}

class _ValueKeyDemoState extends State<_ValueKeyDemo> {
  // ═══ WHY: Same setup as Tab 1, but now each _ColorBox
  // has a ValueKey. Flutter uses the key — not position —
  // to match Elements. State follows the key, not the slot.
  List<Widget> _boxes = [
    const _ColorBox(
      // ─── NOTE: ValueKey takes any value that uniquely
      // identifies this widget among its siblings.
      // The value must be stable — don't use random numbers
      // or DateTime.now() as keys. Use meaningful identifiers.
      key: ValueKey('red'),
      color: Colors.red,
      label: 'RED',
    ),
    const _ColorBox(
      key: ValueKey('blue'),
      color: Colors.blue,
      label: 'BLUE',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              'Same demo — but boxes now have ValueKeys.\n'
              'Tap boxes to increment, then SWAP.\n'
              'Counters now follow their box correctly.',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),

          const SizedBox(height: 24),

          ..._boxes,

          const SizedBox(height: 24),

          FilledButton(
            onPressed: () {
              setState(() {
                _boxes = _boxes.reversed.toList();
              });
            },
            child: const Text('SWAP ORDER (counters follow the box)'),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════
// TAB 3: GlobalKey — accessing State from outside the tree
// ═══════════════════════════════════════════════════════

class _GlobalKeyDemo extends StatefulWidget {
  const _GlobalKeyDemo();

  @override
  State<_GlobalKeyDemo> createState() => _GlobalKeyDemoState();
}

class _GlobalKeyDemoState extends State<_GlobalKeyDemo> {
  // ═══ WHY: GlobalKey gives us a direct reference to a specific
  // State object — accessible from ANYWHERE in the widget tree.
  // This is powerful but expensive. Use it sparingly.
  // Most common legitimate uses: Form validation, Scaffold.of(),
  // programmatically triggering animations on a specific widget.
  final GlobalKey<_CounterWidgetState> _counterKey =
      GlobalKey<_CounterWidgetState>();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.secondaryContainer,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              'GlobalKey lets a PARENT directly access\n'
              'a child\'s State object and call methods on it.\n'
              'The button below lives in the PARENT but controls\n'
              'the counter that lives in the CHILD.',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),

          const SizedBox(height: 24),

          // ─── NOTE: We pass the GlobalKey to this widget.
          // Flutter registers this key in a global lookup table —
          // that's why it's "global" — accessible from any widget.
          _CounterWidget(key: _counterKey),

          const SizedBox(height: 24),

          FilledButton(
            onPressed: () {
              // ═══ WHY: .currentState gives us the actual State
              // object — we can call methods on it directly.
              // This bypasses the normal data-down/events-up flow.
              // ⚠ GOTCHA: .currentState is nullable — always
              // null-check before calling methods on it.
              _counterKey.currentState?.incrementFromOutside();
            },
            child: const Text(
              'Increment counter from PARENT (via GlobalKey)',
            ),
          ),
        ],
      ),
    );
  }
}

// A widget whose State is accessed externally via GlobalKey.
class _CounterWidget extends StatefulWidget {
  const _CounterWidget({super.key});

  @override
  State<_CounterWidget> createState() => _CounterWidgetState();
}

class _CounterWidgetState extends State<_CounterWidget> {
  int _count = 0;

  // ═══ WHY: This is a PUBLIC method on the State class —
  // intentionally exposed so the GlobalKey holder can call it.
  // In well-architected apps this pattern is rare — state
  // management solutions (Riverpod, Bloc) replace most GlobalKey
  // use cases. But for Form validation and specific framework
  // needs, GlobalKey remains the correct tool.
  void incrementFromOutside() {
    setState(() => _count++);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.tertiaryContainer,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Text(
            'Child Counter',
            style: Theme.of(context).textTheme.labelLarge,
          ),
          Text(
            '$_count',
            style: Theme.of(context).textTheme.displayLarge,
          ),
          Text(
            '(controlled by parent via GlobalKey)',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}