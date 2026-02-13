import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../data/business_settings_provider.dart';
import '../data/user_profile_provider.dart';
import '../screens/account_delete_screen.dart';
import '../screens/account_profile_screen.dart';
import '../screens/activity_feed_screen.dart';
import '../screens/analytics_detail_screen.dart';
import '../screens/analytics_overview_screen.dart';
import '../screens/appt_cancel_screen.dart';
import '../screens/appt_complete_screen.dart';
import '../screens/appt_detail_screen.dart';
import '../screens/appt_new_client_screen.dart';
import '../screens/appt_new_review_screen.dart';
import '../screens/appt_new_service_screen.dart';
import '../screens/appt_new_time_screen.dart';
import '../screens/appt_no_show_screen.dart';
import '../screens/appt_reschedule_screen.dart';
import '../screens/appts_list_screen.dart';
import '../screens/auth_forgot_screen.dart';
import '../screens/auth_signin_screen.dart';
import '../screens/auth_signup_screen.dart';
import '../screens/availability_blackouts_screen.dart';
import '../screens/availability_hours_screen.dart';
import '../screens/availability_overview_screen.dart';
import '../screens/availability_week_screen.dart';
import '../screens/change_password_screen.dart';
import '../screens/client_archive_screen.dart';
import '../screens/client_detail_screen.dart';
import '../screens/client_edit_screen.dart';
import '../screens/client_new_screen.dart';
import '../screens/clients_list_screen.dart';
import '../screens/dashboard_home_screen.dart';
import '../screens/forgot_password_screen.dart';
import '../screens/global_search_screen.dart';
import '../screens/legal_data_safety_screen.dart';
import '../screens/legal_privacy_screen.dart';
import '../screens/legal_terms_screen.dart';
import '../screens/logout_screen.dart';
import '../screens/onboarding_availability_screen.dart';
import '../screens/onboarding_brand_screen.dart';
import '../screens/onboarding_business_screen.dart';
import '../screens/onboarding_complete_screen.dart';
import '../screens/onboarding_hours_screen.dart';
import '../screens/onboarding_welcome_screen.dart';
import '../screens/service_archive_screen.dart';
import '../screens/service_detail_screen.dart';
import '../screens/service_edit_screen.dart';
import '../screens/service_new_screen.dart';
import '../screens/services_list_screen.dart';
import '../screens/settings_business_profile_screen.dart';
import '../screens/settings_delete_account_screen.dart';
import '../screens/settings_home_screen.dart';
import '../screens/settings_integrations_screen.dart';
import '../screens/settings_logout_screen.dart';
import '../screens/settings_notifications_screen.dart';
import '../screens/settings_policies_screen.dart';
import '../screens/settings_roles_screen.dart';
import '../screens/settings_team_screen.dart';
import '../screens/sign_in_screen.dart';
import '../screens/sign_up_screen.dart';
import '../screens/splash_boot_screen.dart';
import '../screens/support_contact_screen.dart';
import '../screens/support_help_screen.dart';
import '../screens/system_hub_screen.dart';
import '../screens/template_detail_screen.dart';
import '../screens/template_edit_screen.dart';
import '../screens/template_use_screen.dart';
import '../screens/templates_list_screen.dart';
import '../screens/timeoff_create_screen.dart';
import '../screens/timeoff_list_screen.dart';
import '../screens/verify_email_screen.dart';
import '../screens/welcome_screen.dart';

