import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:magic_english/providers/app_providers.dart';
import 'package:magic_english/services/user_service.dart';
import 'package:magic_english/screens/auth_screen.dart';
import 'package:magic_english/screens/dashboard_screen.dart';
import 'package:magic_english/screens/vocabulary_screen.dart';
import 'package:magic_english/screens/grammar_screen.dart';

/// Home Screen with Navigation
class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  final List<BottomNavigationBarItem> _navItems = [
    const BottomNavigationBarItem(
      icon: Icon(Icons.dashboard),
      label: 'Dashboard',
    ),
    const BottomNavigationBarItem(
      icon: Icon(Icons.book),
      label: 'Vocabulary',
    ),
    const BottomNavigationBarItem(
      icon: Icon(Icons.edit),
      label: 'Grammar',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  void _loadInitialData() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userId = UserService.getCurrentUserId();
      if (userId != null) {
        // Load dashboard data
        final dashboardProvider = context.read<DashboardProvider>();
        dashboardProvider.loadDashboard(userId);
        dashboardProvider.loadStreak(userId);
        dashboardProvider.loadActivityTrend(userId);

        // Load vocabularies
        final vocabProvider = context.read<VocabularyProvider>();
        vocabProvider.loadVocabularies(userId);
        vocabProvider.loadStatistics(userId);

        // Load grammar history
        final grammarProvider = context.read<GrammarProvider>();
        grammarProvider.loadHistory(userId);
      }
    });
  }

  Widget _getScreen() {
    switch (_selectedIndex) {
      case 0:
        return const DashboardScreen();
      case 1:
        return const VocabularyScreen();
      case 2:
        return const GrammarScreen();
      default:
        return const DashboardScreen();
    }
  }

  void _handleLogout() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              UserService.logout();
              context.read<AuthProvider>().logout();
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (_) => const AuthScreen()),
              );
            },
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final userName = UserService.getCurrentUserName() ?? 'User';

    return Scaffold(
      appBar: AppBar(
        title: Text('Magic English - Hi $userName! 👋'),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _handleLogout,
          ),
        ],
      ),
      body: _getScreen(),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        items: _navItems,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
      ),
    );
  }
}
