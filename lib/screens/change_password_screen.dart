// lib/screens/change_password_screen.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';
import '../theme/tokens.dart';
import '../widgets/screen_scaffold.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _currentPwController = TextEditingController();
  final _newPwController = TextEditingController();
  final _confirmPwController = TextEditingController();

  bool _isLoading = false;
  String? _error;

  @override
  void dispose() {
    _currentPwController.dispose();
    _newPwController.dispose();
    _confirmPwController.dispose();
    super.dispose();
  }

  bool get _isValid {
    final currentOk = _currentPwController.text.isNotEmpty;
    final newPw = _newPwController.text;
    final newOk = newPw.length >= 8;
    final match = newPw == _confirmPwController.text;
    return currentOk && newOk && match;
  }

  Future<void> _submit() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null || user.email == null) {
        setState(() => _error = 'No authenticated user found.');
        return;
      }

      final credential = EmailAuthProvider.credential(
        email: user.email!,
        password: _currentPwController.text,
      );

      await user.reauthenticateWithCredential(credential);
      await user.updatePassword(_newPwController.text);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Password updated.')),
      );
      context.pop();
    } on FirebaseAuthException catch (e) {
      setState(() {
        if (e.code == 'wrong-password' || e.code == 'invalid-credential') {
          _error = 'Current password is incorrect.';
        } else {
          _error = e.message ?? 'Failed to update password. Try again.';
        }
      });
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ScreenScaffold(
      title: 'Change Password',
      subtitle: 'Enter your current password to continue.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: _currentPwController,
            obscureText: true,
            decoration: const InputDecoration(labelText: 'Current password'),
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: AppSpacing.lg),
          TextField(
            controller: _newPwController,
            obscureText: true,
            decoration: const InputDecoration(
              labelText: 'New password',
              helperText: 'Minimum 8 characters',
            ),
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: AppSpacing.lg),
          TextField(
            controller: _confirmPwController,
            obscureText: true,
            decoration: const InputDecoration(labelText: 'Confirm new password'),
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
            onPressed: _isValid && !_isLoading ? _submit : null,
            child: _isLoading
                ? const SizedBox(
                    height: 18,
                    width: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Update Password'),
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
