import 'package:fit4102_project_magic_english/providers/vocabulary_provider.dart';
import 'package:fit4102_project_magic_english/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class MagicVocabScreen extends StatefulWidget {
  const MagicVocabScreen({Key? key}) : super(key: key);

  @override
  State<MagicVocabScreen> createState() => _MagicVocabScreenState();
}

class _MagicVocabScreenState extends State<MagicVocabScreen> {
  final TextEditingController _wordController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      context.read<VocabularyProvider>().loadVocabularies();
    });
  }

  @override
  void dispose() {
    _wordController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _addVocabulary(BuildContext context) async {
    final word = _wordController.text.trim();
    if (word.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please enter a word')));
      return;
    }

    final provider = context.read<VocabularyProvider>();
    await provider.addVocabulary(word);
    _wordController.clear();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Word added successfully!'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              floating: true,
              pinned: false,
              backgroundColor: AppTheme.backgroundColor,
              elevation: 0,
              expandedHeight: 0,
              title: Text('Magic Vocabulary', style: AppTheme.headlineSmall),
            ),

            SliverPadding(
              padding: const EdgeInsets.all(16),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  _buildAddWordCard(context),
                  const SizedBox(height: 24),
                  _buildSearchBar(),
                  const SizedBox(height: 24),
                  Text('Your Vocabulary', style: AppTheme.headlineSmall),
                  const SizedBox(height: 12),
                ]),
              ),
            ),

            Consumer<VocabularyProvider>(
              builder: (context, provider, _) {
                if (provider.isLoading) {
                  return SliverFillRemaining(
                    child: Center(
                      child: CircularProgressIndicator(
                        color: AppTheme.primaryGreen,
                      ),
                    ),
                  );
                }

                final vocabs = provider.vocabularies;
                if (vocabs.isEmpty) {
                  return SliverFillRemaining(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.library_books_outlined,
                            size: 64,
                            color: AppTheme.lightText,
                          ),
                          const SizedBox(height: 16),
                          Text('No words yet', style: AppTheme.bodyLarge),
                          Text(
                            'Start adding words to build your vocabulary!',
                            style: AppTheme.bodyMedium,
                          ),
                        ],
                      ),
                    ),
                  );
                }

                return SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) => _buildVocabularyCard(vocabs[index]),
                      childCount: vocabs.length,
                    ),
                  ),
                );
              },
            ),

            SliverPadding(padding: EdgeInsets.only(bottom: 16)),
          ],
        ),
      ),
    );
  }

  Widget _buildAddWordCard(BuildContext context) {
    return Container(
      decoration: AppTheme.elevatedCardDecoration,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Add New Word', style: AppTheme.headlineSmall),
          const SizedBox(height: 16),
          TextField(
            controller: _wordController,
            style: AppTheme.bodyLarge,
            decoration: AppTheme.inputDecoration(
              labelText: 'Enter a word',
              hintText: 'e.g., "serendipity"',
              prefixIcon: Icons.language,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton.icon(
              onPressed: () => _addVocabulary(context),
              icon: const Icon(Icons.add),
              label: const Text('Add Word'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryGreen,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return TextField(
      controller: _searchController,
      style: AppTheme.bodyLarge,
      decoration:
          AppTheme.inputDecoration(
            labelText: 'Search words',
            hintText: 'Search...',
            prefixIcon: Icons.search,
          ).copyWith(
            suffixIcon: _searchController.text.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      _searchController.clear();
                      setState(() {});
                    },
                  )
                : null,
          ),
      onChanged: (value) => setState(() {}),
    );
  }

  Widget _buildVocabularyCard(dynamic vocab) {
    final word = vocab.word ?? 'Unknown';
    final meaning = vocab.meaning ?? 'No definition';
    final ipa = vocab.ipa ?? '';
    final wordType = vocab.wordType ?? '';
    final cefrLevel = vocab.cefrLevel ?? 'A1';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: AppTheme.cardDecoration,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(word, style: AppTheme.headlineSmall),
                    if (ipa.isNotEmpty)
                      Text(
                        '/$ipa/',
                        style: AppTheme.labelSmall.copyWith(
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: AppTheme.primaryGreen.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  cefrLevel,
                  style: AppTheme.labelSmall.copyWith(
                    color: AppTheme.primaryGreen,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Definition',
            style: AppTheme.labelSmall.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 4),
          Text(meaning, style: AppTheme.bodyMedium),
          if (wordType.isNotEmpty) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                wordType,
                style: AppTheme.labelSmall.copyWith(color: Colors.blue),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
