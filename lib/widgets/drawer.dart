import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../routes/provider.dart';

class AppDrawer extends ConsumerStatefulWidget {
  const AppDrawer({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _AppDrawerState();
}

class _AppDrawerState extends ConsumerState<AppDrawer> {
  @override
  Widget build(BuildContext context) {
    final router = ref.watch(routerProvider);
    return Drawer(
      child: ListView(
        children: [
          const DrawerHeader(child: Text('Menu')),
          ListTile(
            title: const Text('chatbot'),
            onTap: () {
              router.go('/');
              router.pop(context);
            },
          ),
          ListTile(
            title: const Text('Chat with PDF'),
            onTap: () {
              router.go('/chatPDF');
              router.pop(context);
            },
          ),
        ],
      ),
    );
  }
}
