import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:magic_english/providers/app_providers.dart';
import 'package:magic_english/services/user_service.dart';
import 'package:magic_english/widgets/streak_card.dart';
import 'package:magic_english/widgets/stat_card.dart';
import 'package:magic_english/models/models.dart';
import 'package:fl_chart/fl_chart.dart';

/// Dashboard Screen
class DashboardScreen extends StatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() {
    final userId = UserService.getCurrentUserId();
    if (userId != null) {
      final dashboardProvider = context.read<DashboardProvider>();
      dashboardProvider.loadDashboard(userId);
      dashboardProvider.loadActivityTrend(userId);
    }
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async {
        _load();
      },
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Consumer<DashboardProvider>(
          builder: (context, dashboardProvider, _) {
            if (dashboardProvider.isLoading && dashboardProvider.dashboard == null) {
              return const SizedBox(
                height: 400,
                child: Center(child: CircularProgressIndicator()),
              );
            }

            final dashboard = dashboardProvider.dashboard;
            if (dashboard == null) {
              return const Center(child: Text('No data available'));
            }

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Streak Card
                StreakCard(streak: dashboard.streak),
                const SizedBox(height: 20),

                // Statistics Cards
                Row(
                  children: [
                    Expanded(
                      child: StatCard(
                        title: 'Vocabulary',
                        value: dashboard.totalVocabularyLearned.toString(),
                        icon: Icons.book,
                        color: Colors.blue,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: StatCard(
                        title: 'Today',
                        value: dashboard.todayActivityCount.toString(),
                        icon: Icons.check_circle,
                        color: Colors.green,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // CEFR Level Distribution Chart
                if (dashboard.vocabularyStats.cefrLevelDistribution.isNotEmpty)
                  _buildCEFRChart(dashboard),
                const SizedBox(height: 20),

                // Part of Speech Distribution Chart
                if (dashboard.vocabularyStats.partOfSpeechDistribution.isNotEmpty)
                  _buildPartOfSpeechChart(dashboard),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildCEFRChart(Dashboard dashboard) {
    final data = dashboard.vocabularyStats.cefrLevelDistribution;
    final colors = {
      'A1': Colors.green,
      'A2': Colors.lightGreen,
      'B1': Colors.yellow,
      'B2': Colors.orange,
      'C1': Colors.deepOrange,
      'C2': Colors.red,
    };

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'CEFR Level Distribution',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 250,
              child: PieChart(
                PieChartData(
                  sections: data.entries.map((entry) {
                    final total = data.values.reduce((a, b) => a + b);
                    final percentage = (entry.value / total * 100).toStringAsFixed(1);
                    return PieChartSectionData(
                      value: entry.value.toDouble(),
                      title: '${entry.key}\n$percentage%',
                      color: colors[entry.key] ?? Colors.grey,
                      radius: 50,
                    );
                  }).toList(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPartOfSpeechChart(Dashboard dashboard) {
    final data = dashboard.vocabularyStats.partOfSpeechDistribution;
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Part of Speech Distribution',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 250,
              child: BarChart(
                BarChartData(
                  barGroups: data.entries.toList().asMap().entries.map((entry) {
                    return BarChartGroupData(
                      x: entry.key,
                      barRods: [
                        BarChartRodData(
                          toY: entry.value.value.toDouble(),
                          color: Colors.blue,
                        ),
                      ],
                    );
                  }).toList(),
                  titlesData: FlTitlesData(
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          final keys = data.keys.toList();
                          if (value.toInt() < keys.length) {
                            return Text(keys[value.toInt()]);
                          }
                          return const Text('');
                        },
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
