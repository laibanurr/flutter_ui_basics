import 'package:flutter/material.dart';

class AppUserData extends InheritedWidget {
  const AppUserData({
    required this.userName,
    required this.isPremiumUser,
    required super.child,
    super.key,
  });
  final String userName;
  final bool isPremiumUser;
  static AppUserData of(BuildContext context) {
    final result = context.dependOnInheritedWidgetOfExactType<AppUserData>();
    assert(result != null, 'No AppUserData found in context.');
    return result!;
  }

  @override
  bool updateShouldNotify(AppUserData oldWidget) {
    return userName != oldWidget.userName ||
        isPremiumUser != oldWidget.isPremiumUser;
  }
}

class AppUserDataProvider extends StatefulWidget {
  const AppUserDataProvider({super.key});

  @override
  State<AppUserDataProvider> createState() => _AppUserDataProviderState();
}

class _AppUserDataProviderState extends State<AppUserDataProvider> {
  String _userName = 'Laiba';
  bool _isPremiumUser = false;

  void togglePremium() {
    setState(() {
      _isPremiumUser = !_isPremiumUser;
    });
  }

  void changeUserName(String newName) {
    setState(() {
      _userName = newName;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AppUserData(
      userName: _userName,
      isPremiumUser: _isPremiumUser,
      child: _DemoScreen(
        onChangeUsername: changeUserName,
        onTogglePremium: togglePremium,
      ),
    );
  }
}

class _DemoScreen extends StatelessWidget {
  const _DemoScreen({
    required this.onChangeUsername,
    required this.onTogglePremium,
  });
  final VoidCallback onTogglePremium;
  final ValueChanged<String> onChangeUsername;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('InheritedWidget Demo'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const _UserGreeting(),
            const SizedBox(
              height: 16,
            ),
            const _PremiumBadge(),
            const SizedBox(
              height: 16,
            ),
            const _DeepConsumer(),
            const SizedBox(height: 32),
            FilledButton(
              onPressed: onTogglePremium,
              child: const Text('Toggle premium status'),
            ),
            const SizedBox(height: 12),
            FilledButton.tonal(
              onPressed: () => onChangeUsername('ALI'),
              child: const Text('change username to ALI'),
            ),
            const SizedBox(height: 12),
            FilledButton.tonal(
              onPressed: () => onChangeUsername('Laiba'),
              child: const Text('Reset name to laiba '),
            ),
          ],
        ),
      ),
    );
  }
}

class _UserGreeting extends StatelessWidget {
  const _UserGreeting();

  @override
  Widget build(BuildContext context) {
    final userData = AppUserData.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        'Hello ,${userData.userName}!',
        style: Theme.of(context).textTheme.headlineSmall,
      ),
    );
  }
}

class _PremiumBadge extends StatelessWidget {
  const _PremiumBadge();

  @override
  Widget build(BuildContext context) {
    final userData = AppUserData.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: userData.isPremiumUser
            ? Colors.amber.shade100
            : Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(
            userData.isPremiumUser ? Icons.star : Icons.star_border,
            color: userData.isPremiumUser ? Colors.amber : Colors.grey,
          ),
          const SizedBox(
            width: 8,
          ),
          Text(
            userData.isPremiumUser ? 'Premium Member' : 'Free Tier',
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ],
      ),
    );
  }
}

class _DeepConsumer extends StatelessWidget {
  const _DeepConsumer();

  @override
  Widget build(BuildContext context) {
    final userData = AppUserData.of(context);
    return Text(
      'Deep widget sees ${userData.userName} (${userData.isPremiumUser ? 'Premium' : 'Free'})',
      textAlign: TextAlign.center,
      style: Theme.of(context).textTheme.bodyMedium,
    );
  }
}

class InheritedWidgetDemoScreen extends StatelessWidget {
  const InheritedWidgetDemoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const AppUserDataProvider();
  }
}