class AppRouter {
  static final GoRouter _router = GoRouter(
    initialLocation: '/splash',
    refreshListenable: GoRouterRefreshStream(
      FirebaseAuth.instance.authStateChanges(),
    ),
    redirect: (context, state) {
      final user = FirebaseAuth.instance.currentUser;
      final path = state.matchedLocation;
      final ownerOnly =
          path.startsWith('/availability') ||
          path.startsWith('/analytics') ||
          path.startsWith('/settings');
      final profileProvider = context.read<UserProfileProvider>();
      final settingsProvider = context.read<BusinessSettingsProvider>();
      final profile = profileProvider.profile;
      final settings = settingsProvider.settings;
      final isOwner = profile?.role == 'owner';
      final loggingIn =
          path == '/login' ||
          path == '/signup' ||
          path == '/welcome' ||
          path == '/reset' ||
          path == '/verify' ||
          path == '/auth/signin' ||
          path == '/auth/signup' ||
          path == '/auth/forgot';

      if (user == null) {
        return loggingIn || path == '/splash' ? null : '/auth/signin';
      }

      if (profile == null && !profileProvider.isLoading) {
        profileProvider.load(user.uid);
        return '/splash';
      }
      if (profile != null &&
          profile.businessId.isNotEmpty &&
          settings == null &&
          !settingsProvider.isLoading) {
        settingsProvider.load(profile.businessId);
        return '/splash';
      }

      if (loggingIn) {
        return '/dashboard';
      }

      if (ownerOnly && !isOwner) {
        return '/system?mode=permission&from=$path';
      }

      if (settings != null &&
          settings.onboardingComplete == false &&
          path != '/onboarding/welcome' &&
          !path.startsWith('/onboarding/')) {
        return '/onboarding/welcome';
      }

      return null;
    },
    routes: [
      _defaultRoute('/', const SplashBootScreen()),
      _defaultRoute('/splash', const SplashBootScreen()),
      _defaultRoute('/welcome', const WelcomeScreen()),
      _defaultRoute('/login', const SignInScreen()),
      _defaultRoute('/signup', const SignUpScreen()),
      _defaultRoute('/reset', const ForgotPasswordScreen()),
      _defaultRoute('/verify', const VerifyEmailScreen()),
      _defaultRoute('/auth/signin', const AuthSigninScreen()),
      _defaultRoute('/auth/signup', const AuthSignupScreen()),
      _defaultRoute('/auth/forgot', const AuthForgotScreen()),
      _defaultRoute('/onboarding/welcome', const OnboardingWelcomeScreen()),
      _defaultRoute('/onboarding/business', const OnboardingBusinessScreen()),
      _defaultRoute('/onboarding/brand', const OnboardingBrandScreen()),
      _defaultRoute('/onboarding/hours', const OnboardingHoursScreen()),
      _defaultRoute(
        '/onboarding/availability',
        const OnboardingAvailabilityScreen(),
      ),
      _defaultRoute('/onboarding/finish', const OnboardingCompleteScreen()),
      _fastRoute('/dashboard', const DashboardHomeScreen()),
      _defaultRoute('/search', const GlobalSearchScreen()),
      _defaultRoute('/activity', const ActivityFeedScreen()),
      _fastRoute('/clients', const ClientsListScreen()),
      _fastRoute('/clients/new', const ClientNewScreen()),
      _fastRoute('/clients/:id', const ClientDetailScreen()),
      _fastRoute('/clients/:id/edit', const ClientEditScreen()),
      _fastRoute('/clients/:id/archive', const ClientArchiveScreen()),
      _fastRoute('/appointments', const ApptsListScreen()),
      _fastRoute('/appointments/new/client', const ApptNewClientScreen()),
      _fastRoute('/appointments/new/service', const ApptNewServiceScreen()),
      _fastRoute('/appointments/new/time', const ApptNewTimeScreen()),
      _fastRoute('/appointments/new/review', const ApptNewReviewScreen()),
      _fastRoute('/appointments/:id', const ApptDetailScreen()),
      _fastRoute('/appointments/:id/reschedule', const ApptRescheduleScreen()),
      _fastRoute('/appointments/:id/cancel', const ApptCancelScreen()),
      _fastRoute('/appointments/:id/no-show', const ApptNoShowScreen()),
      _fastRoute('/appointments/:id/complete', const ApptCompleteScreen()),
      _fastRoute(
        '/appointments/new/step-1-client',
        const ApptNewClientScreen(),
      ),
      _fastRoute(
        '/appointments/new/step-2-service',
        const ApptNewServiceScreen(),
      ),
      _fastRoute(
        '/appointments/new/step-3-datetime',
        const ApptNewTimeScreen(),
      ),
      _fastRoute(
        '/appointments/new/step-4-confirm',
        const ApptNewReviewScreen(),
      ),
      _fastRoute('/services', const ServicesListScreen()),
      _fastRoute('/services/new', const ServiceNewScreen()),
      _fastRoute('/services/:id', const ServiceDetailScreen()),
      _fastRoute('/services/:id/edit', const ServiceEditScreen()),
      _fastRoute('/services/:id/archive', const ServiceArchiveScreen()),
      _defaultRoute('/templates', const TemplatesListScreen()),
      _defaultRoute('/templates/new', const TemplateEditScreen()),
      _defaultRoute('/templates/:id', const TemplateDetailScreen()),
      _defaultRoute('/templates/:id/edit', const TemplateEditScreen()),
      _defaultRoute('/templates/:id/use', const TemplateUseScreen()),
      _defaultRoute('/availability', const AvailabilityOverviewScreen()),
      _defaultRoute('/availability/hours', const AvailabilityHoursScreen()),
      _defaultRoute(
        '/availability/blackouts',
        const AvailabilityBlackoutsScreen(),
      ),
      _defaultRoute('/availability/week', const AvailabilityWeekScreen()),
      _defaultRoute('/availability/time-off', const TimeoffListScreen()),
      _defaultRoute('/availability/time-off/new', const TimeoffCreateScreen()),
      _defaultRoute('/analytics', const AnalyticsOverviewScreen()),
      _defaultRoute('/analytics/detail', const AnalyticsDetailScreen()),
      _defaultRoute('/system', const SystemHubScreen()),
      _defaultRoute('/settings', const SettingsHomeScreen()),
      _defaultRoute(
        '/settings/business-profile',
        const SettingsBusinessProfileScreen(),
      ),
      _defaultRoute('/settings/team', const SettingsTeamScreen()),
      _defaultRoute('/settings/roles', const SettingsRolesScreen()),
      _defaultRoute(
        '/settings/notifications',
        const SettingsNotificationsScreen(),
      ),
      _defaultRoute('/settings/policies', const SettingsPoliciesScreen()),
      _defaultRoute(
        '/settings/integrations',
        const SettingsIntegrationsScreen(),
      ),
      _defaultRoute('/settings/logout', const SettingsLogoutScreen()),
      _defaultRoute(
        '/settings/delete-account',
        const SettingsDeleteAccountScreen(),
      ),
      _defaultRoute('/account/profile', const AccountProfileScreen()),
      _defaultRoute('/account/change-password', const ChangePasswordScreen()),
      _defaultRoute('/account/delete', const AccountDeleteScreen()),
      _defaultRoute('/delete', const AccountDeleteScreen()),
      _defaultRoute('/legal/terms', const LegalTermsScreen()),
      _defaultRoute('/legal/privacy', const LegalPrivacyScreen()),
      _defaultRoute('/legal/data-safety', const LegalDataSafetyScreen()),
      _defaultRoute('/support/help', const SupportHelpScreen()),
      _defaultRoute('/support/contact', const SupportContactScreen()),
      _defaultRoute('/logout', const LogoutScreen()),
    ],
  );

  static GoRouter build() => _router;

  static GoRoute _defaultRoute(String path, Widget child) {
    return GoRoute(path: path, builder: (context, state) => child);
  }

  static GoRoute _fastRoute(String path, Widget child) {
    return GoRoute(
      path: path,
      pageBuilder: (context, state) =>
          NoTransitionPage<void>(key: state.pageKey, child: child),
    );
  }
}

class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    _subscription = stream.asBroadcastStream().listen((_) => notifyListeners());
  }

  late final StreamSubscription<dynamic> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
