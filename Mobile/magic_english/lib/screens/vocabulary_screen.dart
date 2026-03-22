import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:magic_english/providers/app_providers.dart';
import 'package:magic_english/services/user_service.dart';
import 'package:magic_english/screens/add_vocabulary_screen.dart';

/// Vocabulary Screen
class VocabularyScreen extends StatefulWidget {
  const VocabularyScreen({Key? key}) : super(key: key);

  @override
  State<VocabularyScreen> createState() => _VocabularyScreenState();
}

class _VocabularyScreenState extends State<VocabularyScreen> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _performSearch(String query, int userId) {
    if (query.isEmpty) {
      context.read<VocabularyProvider>().loadVocabularies(userId);
    } else {
      context.read<VocabularyProvider>().searchVocabularies(userId, query);
    }
  }

  @override
  Widget build(BuildContext context) {
    final userId = UserService.getCurrentUserId();

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () async {
          if (userId != null) {
            context.read<VocabularyProvider>().loadVocabularies(userId);
          }
        },
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search vocabulary...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            _searchController.clear();
                            if (userId != null) {
                              context.read<VocabularyProvider>().loadVocabularies(userId);
                            }
                          },
                        )
                      : null,
                ),
                onChanged: (value) {
                  if (userId != null) {
                    _performSearch(value, userId);
                  }
                },
              ),
            ),
            Expanded(
              child: Consumer<VocabularyProvider>(
                builder: (context, vocabProvider, _) {
                  if (vocabProvider.isLoading && vocabProvider.vocabularies.isEmpty) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (vocabProvider.vocabularies.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.book_outlined, size: 64, color: Colors.grey),
                          const SizedBox(height: 16),
                          Text(
                            'No vocabularies yet',
                            style: Theme.of(context).textTheme.headlineSmall,
                          ),
                          const SizedBox(height: 8),
                          const Text('Add your first word to get started!'),
                        ],
                      ),
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.all(8),
                    itemCount: vocabProvider.vocabularies.length,
                    itemBuilder: (context, index) {
                      final vocab = vocabProvider.vocabularies[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    vocab.word,
                                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Chip(
                                    label: Text(vocab.cefrLevel),
                                    backgroundColor: _getLevelColor(vocab.cefrLevel),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                vocab.ipa,
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  fontStyle: FontStyle.italic,
                                  color: Colors.grey[700],
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                vocab.meaning,
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                              const SizedBox(height: 12),
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.blue[50],
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Example: "${vocab.example}"',
                                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                        fontStyle: FontStyle.italic,
                                        color: Colors.black87,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 12),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Chip(
                                    label: Text('${vocab.partOfSpeech} • Reviewed ${vocab.reviewCount}x'),
                                    avatar: const Icon(Icons.info_outline, size: 18),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete, color: Colors.red),
                                    onPressed: () {
                                      showDialog(
                                        context: context,
                                        builder: (context) => AlertDialog(
                                          title: const Text('Delete'),
                                          content: const Text('Delete this vocabulary?'),
                                          actions: [
                                            TextButton(
                                              onPressed: () => Navigator.pop(context),
                                              child: const Text('Cancel'),
                                            ),
                                            TextButton(
                                              onPressed: () {
                                                vocabProvider.deleteVocabulary(vocab.id);
                                                Navigator.pop(context);
                                              },
                                              child: const Text('Delete'),
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const AddVocabularyScreen()),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Color _getLevelColor(String level) {
    switch (level) {
      case 'A1':
        return Colors.green;
      case 'A2':
        return Colors.lightGreen;
      case 'B1':
        return Colors.yellow;
      case 'B2':
        return Colors.orange;
      case 'C1':
        return Colors.deepOrange;
      case 'C2':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}
