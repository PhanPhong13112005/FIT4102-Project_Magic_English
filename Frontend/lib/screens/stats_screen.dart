import 'package:fit4102_project_magic_english/providers/stats_provider.dart';
import 'package:fit4102_project_magic_english/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class StatsScreen extends StatefulWidget {
  const StatsScreen({Key? key}) : super(key: key);

  @override
  State<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      context.read<StatsProvider>().loadDashboard();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: Consumer<StatsProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return Center(
              child: CircularProgressIndicator(color: AppTheme.primaryGreen),
            );
          }

          return SafeArea(
            child: CustomScrollView(
              slivers: [
                SliverAppBar(
                  floating: true,
                  pinned: false,
                  backgroundColor: AppTheme.backgroundColor,
                  elevation: 0,
                  expandedHeight: 0,
                  title: Text(
                    'Tiến bộ & Thành tựu',
                    style: AppTheme.headlineSmall,
                  ),
                ),

                SliverPadding(
                  padding: const EdgeInsets.all(16),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      // Current Streak Card
                      _buildStreakCard(),
                      const SizedBox(height: 16),

                      // Quick Stats
                      _buildQuickStatsRow(),
                      const SizedBox(height: 16),

                      // Achievements Section
                      Text('Thành tích', style: AppTheme.headlineSmall),
                      const SizedBox(height: 12),
                      _buildAchievementsSection(),
                      const SizedBox(height: 16),

                      // Learning Progress
                      Text('Tiến độ học tập', style: AppTheme.headlineSmall),
                      const SizedBox(height: 12),
                      _buildProgressSection(),
                      const SizedBox(height: 24),
                    ]),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildStreakCard() {
    return Container(
      decoration: AppTheme.elevatedCardDecoration,
      padding: const EdgeInsets.all(20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStreakItem(
            icon: Icons.local_fire_department,
            title: 'Chuỗi Hiện Tại',
            value: '12',
            color: Colors.orange,
          ),
          Container(height: 50, width: 1, color: AppTheme.borderColor),
          _buildStreakItem(
            icon: Icons.trending_up,
            title: 'Chuỗi Dài Nhất',
            value: '28',
            color: AppTheme.primaryGreen,
          ),
        ],
      ),
    );
  }

  Widget _buildStreakItem({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return Column(
      children: [
        Icon(icon, color: color, size: 32),
        const SizedBox(height: 8),
        Text(value, style: AppTheme.headlineSmall.copyWith(color: color)),
        const SizedBox(height: 4),
        Text(
          title,
          style: AppTheme.labelSmall.copyWith(color: AppTheme.lightText),
        ),
      ],
    );
  }

  Widget _buildQuickStatsRow() {
    return Row(
      children: [
        Expanded(
          child: Container(
            decoration: AppTheme.cardDecoration,
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Icon(Icons.language, color: AppTheme.primaryGreen, size: 28),
                const SizedBox(height: 8),
                Text('48', style: AppTheme.headlineMedium),
                const SizedBox(height: 4),
                Text(
                  'Từ vựng đã học',
                  style: AppTheme.labelSmall.copyWith(
                    color: AppTheme.lightText,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Container(
            decoration: AppTheme.cardDecoration,
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Icon(Icons.edit_note, color: Colors.blue, size: 28),
                const SizedBox(height: 8),
                Text('24', style: AppTheme.headlineMedium),
                const SizedBox(height: 4),
                Text(
                  'Bài viết đã hoàn thành',
                  style: AppTheme.labelSmall.copyWith(
                    color: AppTheme.lightText,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Container(
            decoration: AppTheme.cardDecoration,
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Icon(Icons.history, color: Colors.purple, size: 28),
                const SizedBox(height: 8),
                Text('12h', style: AppTheme.headlineMedium),
                const SizedBox(height: 4),
                Text(
                  'Thời gian Học',
                  style: AppTheme.labelSmall.copyWith(
                    color: AppTheme.lightText,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAchievementsSection() {
    final achievements = [
      {'icon': '🎯', 'title': 'Bước đầu tiên', 'description': 'Học 10 từ mới'},
      {
        'icon': '🚀',
        'title': 'Học tốc độ',
        'description': 'Hoàn thành 5 buổi học trong 1 ngày',
      },
      {'icon': '🏆', 'title': 'Tuần chiến binh', 'description': 'chuỗi 7 ngày'},
      {
        'icon': '⭐',
        'title': 'Người cầu toàn',
        'description': 'Độ chính xác 100% trên 5 bài viết',
      },
    ];

    return Column(
      children: achievements.map((achievement) {
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: AppTheme.cardDecoration,
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Text(
                achievement['icon'] as String,
                style: const TextStyle(fontSize: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      achievement['title'] as String,
                      style: AppTheme.labelSmall.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      achievement['description'] as String,
                      style: AppTheme.bodySmall.copyWith(
                        color: AppTheme.lightText,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.check_circle, color: AppTheme.primaryGreen, size: 24),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildProgressSection() {
    return Column(
      children: [
        _buildProgressItem(
          label: 'Vocabulary Progress',
          value: 48,
          max: 100,
          color: AppTheme.primaryGreen,
        ),
        const SizedBox(height: 16),
        _buildProgressItem(
          label: 'Writing Skills',
          value: 24,
          max: 100,
          color: Colors.blue,
        ),
        const SizedBox(height: 16),
        _buildProgressItem(
          label: 'Daily Activity',
          value: 12,
          max: 30,
          color: Colors.orange,
        ),
      ],
    );
  }

  Widget _buildProgressItem({
    required String label,
    required int value,
    required int max,
    required Color color,
  }) {
    final percentage = (value / max * 100).toStringAsFixed(0);

    return Container(
      decoration: AppTheme.cardDecoration,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: AppTheme.labelSmall.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                '$percentage%',
                style: AppTheme.labelSmall.copyWith(color: color),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: value / max,
              minHeight: 8,
              backgroundColor: AppTheme.borderColor,
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '$value / $max completed',
            style: AppTheme.bodySmall.copyWith(color: AppTheme.lightText),
          ),
        ],
      ),
    );
  }
}
