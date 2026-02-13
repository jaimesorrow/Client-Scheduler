import 'package:flutter/material.dart';
import '../theme/tokens.dart';
import '../widgets/screen_scaffold.dart';

class SupportContactScreen extends StatefulWidget {
  const SupportContactScreen({super.key});

  @override
  State<SupportContactScreen> createState() => _SupportContactScreenState();
}

class _SupportContactScreenState extends State<SupportContactScreen> {
  final _subjectController = TextEditingController();
  final _messageController = TextEditingController();
  bool _isLoading = false;
  String? _error;

  @override
  void dispose() {
    _subjectController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  bool get _isValid =>
      _subjectController.text.trim().isNotEmpty &&
      _messageController.text.trim().isNotEmpty;

  void _submit() {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // TODO: Replace with mailto or in-app messaging integration.
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Support message queued.')));
    } catch (e) {
      setState(() {
        _error = 'Something went wrong. Try again.';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return ScreenScaffold(
      title: 'Contact support',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Support email: support@cliente.app',
            style: AppTextStyles.bodyMuted,
          ),
          const SizedBox(height: AppSpacing.xl),
          TextField(
            controller: _subjectController,
            decoration: const InputDecoration(labelText: 'Subject'),
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: AppSpacing.lg),
          TextField(
            controller: _messageController,
            maxLines: 5,
            decoration: const InputDecoration(labelText: 'Message'),
            onChanged: (_) => setState(() {}),
          ),
          if (_error != null) ...[
            const SizedBox(height: AppSpacing.lg),
            Text(_error!, style: const TextStyle(color: AppColors.danger)),
          ],
          const SizedBox(height: AppSpacing.xl),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: _isValid && !_isLoading ? _submit : null,
                  child: _isLoading
                      ? const SizedBox(
                          height: 18,
                          width: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Send'),
                ),
              ),
              const SizedBox(width: AppSpacing.lg),
              Expanded(
                child: OutlinedButton(
                  onPressed: _isLoading
                      ? null
                      : () => Navigator.of(context).pop(),
                  child: const Text('Cancel'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
