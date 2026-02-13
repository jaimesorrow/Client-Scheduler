import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';
import '../theme/tokens.dart';

class SplashBootScreen extends StatefulWidget {
  const SplashBootScreen({super.key});

  @override
  State<SplashBootScreen> createState() => _SplashBootScreenState();
}

class _SplashBootScreenState extends State<SplashBootScreen> {
  @override
  void initState() {
    super.initState();
    _route();
  }

  Future<void> _route() async {
    await Future.delayed(const Duration(milliseconds: 600));
    final user = FirebaseAuth.instance.currentUser;
    if (!mounted) return;
    if (user == null) {
      context.go('/auth/signin');
    } else {
      context.go('/dashboard');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Text('Clientè', style: AppTextStyles.h1),
              SizedBox(height: AppSpacing.md),
              Text('Preparing your workspace…', style: AppTextStyles.bodyMuted),
              SizedBox(height: AppSpacing.xl),
              CircularProgressIndicator(),
            ],
          ),
        ),
      ),
    );
  }
}
