import 'package:fit4102_project_magic_english/providers/auth_provider.dart';
import 'package:fit4102_project_magic_english/providers/stats_provider.dart';
import 'package:fit4102_project_magic_english/screens/magic_vocab_screen.dart';
import 'package:fit4102_project_magic_english/screens/stats_screen.dart';
import 'package:fit4102_project_magic_english/screens/writing_checker_screen.dart';
import 'package:fit4102_project_magic_english/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome Card
            _buildWelcomeCard(context),
            const SizedBox(height: 24),

            // Quick Stats
            _buildQuickStats(context),
            const SizedBox(height: 24),

            // Feature Cards
            _buildFeatureCards(context),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildWelcomeCard(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, _) {
        return Container(
          decoration: AppTheme.elevatedCardDecoration,
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      color: AppTheme.primaryGreen,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(
                      Icons.person,
                      color: Colors.white,
                      size: 32,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Chào Mừng Trở Lại!', style: AppTheme.bodyMedium),
                        const SizedBox(height: 4),
                        Text(
                          authProvider.currentUser?.fullName ?? 'User',
                          style: AppTheme.headlineSmall,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                'Hãy tiếp tục học hỏi mỗi ngày để cải thiện tiếng Anh của bạn!',
                style: AppTheme.bodyMedium,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildQuickStats(BuildContext context) {
    return Consumer<StatsProvider>(
      builder: (context, statsProvider, _) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Hành Trình Của Bạn', style: AppTheme.headlineSmall),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    icon: Icons.library_books,
                    label: 'Từ đã học',
                    value:
                        statsProvider.stats?.totalVocabularyCount.toString() ??
                        '0',
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    icon: Icons.local_fire_department,
                    label: 'Chuỗi hiện tại',
                    value: statsProvider.stats?.currentStreak.toString() ?? '0',
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    icon: Icons.star,
                    label: 'Chuỗi dài nhất',
                    value: statsProvider.stats?.longestStreak.toString() ?? '0',
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Container(
      decoration: AppTheme.cardDecoration,
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppTheme.primaryGreen.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: AppTheme.primaryGreen, size: 24),
          ),
          const SizedBox(height: 12),
          Text(value, style: AppTheme.headlineSmall),
          const SizedBox(height: 4),
          Text(label, style: AppTheme.labelSmall, textAlign: TextAlign.center),
        ],
      ),
    );
  }

  Widget _buildFeatureCards(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Tính Năng', style: AppTheme.headlineSmall),
        const SizedBox(height: 16),
        _buildFeatureCard(
          icon: Icons.library_books,
          title: 'Từ vựng ma thuật',
          description:
              'Học từ mới với định nghĩa và ví dụ được hỗ trợ bởi trí tuệ nhân tạo.',
          color: Colors.blue,
          onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (_) => const MagicVocabScreen()));
          },
        ),
        const SizedBox(height: 12),
        _buildFeatureCard(
          icon: Icons.edit_document,
          title: 'Viết kiểm tra',
          description: 'Nhận phản hồi tức thì về bài viết tiếng Anh của bạn',
          color: Colors.orange,
          onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (_) => const WritingCheckerScreen()));
          },
        ),
        const SizedBox(height: 12),
        _buildFeatureCard(
          icon: Icons.bar_chart,
          title: 'Thống kê',
          description: 'Theo dõi tiến độ học tập và thành tựu của bạn',
          color: Colors.green,
          onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (_) => const StatsScreen()));
          },
        ),
      ],
    );
  }

  Widget _buildFeatureCard({
    required IconData icon,
    required String title,
    required String description,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: AppTheme.cardDecoration,
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 32),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: AppTheme.bodyLarge),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: AppTheme.bodyMedium,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: AppTheme.lightText,
            ),
          ],
        ),
      ),
    );
  }
}
