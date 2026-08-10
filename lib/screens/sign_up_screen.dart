import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:go_router/go_router.dart';
import '../theme/tokens.dart';
import '../widgets/screen_scaffold.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  bool _acceptTerms = false;
  bool _isLoading = false;
  String? _error;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  bool get _isValid {
    final nameOk = _nameController.text.trim().length >= 2;
    final email = _emailController.text.trim();
    final emailOk = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email);
    final pass = _passwordController.text;
    final passOk = pass.length >= 8;
    final match = pass == _confirmController.text;
    return nameOk && emailOk && passOk && match && _acceptTerms;
  }

  Future<void> _createAccount() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final cred = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );
      final user = cred.user!;
      await user.updateDisplayName(_nameController.text.trim());
      // UID doubles as businessId for solo professionals.
      final db = FirebaseFirestore.instance;
      await db.collection('users').doc(user.uid).set({
        'uid': user.uid,
        'role': 'owner',
        'businessId': user.uid,
        'onboardingComplete': false,
        'createdAt': FieldValue.serverTimestamp(),
      });
      await db.collection('businessSettings').doc(user.uid).set({
        'businessId': user.uid,
        'onboardingComplete': false,
        'businessName': _nameController.text.trim(),
        'timezone': 'America/New_York',
        'workingDays': {
          'Mon': true,
          'Tue': true,
          'Wed': true,
          'Thu': true,
          'Fri': true,
          'Sat': false,
          'Sun': false,
        },
        'workingHours': {
          'Mon': {'open': '09:00', 'close': '17:00'},
          'Tue': {'open': '09:00', 'close': '17:00'},
          'Wed': {'open': '09:00', 'close': '17:00'},
          'Thu': {'open': '09:00', 'close': '17:00'},
          'Fri': {'open': '09:00', 'close': '17:00'},
          'Sat': {'open': '09:00', 'close': '17:00'},
          'Sun': {'open': '09:00', 'close': '17:00'},
        },
        'createdAt': FieldValue.serverTimestamp(),
      });
      if (!mounted) return;
      context.go('/onboarding/welcome');
    } on FirebaseAuthException catch (e) {
      setState(() {
        _error = e.message ?? 'Sign up failed. Try again.';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ScreenScaffold(
      title: 'Create account',
      subtitle: 'Start your Clientè setup.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: _nameController,
            decoration: const InputDecoration(labelText: 'Full name'),
            onChanged: (_) => setState(() {}),
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
          const SizedBox(height: AppSpacing.lg),
          TextField(
            controller: _confirmController,
            obscureText: true,
            decoration: const InputDecoration(labelText: 'Confirm password'),
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: AppSpacing.lg),
          CheckboxListTile(
            value: _acceptTerms,
            onChanged: _isLoading
                ? null
                : (val) => setState(() => _acceptTerms = val ?? false),
            title: const Text('I agree to Terms and Privacy'),
            controlAffinity: ListTileControlAffinity.leading,
            contentPadding: EdgeInsets.zero,
          ),
          if (_error != null) ...[
            const SizedBox(height: AppSpacing.md),
            Text(_error!, style: const TextStyle(color: AppColors.danger)),
          ],
          const Spacer(),
          ElevatedButton(
            onPressed: _isValid && !_isLoading ? _createAccount : null,
            child: _isLoading
                ? const SizedBox(
                    height: 18,
                    width: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Create account'),
          ),
          const SizedBox(height: AppSpacing.sm),
          OutlinedButton(
            onPressed: _isLoading ? null : () => context.go('/auth/signin'),
            child: const Text('Back to sign in'),
          ),
        ],
      ),
    );
  }
}
