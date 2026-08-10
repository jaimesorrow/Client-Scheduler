// lib/screens/settings_delete_account_screen.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../theme/tokens.dart';
import '../widgets/screen_scaffold.dart';

class SettingsDeleteAccountScreen extends StatefulWidget {
  const SettingsDeleteAccountScreen({super.key});

  @override
  State<SettingsDeleteAccountScreen> createState() =>
      _SettingsDeleteAccountScreenState();
}

class _SettingsDeleteAccountScreenState
    extends State<SettingsDeleteAccountScreen> {
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isLoading = false;
  String? _error;

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _deleteAccount() async {
    final password = _passwordController.text.trim();
    if (password.isEmpty) {
      setState(() => _error = 'Please enter your password to confirm.');
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception('Not signed in');

      final email = user.email;
      if (email == null) throw Exception('No email on account');

      final credential = EmailAuthProvider.credential(
        email: email,
        password: password,
      );
      await user.reauthenticateWithCredential(credential);
      await user.delete();

      if (!mounted) return;
      context.go('/auth/signin');
    } on FirebaseAuthException catch (e) {
      String message;
      switch (e.code) {
        case 'wrong-password':
        case 'invalid-credential':
          message = 'Incorrect password. Please try again.';
          break;
        case 'too-many-requests':
          message = 'Too many attempts. Please try again later.';
          break;
        case 'requires-recent-login':
          message = 'Please sign out and sign back in, then try again.';
          break;
        default:
          message = 'Unable to delete account. Please try again.';
      }
      setState(() => _error = message);
    } catch (e) {
      setState(() => _error = 'Unable to delete account. Please try again.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ScreenScaffold(
      title: 'Delete Account',
      subtitle: 'This action is permanent and cannot be undone.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    decoration: BoxDecoration(
                      color: AppColors.danger.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(AppRadii.card),
                      border: Border.all(
                          color: AppColors.danger.withOpacity(0.3)),
                    ),
                    child: const Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.warning_amber_rounded,
                          color: AppColors.danger,
                          size: 20,
                        ),
                        SizedBox(width: AppSpacing.sm),
                        Expanded(
                          child: Text(
                            'Deleting your account will permanently remove all your data, '
                            'including clients, appointments, and business settings. '
                            'This cannot be undone.',
                            style: TextStyle(
                              fontSize: 14,
                              color: AppColors.danger,
                              height: 1.4,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  const Text(
                    'Enter your password to confirm',
                    style: AppTextStyles.body,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  TextField(
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    enabled: !_isLoading,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                        ),
                        onPressed: () => setState(
                            () => _obscurePassword = !_obscurePassword),
                      ),
                    ),
                    onChanged: (_) {
                      if (_error != null) setState(() => _error = null);
                    },
                  ),
                  if (_error != null) ...[
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      _error!,
                      style: const TextStyle(color: AppColors.danger),
                    ),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.danger,
              foregroundColor: AppColors.surface,
            ),
            onPressed: _isLoading ? null : _deleteAccount,
            child: _isLoading
                ? const SizedBox(
                    height: 18,
                    width: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColors.surface,
                    ),
                  )
                : const Text('Delete my account'),
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
