import 'package:flutter/material.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/login_screen.dart';
import 'features/History/history_screen.dart';
import 'features/home/home_screen.dart';
import 'features/profile/profile_screen.dart';
import 'features/splash/splash_screen.dart';
import 'features/trash/trash_screen.dart';
import 'services/api_service.dart';
import 'services/secure_storage_service.dart';

class NovaTasksApp extends StatefulWidget {
  const NovaTasksApp({super.key});

  @override
  State<NovaTasksApp> createState() => _NovaTasksAppState();
}

class _NovaTasksAppState extends State<NovaTasksApp> {
  final SecureStorageService _storageService = SecureStorageService();
  ThemeMode themeMode = ThemeMode.light;
  bool isLoading = true;
  bool isAuthenticated = false;
  String username = '';
  int index = 0;

  List<Widget> get pages => [
    const HomeScreen(),
    const HistoryScreen(),
    const TrashScreen(),
    ProfileScreen(username: username, onLogout: _handleLogout),
  ];

  @override
  void initState() {
    super.initState();
    _initializeAuthState();
  }

  Future<void> _initializeAuthState() async {
    final loggedIn = await _storageService.isLoggedIn();
    var storedUsername = await _storageService.getUsername();

    if (loggedIn && (storedUsername == null || storedUsername.isEmpty)) {
      try {
        final user = await ApiService.getUser();
        storedUsername = user['name'] as String? ?? '';
      } catch (_) {
        storedUsername = '';
      }
    }

    if (!mounted) return;

    setState(() {
      isAuthenticated = loggedIn;
      username = storedUsername ?? '';
      isLoading = false;
    });
  }

  Future<void> _handleLogin(String username) async {
    setState(() {
      this.username = username;
      isAuthenticated = true;
      index = 0;
    });
  }

  Future<void> _handleLogout() async {
    try {
      await ApiService.logout();
    } catch (_) {
      // ignore errors while logging out
    }

    await _storageService.logout();

    if (!mounted) return;

    setState(() {
      username = '';
      isAuthenticated = false;
      index = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        darkTheme: AppTheme.dark,
        themeMode: themeMode,
        home: const SplashScreen(),
      );
    }

    if (!isAuthenticated) {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        darkTheme: AppTheme.dark,
        themeMode: themeMode,
        home: AuthScreen(onLogin: _handleLogin),
      );
    }

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: themeMode,
      home: Scaffold(
        body: pages[index],
        bottomNavigationBar: NavigationBar(
          selectedIndex: index,
          onDestinationSelected: (i) => setState(() => index = i),
          destinations: const [
            NavigationDestination(icon: Icon(Icons.home), label: "Home"),
            NavigationDestination(icon: Icon(Icons.history), label: "History"),
            NavigationDestination(
              icon: Icon(Icons.restore_from_trash),
              label: "Trash",
            ),
            NavigationDestination(icon: Icon(Icons.person), label: "Profile"),
          ],
        ),
      ),
    );
  }
}
