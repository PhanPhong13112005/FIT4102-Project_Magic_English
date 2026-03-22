import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:magic_english/providers/app_providers.dart';
import 'package:magic_english/services/user_service.dart';

/// Add Vocabulary Screen
class AddVocabularyScreen extends StatefulWidget {
  const AddVocabularyScreen({Key? key}) : super(key: key);

  @override
  State<AddVocabularyScreen> createState() => _AddVocabularyScreenState();
}

class _AddVocabularyScreenState extends State<AddVocabularyScreen> {
  final _wordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _wordController.dispose();
    super.dispose();
  }

  void _handleAddVocabulary() async {
    if (!_formKey.currentState!.validate()) return;

    final userId = UserService.getCurrentUserId();
    if (userId == null) return;

    final vocabProvider = context.read<VocabularyProvider>();
    final success = await vocabProvider.addVocabulary(userId, _wordController.text.trim());

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Word added successfully! 🎉')),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(vocabProvider.error ?? 'Failed to add word')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add New Word'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 24),
              Icon(
                Icons.lightbulb_outline,
                size: 64,
                color: Colors.blue[300],
              ),
              const SizedBox(height: 32),
              Text(
                'Enter an English word',
                style: Theme.of(context).textTheme.titleLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                'Our AI will automatically provide the pronunciation, meaning, example, and CEFR level',
                style: Theme.of(context).textTheme.bodySmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              TextFormField(
                controller: _wordController,
                decoration: InputDecoration(
                  labelText: 'English Word',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: const Icon(Icons.lightbulb),
                ),
                validator: (value) {
                  if (value?.isEmpty ?? true) {
                    return 'Please enter a word';
                  }
                  if (value!.length < 2) {
                    return 'Word must be at least 2 characters';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 32),
              Consumer<VocabularyProvider>(
                builder: (context, vocabProvider, _) {
                  return ElevatedButton.icon(
                    onPressed: vocabProvider.isLoading ? null : _handleAddVocabulary,
                    icon: vocabProvider.isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : const Icon(Icons.add),
                    label: Text(vocabProvider.isLoading ? 'Adding...' : 'Add Word'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
