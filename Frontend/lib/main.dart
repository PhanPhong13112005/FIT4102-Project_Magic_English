import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';
import 'providers/vocabulary_provider.dart';
import 'providers/writing_provider.dart';
import 'providers/stats_provider.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/dashboard_screen.dart';
import 'screens/magic_vocab_screen.dart';
import 'screens/writing_checker_screen.dart';
import 'screens/stats_screen.dart';
import 'theme/app_theme.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => VocabularyProvider()),
        ChangeNotifierProvider(create: (_) => WritingProvider()),
        ChangeNotifierProvider(create: (_) => StatsProvider()),
      ],
      child: MaterialApp(
        title: 'Magic English',
        theme: ThemeData(
          primarySwatch: Colors.green,
          useMaterial3: true,
          scaffoldBackgroundColor: AppTheme.backgroundColor,
        ),
        home: Consumer<AuthProvider>(
          builder: (context, authProvider, _) {
            return authProvider.isAuthenticated
                ? const HomePage()
                : const LoginScreen();
          },
        ),
        routes: {
          '/login': (context) => const LoginScreen(),
          '/register': (context) => const RegisterScreen(),
          '/home': (context) => const HomePage(),
        },
      ),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  static const List<Widget> _screens = [
    DashboardScreen(),
    MagicVocabScreen(),
    WritingCheckerScreen(),
    StatsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppTheme.primaryGreen,
        elevation: 0,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.school, color: Colors.white, size: 24),
            ),
            const SizedBox(width: 12),
            Text(
              'Magic English',
              style: AppTheme.bodyLarge.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
          ],
        ),
        centerTitle: false,
        actions: [
          Consumer<AuthProvider>(
            builder: (context, authProvider, _) {
              return PopupMenuButton<int>(
                itemBuilder: (BuildContext context) => [
                  PopupMenuItem<int>(
                    value: 1,
                    child: Row(
                      children: [
                        const Icon(Icons.person, color: AppTheme.darkText),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              authProvider.currentUser?.fullName ?? 'User',
                              style: AppTheme.bodyLarge,
                            ),
                            Text(
                              authProvider.currentUser?.email ?? '',
                              style: AppTheme.bodyMedium,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const PopupMenuDivider(),
                  PopupMenuItem<int>(
                    value: 2,
                    onTap: () async {
                      await authProvider.logout();
                      if (context.mounted) {
                        // ignore: use_build_context_synchronously
                        Navigator.of(context).pushReplacementNamed('/login');
                      }
                    },
                    child: Row(
                      children: [
                        const Icon(Icons.logout, color: AppTheme.errorRed),
                        const SizedBox(width: 12),
                        Text(
                          'Logout',
                          style: AppTheme.bodyLarge.copyWith(
                            color: AppTheme.errorRed,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        selectedItemColor: AppTheme.primaryGreen,
        unselectedItemColor: AppTheme.lightText,
        items: [
          BottomNavigationBarItem(
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: _selectedIndex == 0
                  ? BoxDecoration(
                      color: AppTheme.primaryGreen.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    )
                  : null,
              child: Icon(
                Icons.home,
                color: _selectedIndex == 0
                    ? AppTheme.primaryGreen
                    : AppTheme.lightText,
              ),
            ),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: _selectedIndex == 1
                  ? BoxDecoration(
                      color: AppTheme.primaryGreen.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    )
                  : null,
              child: Icon(
                Icons.library_books,
                color: _selectedIndex == 1
                    ? AppTheme.primaryGreen
                    : AppTheme.lightText,
              ),
            ),
            label: 'Vocabulary',
          ),
          BottomNavigationBarItem(
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: _selectedIndex == 2
                  ? BoxDecoration(
                      color: AppTheme.primaryGreen.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    )
                  : null,
              child: Icon(
                Icons.edit_document,
                color: _selectedIndex == 2
                    ? AppTheme.primaryGreen
                    : AppTheme.lightText,
              ),
            ),
            label: 'Writing',
          ),
          BottomNavigationBarItem(
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: _selectedIndex == 3
                  ? BoxDecoration(
                      color: AppTheme.primaryGreen.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    )
                  : null,
              child: Icon(
                Icons.bar_chart,
                color: _selectedIndex == 3
                    ? AppTheme.primaryGreen
                    : AppTheme.lightText,
              ),
            ),
            label: 'Stats',
          ),
        ],
      ),
    );
  }
}
