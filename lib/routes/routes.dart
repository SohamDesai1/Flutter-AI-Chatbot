import 'package:go_router/go_router.dart';
import '../screens/home.dart';
import '../screens/chat_with_pdf.dart';

GoRouter router = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const Home(),
    ),
    GoRoute(
      path: '/chatPDF',
      builder: (context, state) => const ChatPDF(),
    )
  ],
);
