import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'app/app_router.dart';
import 'theme/app_theme.dart';
import 'data/user_profile_provider.dart';
import 'data/business_settings_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const ClienteApp());
}

class ClienteApp extends StatelessWidget {
  const ClienteApp({super.key});

  @override
  Widget build(BuildContext context) {
    final router = AppRouter.build();
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UserProfileProvider()),
        ChangeNotifierProvider(create: (_) => BusinessSettingsProvider()),
      ],
      child: MaterialApp.router(
        title: 'Clientè',
        theme: AppTheme.build(),
        routerConfig: router,
      ),
    );
  }
}
