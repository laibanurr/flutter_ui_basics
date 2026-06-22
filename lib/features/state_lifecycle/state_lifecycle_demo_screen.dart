// STATE LIFECYCLE DEMO
// Goal: observe every lifecycle method firing in sequence
// and understand WHEN Flutter calls each one and WHY.

import 'package:flutter/material.dart';

// ─── NOTE: StatefulWidget is split into TWO classes by design.
// The Widget class stays immutable (config only).
// The State class holds all mutable data and lifecycle methods.
class StateLifecycleDemoScreen extends StatefulWidget {
  // ⚠ GOTCHA: StatefulWidget itself is still immutable — never add
  // mutable fields here. All mutable data belongs in State<T>.
  const StateLifecycleDemoScreen({super.key});

  // createState() is a factory — its ONLY job is to instantiate
  // the State object. Flutter calls this exactly once per Element.
  // Never put initialization logic here.
  @override
  State<StateLifecycleDemoScreen> createState() =>
      _StateLifecycleDemoScreenState();
}

class _StateLifecycleDemoScreenState extends State<StateLifecycleDemoScreen> {
  // ─── NOTE: These fields live on the State object, which is
  // attached to the Element — they survive widget rebuilds.
  // This is WHY state persists even though the Widget is recreated.
  int _counter = 0;
  final List<String> _lifecycleLog = [];

  // ═══ WHY: initState is where we initialize anything that requires
  // the widget's configuration (via `widget.someProperty`).
  // Called ONCE. Never call setState() inside initState() directly —
  // the widget isn't mounted yet and it's unnecessary overhead.
  @override
  void initState() {
    // ⚠ GOTCHA: super.initState() MUST be called first, always.
    // The framework does critical setup in the parent implementation.
    super.initState();
    _lifecycleLog.add(
      '1. initState() — State object born, '
      'called exactly once',
    );
  }

  // ═══ WHY: didChangeDependencies fires after initState AND whenever
  // an InheritedWidget dependency changes (e.g., Theme, MediaQuery).
  // Safe to call Theme.of(context) here, unlike in initState().
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // ─── NOTE: We only log the first call to avoid noise —
    // this method can fire multiple times during a widget's life.
    if (_lifecycleLog.length < 2) {
      _lifecycleLog.add(
        '2. didChangeDependencies() — '
        'InheritedWidget deps resolved',
      );
    }
  }

  // ═══ WHY: build() is a pure function — it reads current state
  // and returns a widget description. No side effects allowed here.
  // Flutter may call this dozens of times per second.
  @override
  Widget build(BuildContext context) {
    // ─── NOTE: We add to the log here only on the first build
    // to demonstrate sequence — in real code, NEVER log in build().
    if (_lifecycleLog.length < 3) {
      _lifecycleLog.add('3. build() — UI described from current state');
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('State Lifecycle'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── Counter display — rebuilds every setState() call
            _CounterDisplay(count: _counter),

            const SizedBox(height: 32),

            // ── Lifecycle log — shows methods firing in sequence
            _LifecycleLog(entries: _lifecycleLog),

            const SizedBox(height: 32),

            // ── Button that triggers setState()
            FilledButton(
              onPressed: _incrementCounter,
              child: const Text('Increment Counter'),
            ),

            const SizedBox(height: 12),

            // ── Button that demonstrates dispose() by navigating away
            FilledButton.tonal(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  // ⚠ GOTCHA: When this new route pushes onto the stack,
                  // this widget is deactivated but NOT disposed — it's
                  // still in the tree, just not visible.
                  // Only popping back and then pushing again after full
                  // removal triggers dispose().
                  builder: (_) => const _DisposeDemoScreen(),
                ),
              ),
              child: const Text('See dispose() demo →'),
            ),
          ],
        ),
      ),
    );
  }

  // ═══ WHY: setState() does two things:
  // 1. Runs the closure you pass it (mutating state)
  // 2. Marks this Element as dirty, scheduling a rebuild
  // Flutter batches dirty Elements and rebuilds them efficiently —
  // calling setState() doesn't rebuild the whole tree, only this
  // widget's subtree.
  void _incrementCounter() {
    setState(() {
      // ─── NOTE: mutation MUST happen inside the setState closure.
      // Mutating state outside setState() changes the data but
      // does NOT schedule a rebuild — the UI won't update.
      _counter++;
      _lifecycleLog.add(
        '→ setState() called: counter is now $_counter',
      );
    });
  }

  // ═══ WHY: didUpdateWidget fires when the PARENT rebuilds and sends
  // a new widget configuration to this same State object.
  // oldWidget lets you compare previous vs new config to react.
  @override
  void didUpdateWidget(StateLifecycleDemoScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    // In this demo the parent never changes config, so this won't fire.
    // Left here for completeness — always override if your widget
    // accepts parameters that can change from the parent.
    _lifecycleLog.add('didUpdateWidget() — parent sent new config');
  }

  // ═══ WHY: dispose() is the cleanup method.
  // Rule: anything you ALLOCATE in initState(), you DISPOSE here.
  // TextEditingController, AnimationController, StreamSubscription,
  // FocusNode — all must be disposed or you leak memory.
  @override
  void dispose() {
    // In this demo we have nothing to dispose —
    // no controllers, no subscriptions.
    // Left here so you see WHERE it goes and WHEN it fires.
    _lifecycleLog.add('4. dispose() — State object destroyed');
    // ⚠ GOTCHA: super.dispose() MUST be called LAST, not first.
    // Opposite of initState() — this is the framework rule.
    super.dispose();
  }
}

