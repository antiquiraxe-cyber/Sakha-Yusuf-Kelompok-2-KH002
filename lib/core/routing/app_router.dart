import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/register_screen.dart';
import '../../features/child_profile/presentation/providers/child_provider.dart';
import '../../features/child_profile/presentation/screens/add_child_screen.dart';
import '../../features/child_profile/presentation/screens/child_list_screen.dart';
import '../../features/milestone/presentation/screens/milestone_screen.dart';
import '../../features/tracking/presentation/screens/tracking_screen.dart';

class AppRouter {
  AppRouter._();

  static final GoRouter router = GoRouter(
    initialLocation: '/login',
    redirect: (context, state) {
      final user = FirebaseAuth.instance.currentUser;
      final isAuthRoute =
          state.uri.path == '/login' || state.uri.path == '/register';

      // Belum login & bukan di halaman login/register -> paksa ke /login
      if (user == null && !isAuthRoute) {
        return '/login';
      }

      // Sudah login tapi masih di halaman login/register -> arahkan ke /home
      if (user != null && isAuthRoute) {
        return '/home';
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        name: 'register',
        builder: (context, state) => const RegisterScreen(),
      ),
      // Shell Route untuk Bottom Navigation
      ShellRoute(
        builder: (context, state, child) => MainShell(child: child),
        routes: [
          GoRoute(
            path: '/home',
            name: 'home',
            builder: (context, state) => const ChildListScreen(),
          ),
          GoRoute(
            path: '/milestone/:childId',
            name: 'milestone',
            builder: (context, state) => MilestoneScreen(
              childId: state.pathParameters['childId']!,
            ),
          ),
          GoRoute(
            path: '/tracking/:childId',
            name: 'tracking',
            builder: (context, state) => TrackingScreen(
              childId: state.pathParameters['childId']!,
            ),
          ),
        ],
      ),
      GoRoute(
        path: '/add-child',
        name: 'addChild',
        builder: (context, state) => const AddChildScreen(),
      ),
    ],
  );
}

class MainShell extends ConsumerWidget {
  final Widget child;

  const MainShell({super.key, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _calculateSelectedIndex(context),
        onDestinationSelected: (index) => _onItemTapped(index, context, ref),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Beranda',
          ),
          NavigationDestination(
            icon: Icon(Icons.child_care_outlined),
            selectedIcon: Icon(Icons.child_care),
            label: 'Milestone',
          ),
          NavigationDestination(
            icon: Icon(Icons.monitor_weight_outlined),
            selectedIcon: Icon(Icons.monitor_weight),
            label: 'Catatan',
          ),
        ],
      ),
    );
  }

  int _calculateSelectedIndex(BuildContext context) {
    final location = GoRouterState.of(context).uri.toString();
    if (location.startsWith('/tracking')) return 2;
    if (location.startsWith('/milestone')) return 1;
    return 0;
  }

  void _onItemTapped(int index, BuildContext context, WidgetRef ref) {
    if (index == 0) {
      context.goNamed('home');
      return;
    }

    final selectedChild = ref.read(selectedChildProvider);
    if (selectedChild == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Tambahkan data anak terlebih dahulu'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      context.goNamed('home');
      return;
    }

    if (index == 1) {
      context.goNamed('milestone', pathParameters: {'childId': selectedChild.id});
    } else if (index == 2) {
      context.goNamed('tracking', pathParameters: {'childId': selectedChild.id});
    }
  }
}
