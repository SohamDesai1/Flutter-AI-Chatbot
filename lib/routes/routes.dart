import 'package:go_router/go_router.dart';
import '../screens/home.dart';

GoRouter router = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const Home(),
    )
  ],
);