// ── Private sub-widget: displays counter value.
// Extracted as a class so Flutter can diff it independently.
// ─── NOTE: This is StateLESS — it receives data, displays it,
// has no memory of its own. The parent owns the counter value.
class _CounterDisplay extends StatelessWidget {
  const _CounterDisplay({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Text(
            'Counter',
            style: Theme.of(context).textTheme.labelLarge,
          ),
          Text(
            '$count',
            style: Theme.of(context).textTheme.displayLarge,
          ),
        ],
      ),
    );
  }
}

// ── Private sub-widget: displays lifecycle event log.
class _LifecycleLog extends StatelessWidget {
  const _LifecycleLog({required this.entries});

  final List<String> entries;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(12),
        ),
        // ─── NOTE: ListView here is NOT ListView.builder because
        // lifecycle log entries are few and bounded in number.
        // ListView.builder overhead is only worth it for large/
        // dynamic lists — we covered this in the Q2 exercise.
        child: ListView(
          children: entries
              .map(
                (entry) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Text(
                    entry,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
              )
              .toList(),
        ),
      ),
    );
  }
}

// ── Separate screen to demonstrate dispose() firing
// when the widget is permanently removed from the tree.
class _DisposeDemoScreen extends StatefulWidget {
  const _DisposeDemoScreen();

  @override
  State<_DisposeDemoScreen> createState() => _DisposeDemoScreenState();
}

class _DisposeDemoScreenState extends State<_DisposeDemoScreen> {
  @override
  void dispose() {
    // ⚠ GOTCHA: In a real app, you'd dispose controllers here.
    // This fires when you pop this route off the Navigator stack —
    // proving that navigation away permanently removes the widget
    // and triggers disposal.
    debugPrint(
      '_DisposeDemoScreen disposed — '
      'check your debug console for this message',
    );
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dispose Demo'),
        // ─── NOTE: AppBar automatically adds a back button when
        // there's a route below this one on the Navigator stack.
        // Pressing it calls Navigator.pop(), which removes this
        // widget and triggers dispose() — watch the debug console.
      ),
      body: const Center(
        child: Text(
          'Press ← back and watch\nthe debug console for\ndispose() firing.',
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
