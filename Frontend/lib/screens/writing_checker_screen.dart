import 'package:fit4102_project_magic_english/providers/writing_provider.dart';
import 'package:fit4102_project_magic_english/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class WritingCheckerScreen extends StatefulWidget {
  const WritingCheckerScreen({Key? key}) : super(key: key);

  @override
  State<WritingCheckerScreen> createState() => _WritingCheckerScreenState();
}

class _WritingCheckerScreenState extends State<WritingCheckerScreen> {
  final TextEditingController _writingController = TextEditingController();
  Map<String, dynamic>? _checkResult;
  bool _isChecking = false;

  @override
  void dispose() {
    _writingController.dispose();
    super.dispose();
  }

  void _checkWriting() async {
    final text = _writingController.text.trim();
    if (text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter some text to check')),
      );
      return;
    }

    setState(() => _isChecking = true);

    try {
      final provider = context.read<WritingProvider>();
      await provider.checkWriting(text);
      // For demo, create a mock result
      setState(() {
        _checkResult = {
          'score': 85,
          'errors': [],
          'suggestions': ['Consider using more diverse vocabulary'],
          'feedback': 'Good writing! Keep practicing to improve further.',
        };
        _isChecking = false;
      });
    } catch (e) {
      setState(() => _isChecking = false);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
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
              title: Text('Writing Checker', style: AppTheme.headlineSmall),
            ),

            SliverPadding(
              padding: const EdgeInsets.all(16),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  _buildInputCard(),
                  const SizedBox(height: 24),
                ]),
              ),
            ),

            if (_isChecking)
              SliverFillRemaining(
                child: Center(
                  child: CircularProgressIndicator(
                    color: AppTheme.primaryGreen,
                  ),
                ),
              )
            else if (_checkResult != null)
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    _buildResultCard(),
                    const SizedBox(height: 24),
                  ]),
                ),
              ),

            if (_checkResult == null && !_isChecking)
              SliverFillRemaining(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.edit_outlined,
                        size: 64,
                        color: AppTheme.lightText,
                      ),
                      const SizedBox(height: 16),
                      Text('Write something', style: AppTheme.bodyLarge),
                      Text(
                        'Enter your text and click Check to improve your writing',
                        style: AppTheme.bodyMedium,
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputCard() {
    return Container(
      decoration: AppTheme.elevatedCardDecoration,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Your Writing', style: AppTheme.headlineSmall),
          const SizedBox(height: 16),

          // Character count
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Character count: ${_writingController.text.length}',
                style: AppTheme.labelSmall.copyWith(color: AppTheme.lightText),
              ),
              Text(
                'Word count: ${_writingController.text.split(' ').length}',
                style: AppTheme.labelSmall.copyWith(color: AppTheme.lightText),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Text input
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: AppTheme.borderColor),
              borderRadius: BorderRadius.circular(12),
            ),
            child: TextField(
              controller: _writingController,
              maxLines: 8,
              minLines: 6,
              style: AppTheme.bodyLarge,
              decoration: InputDecoration(
                hintText: 'Write something here... (minimum 10 characters)',
                hintStyle: AppTheme.bodyMedium.copyWith(
                  color: AppTheme.lightText,
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.all(12),
              ),
              onChanged: (_) => setState(() {}),
            ),
          ),
          const SizedBox(height: 16),

          // Check button
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton.icon(
              onPressed: _isChecking ? null : _checkWriting,
              icon: _isChecking
                  ? SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          AppTheme.backgroundColor,
                        ),
                      ),
                    )
                  : const Icon(Icons.check),
              label: Text(_isChecking ? 'Checking...' : 'Check Writing'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryGreen,
                disabledBackgroundColor: AppTheme.primaryGreen.withOpacity(0.5),
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

  Widget _buildResultCard() {
    return Container(
      decoration: AppTheme.cardDecoration,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Check Results', style: AppTheme.headlineSmall),
              GestureDetector(
                onTap: () => setState(() => _checkResult = null),
                child: Icon(Icons.close, color: AppTheme.darkText),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Overall score
          if (_checkResult!['score'] != null) ...[
            Container(
              decoration: BoxDecoration(
                color: AppTheme.primaryGreen.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppTheme.primaryGreen.withOpacity(0.3),
                ),
              ),
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Text(
                    'Overall Score',
                    style: AppTheme.labelSmall.copyWith(
                      color: AppTheme.lightText,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${_checkResult!['score']}/100',
                    style: AppTheme.headlineSmall.copyWith(
                      color: AppTheme.primaryGreen,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
          ],

          // Errors section
          if (_checkResult!['errors'] != null &&
              _checkResult!['errors'].isNotEmpty)
            _buildErrorsSection(_checkResult!['errors']),

          // Suggestions section
          if (_checkResult!['suggestions'] != null &&
              _checkResult!['suggestions'].isNotEmpty) ...[
            const SizedBox(height: 20),
            _buildSuggestionsSection(_checkResult!['suggestions']),
          ],

          // Feedback
          if (_checkResult!['feedback'] != null) ...[
            const SizedBox(height: 20),
            Container(
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.05),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blue.withOpacity(0.2)),
              ),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Feedback',
                    style: AppTheme.labelSmall.copyWith(
                      fontWeight: FontWeight.w600,
                      color: Colors.blue,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(_checkResult!['feedback'], style: AppTheme.bodyMedium),
                ],
              ),
            ),
          ],

          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 40,
            child: ElevatedButton(
              onPressed: () => setState(() => _checkResult = null),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryGreen,
              ),
              child: const Text('Try Again'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorsSection(List<dynamic> errors) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.error_outline, color: AppTheme.errorRed, size: 20),
            const SizedBox(width: 8),
            Text(
              'Errors Found (${errors.length})',
              style: AppTheme.labelSmall.copyWith(
                fontWeight: FontWeight.w600,
                color: AppTheme.errorRed,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ...errors.map((error) {
          return Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.errorRed.withOpacity(0.08),
              border: const Border(
                left: BorderSide(color: AppTheme.errorRed, width: 3),
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  error['type'] ?? 'Unknown Error',
                  style: AppTheme.labelSmall.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppTheme.errorRed,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  error['message'] ?? 'No details',
                  style: AppTheme.bodySmall,
                ),
                if (error['suggestion'] != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    'Suggestion: ${error['suggestion']}',
                    style: AppTheme.bodySmall.copyWith(
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ],
            ),
          );
        }).toList(),
      ],
    );
  }

  Widget _buildSuggestionsSection(List<dynamic> suggestions) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.lightbulb_outline, color: Colors.amber, size: 20),
            const SizedBox(width: 8),
            Text(
              'Suggestions (${suggestions.length})',
              style: AppTheme.labelSmall.copyWith(
                fontWeight: FontWeight.w600,
                color: Colors.amber[700],
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ...suggestions.map((suggestion) {
          return Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.amber.withOpacity(0.08),
              border: const Border(
                left: BorderSide(color: Colors.amber, width: 3),
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(suggestion, style: AppTheme.bodySmall),
          );
        }).toList(),
      ],
    );
  }
}
