// lib/screens/account_delete_screen.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';
import '../theme/tokens.dart';
import '../widgets/screen_scaffold.dart';

class AccountDeleteScreen extends StatefulWidget {
  const AccountDeleteScreen({super.key});

  @override
  State<AccountDeleteScreen> createState() => _AccountDeleteScreenState();
}

class _AccountDeleteScreenState extends State<AccountDeleteScreen> {
  late final TextEditingController _emailController;
  final _passwordController = TextEditingController();

  bool _isLoading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    final currentEmail = FirebaseAuth.instance.currentUser?.email ?? '';
    _emailController = TextEditingController(text: currentEmail);
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  bool get _isValid {
    return _emailController.text.trim().isNotEmpty &&
        _passwordController.text.isNotEmpty;
  }

  Future<void> _deleteAccount() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        setState(() => _error = 'No authenticated user found.');
        return;
      }

      final credential = EmailAuthProvider.credential(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      await user.reauthenticateWithCredential(credential);
      await user.delete();

      if (!mounted) return;
      context.go('/auth/signin');
    } on FirebaseAuthException catch (e) {
      setState(() {
        if (e.code == 'wrong-password' || e.code == 'invalid-credential') {
          _error = 'Incorrect password. Please try again.';
        } else if (e.code == 'invalid-email') {
          _error = 'Email does not match your account.';
        } else {
          _error = e.message ?? 'Failed to delete account. Try again.';
        }
      });
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _showConfirmDialog() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete account?'),
        content: const Text(
          'This action is permanent and cannot be undone. All your data will be lost.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: AppColors.danger),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await _deleteAccount();
    }
  }

  @override
  Widget build(BuildContext context) {
    return ScreenScaffold(
      title: 'Delete Account',
      subtitle: null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Warning banner
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: AppColors.danger.withOpacity(0.08),
              borderRadius: BorderRadius.circular(AppRadii.card),
              border: Border.all(color: AppColors.danger.withOpacity(0.3)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.warning_amber_rounded,
                    color: AppColors.danger, size: 20),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    'This will permanently delete your account and all associated data. '
                    'This cannot be undone.',
                    style: const TextStyle(
                      color: AppColors.danger,
                      fontSize: 14,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.xxl),
          const Text(
            'To confirm, enter your account credentials:',
            style: AppTextStyles.bodyMuted,
          ),
          const SizedBox(height: AppSpacing.lg),
          TextField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(labelText: 'Email'),
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: AppSpacing.lg),
          TextField(
            controller: _passwordController,
            obscureText: true,
            decoration: const InputDecoration(labelText: 'Password'),
            onChanged: (_) => setState(() {}),
          ),
          if (_error != null) ...[
            const SizedBox(height: AppSpacing.md),
            Text(
              _error!,
              style: const TextStyle(color: AppColors.danger, fontSize: 14),
            ),
          ],
          const Spacer(),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.danger,
              foregroundColor: Colors.white,
            ),
            onPressed: _isValid && !_isLoading ? _showConfirmDialog : null,
            child: _isLoading
                ? const SizedBox(
                    height: 18,
                    width: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Text('Delete My Account'),
          ),
          const SizedBox(height: AppSpacing.sm),
          OutlinedButton(
            onPressed: _isLoading ? null : () => context.pop(),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }
}
