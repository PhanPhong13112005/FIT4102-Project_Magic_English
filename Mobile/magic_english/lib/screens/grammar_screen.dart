import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:magic_english/providers/app_providers.dart';
import 'package:magic_english/services/user_service.dart';

/// Grammar Checking Screen
class GrammarScreen extends StatefulWidget {
  const GrammarScreen({Key? key}) : super(key: key);

  @override
  State<GrammarScreen> createState() => _GrammarScreenState();
}

class _GrammarScreenState extends State<GrammarScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _textController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadGrammarHistory();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _textController.dispose();
    super.dispose();
  }

  void _loadGrammarHistory() {
    final userId = UserService.getCurrentUserId();
    if (userId != null) {
      context.read<GrammarProvider>().loadHistory(userId);
    }
  }

  void _handleCheckGrammar() async {
    if (!_formKey.currentState!.validate()) return;

    final userId = UserService.getCurrentUserId();
    if (userId == null) return;

    final grammarProvider = context.read<GrammarProvider>();
    final success = await grammarProvider.checkGrammar(userId, _textController.text.trim());

    if (!mounted) return;

    if (success) {
      _textController.clear();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Grammar checked! 📝')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(grammarProvider.error ?? 'Failed to check grammar')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          TabBar(
            controller: _tabController,
            tabs: const [
              Tab(text: 'Check Grammar'),
              Tab(text: 'History'),
            ],
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildCheckTab(),
                _buildHistoryTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCheckTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 16),
            Text(
              'Check Your English',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text('Enter text to check grammar, spelling, and style'),
            const SizedBox(height: 24),
            TextFormField(
              controller: _textController,
              maxLines: 8,
              decoration: InputDecoration(
                labelText: 'Enter text here',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                hintText: 'Example: She go to the store yesterday.',
              ),
              validator: (value) {
                if (value?.isEmpty ?? true) {
                  return 'Please enter some text';
                }
                if (value!.length < 10) {
                  return 'Text should be at least 10 characters';
                }
                return null;
              },
            ),
            const SizedBox(height: 24),
            Consumer<GrammarProvider>(
              builder: (context, grammarProvider, _) {
                return ElevatedButton.icon(
                  onPressed: grammarProvider.isLoading ? null : _handleCheckGrammar,
                  icon: grammarProvider.isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Icon(Icons.check_circle),
                  label: Text(grammarProvider.isLoading ? 'Checking...' : 'Check Grammar'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 32),
            Consumer<GrammarProvider>(
              builder: (context, grammarProvider, _) {
                if (grammarProvider.lastResult == null) {
                  return const SizedBox.shrink();
                }

                final result = grammarProvider.lastResult!;
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Score: ${result.score.toStringAsFixed(1)}/10',
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 12),
                            LinearProgressIndicator(
                              value: result.score / 10,
                              minHeight: 8,
                            ),
                            const SizedBox(height: 16),
                            if (result.errors.isNotEmpty) ...[
                              Text(
                                'Issues Found:',
                                style: Theme.of(context).textTheme.titleSmall,
                              ),
                              const SizedBox(height: 8),
                              ...result.errors.map((error) => Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Colors.red[50],
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border(
                                      left: BorderSide(
                                        color: Colors.red,
                                        width: 4,
                                      ),
                                    ),
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        error.type,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.red,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(error.description),
                                      const SizedBox(height: 4),
                                      Text(
                                        'Suggestion: ${error.suggestedFix}',
                                        style: const TextStyle(
                                          fontStyle: FontStyle.italic,
                                          color: Colors.green,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              )),
                            ] else
                              Text(
                                '✅ Perfect! No errors found.',
                                style: TextStyle(color: Colors.green[600]),
                              ),
                            if (result.suggestions.isNotEmpty) ...[
                              const SizedBox(height: 16),
                              Text(
                                'Suggestions:',
                                style: Theme.of(context).textTheme.titleSmall,
                              ),
                              const SizedBox(height: 8),
                              ...result.suggestions.map((suggestion) => Padding(
                                padding: const EdgeInsets.only(bottom: 8),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text('💡 '),
                                    Expanded(child: Text(suggestion)),
                                  ],
                                ),
                              )),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHistoryTab() {
    return RefreshIndicator(
      onRefresh: () async {
        _loadGrammarHistory();
      },
      child: Consumer<GrammarProvider>(
        builder: (context, grammarProvider, _) {
          if (grammarProvider.isLoading && grammarProvider.history.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (grammarProvider.history.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.history, size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  Text(
                    'No history yet',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  const Text('Check some text to see history!'),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(8),
            itemCount: grammarProvider.history.length,
            itemBuilder: (context, index) {
              final result = grammarProvider.history[index];
              return Card(
                margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              result.originalText,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ),
                          Chip(
                            label: Text('${result.score.toStringAsFixed(1)}/10'),
                            backgroundColor: _getScoreColor(result.score),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${result.errors.length} issues found',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Color _getScoreColor(double score) {
    if (score >= 9) return Colors.green;
    if (score >= 7) return Colors.lightGreen;
    if (score >= 5) return Colors.yellow;
    if (score >= 3) return Colors.orange;
    return Colors.red;
  }
}
