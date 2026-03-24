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
    // Gọi API nạp dữ liệu thật ngay khi mở màn hình
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
          // 1. Trạng thái đang tải dữ liệu
          if (provider.isLoading) {
            return Center(
              child: CircularProgressIndicator(color: AppTheme.primaryGreen),
            );
          }

          // 2. Trạng thái lỗi (nếu có)
          if (provider.error.isNotEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, color: Colors.red, size: 48),
                  const SizedBox(height: 16),
                  Text('Lỗi kết nối: ${provider.error}'),
                  TextButton(
                    onPressed: () => provider.loadDashboard(),
                    child: const Text('Thử lại'),
                  ),
                ],
              ),
            );
          }

          // 3. Giao diện chính khi đã có dữ liệu thật
          return SafeArea(
            child: CustomScrollView(
              slivers: [
                SliverAppBar(
                  floating: true,
                  pinned: false,
                  backgroundColor: AppTheme.backgroundColor,
                  elevation: 0,
                  title: Text(
                    'Tiến bộ & Thành tựu',
                    style: AppTheme.headlineSmall,
                  ),
                ),

                SliverPadding(
                  padding: const EdgeInsets.all(16),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      // Thẻ Chuỗi (Streak) - Dữ liệu thật từ StatsProvider
                      _buildStreakCard(provider),
                      const SizedBox(height: 24),

                      // Hàng chỉ số nhanh - Dữ liệu thật
                      _buildQuickStatsRow(provider),
                      const SizedBox(height: 24),

                      // Danh sách Thành tích - Logic thật dựa trên chỉ số
                      Text('Thành tích của bạn', style: AppTheme.headlineSmall),
                      const SizedBox(height: 12),
                      _buildAchievementsSection(provider),
                      const SizedBox(height: 24),

                      // Thanh tiến độ học tập - Dữ liệu thật
                      Text('Tiến độ mục tiêu', style: AppTheme.headlineSmall),
                      const SizedBox(height: 12),
                      _buildProgressSection(provider),
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

  // --- WIDGETS CHI TIẾT ---

  Widget _buildStreakCard(StatsProvider provider) {
    final current = provider.stats?.currentStreak ?? 0;
    final longest = provider.stats?.longestStreak ?? 0;

    return Container(
      decoration: AppTheme.elevatedCardDecoration,
      padding: const EdgeInsets.all(20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStreakItem(
            icon: Icons.local_fire_department,
            title: 'Chuỗi hiện tại',
            value: '$current',
            color: Colors.orange,
          ),
          Container(height: 40, width: 1, color: AppTheme.borderColor),
          _buildStreakItem(
            icon: Icons.trending_up,
            title: 'Chuỗi dài nhất',
            value: '$longest',
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
        Icon(icon, color: color, size: 30),
        const SizedBox(height: 4),
        Text(value, style: AppTheme.headlineSmall.copyWith(color: color)),
        Text(title, style: AppTheme.labelSmall),
      ],
    );
  }

  Widget _buildQuickStatsRow(StatsProvider provider) {
    final vocabCount = provider.stats?.totalVocabularyCount ?? 0;

    return Row(
      children: [
        Expanded(
          child: _buildStatBox(
            icon: Icons.menu_book,
            value: '$vocabCount',
            label: 'Từ vựng',
            color: Colors.blue,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatBox(
            icon: Icons.edit_note,
            value: '--', // Backend của bạn chưa có field đếm bài viết
            label: 'Bài viết',
            color: Colors.purple,
          ),
        ),
      ],
    );
  }

  Widget _buildStatBox({
    required IconData icon,
    required String value,
    required String label,
    required Color color,
  }) {
    return Container(
      decoration: AppTheme.cardDecoration,
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(value, style: AppTheme.headlineMedium),
          Text(label, style: AppTheme.labelSmall),
        ],
      ),
    );
  }

  // --- PHẦN THÀNH TÍCH THỰC TẾ ---
  Widget _buildAchievementsSection(StatsProvider provider) {
    final int vocab = provider.stats?.totalVocabularyCount ?? 0;
    final int streak = provider.stats?.longestStreak ?? 0;

    // Danh sách thành tích với điều kiện logic thật
    final achievements = [
      {
        'icon': '🎯',
        'title': 'Người khởi đầu',
        'desc': 'Học được 10 từ vựng đầu tiên',
        'isDone': vocab >= 10,
        'progress': '$vocab/10',
      },
      {
        'icon': '🔥',
        'title': 'Kỷ luật thép',
        'desc': 'Duy trì chuỗi học 7 ngày',
        'isDone': streak >= 7,
        'progress': '$streak/7',
      },
      {
        'icon': '🚀',
        'title': 'Bậc thầy từ vựng',
        'desc': 'Đạt mốc 50 từ vựng',
        'isDone': vocab >= 50,
        'progress': '$vocab/50',
      },
    ];

    return Column(
      children: achievements.map((item) {
        bool isDone = item['isDone'] as bool;
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: AppTheme.cardDecoration.copyWith(
            color: isDone ? Colors.white : Colors.grey.withOpacity(0.05),
          ),
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Text(
                item['icon'] as String,
                style: TextStyle(fontSize: 24, color: isDone ? null : Colors.grey),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item['title'] as String,
                      style: AppTheme.labelSmall.copyWith(
                        fontWeight: FontWeight.bold,
                        color: isDone ? AppTheme.darkText : Colors.grey,
                      ),
                    ),
                    Text(item['desc'] as String, style: AppTheme.bodySmall),
                  ],
                ),
              ),
              isDone
                  ? const Icon(Icons.check_circle, color: AppTheme.primaryGreen)
                  : Text(
                      item['progress'] as String,
                      style: const TextStyle(fontSize: 12, color: Colors.orange),
                    ),
            ],
          ),
        );
      }).toList(),
    );
  }

  // --- TIẾN ĐỘ MỤC TIÊU ---
  Widget _buildProgressSection(StatsProvider provider) {
    final vocab = provider.stats?.totalVocabularyCount ?? 0;
    const target = 100; // Mục tiêu mẫu: 100 từ
    final percent = (vocab / target).clamp(0.0, 1.0);

    return Container(
      decoration: AppTheme.cardDecoration,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Mục tiêu 100 từ vựng', style: TextStyle(fontWeight: FontWeight.bold)),
              Text('${(percent * 100).toStringAsFixed(0)}%'),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: percent,
              minHeight: 10,
              backgroundColor: AppTheme.borderColor,
              valueColor: const AlwaysStoppedAnimation(AppTheme.primaryGreen),
            ),
          ),
          const SizedBox(height: 8),
          Text('$vocab / $target từ đã học', style: AppTheme.bodySmall),
        ],
      ),
    );
  }
}