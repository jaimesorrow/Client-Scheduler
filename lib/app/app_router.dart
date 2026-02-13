import 'dart:async';
import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import '../data/user_profile_provider.dart';
import '../data/business_settings_provider.dart';

import '../screens/splash_boot_screen.dart';
import '../screens/welcome_screen.dart';
import '../screens/sign_in_screen.dart';
import '../screens/sign_up_screen.dart';
import '../screens/forgot_password_screen.dart';
import '../screens/verify_email_screen.dart';
import '../screens/auth_signin_screen.dart';
import '../screens/auth_signup_screen.dart';
import '../screens/auth_forgot_screen.dart';
import '../screens/onboarding_welcome_screen.dart';
import '../screens/onboarding_business_screen.dart';
import '../screens/onboarding_brand_screen.dart';
import '../screens/onboarding_hours_screen.dart';
import '../screens/onboarding_availability_screen.dart';
import '../screens/onboarding_complete_screen.dart';
import '../screens/dashboard_home_screen.dart';
import '../screens/global_search_screen.dart';
import '../screens/activity_feed_screen.dart';
import '../screens/clients_list_screen.dart';
import '../screens/client_new_screen.dart';
import '../screens/client_detail_screen.dart';
import '../screens/client_edit_screen.dart';
import '../screens/client_archive_screen.dart';
import '../screens/appts_list_screen.dart';
import '../screens/appt_detail_screen.dart';
import '../screens/appt_reschedule_screen.dart';
import '../screens/appt_cancel_screen.dart';
import '../screens/appt_no_show_screen.dart';
import '../screens/appt_complete_screen.dart';
import '../screens/appt_new_client_screen.dart';
import '../screens/appt_new_service_screen.dart';
import '../screens/appt_new_time_screen.dart';
import '../screens/appt_new_review_screen.dart';
import '../screens/services_list_screen.dart';
import '../screens/service_new_screen.dart';
import '../screens/service_detail_screen.dart';
import '../screens/service_edit_screen.dart';
import '../screens/service_archive_screen.dart';
import '../screens/templates_list_screen.dart';
import '../screens/template_detail_screen.dart';
import '../screens/template_edit_screen.dart';
import '../screens/template_use_screen.dart';
import '../screens/availability_overview_screen.dart';
import '../screens/availability_hours_screen.dart';
import '../screens/availability_blackouts_screen.dart';
import '../screens/availability_week_screen.dart';
import '../screens/timeoff_list_screen.dart';
import '../screens/timeoff_create_screen.dart';
import '../screens/analytics_overview_screen.dart';
import '../screens/analytics_detail_screen.dart';
import '../screens/system_hub_screen.dart';
import '../screens/settings_home_screen.dart';
import '../screens/settings_business_profile_screen.dart';
import '../screens/settings_team_screen.dart';
import '../screens/settings_roles_screen.dart';
import '../screens/settings_notifications_screen.dart';
import '../screens/settings_policies_screen.dart';
import '../screens/settings_integrations_screen.dart';
import '../screens/settings_logout_screen.dart';
import '../screens/settings_delete_account_screen.dart';
import '../screens/account_profile_screen.dart';
import '../screens/change_password_screen.dart';
import '../screens/account_delete_screen.dart';
import '../screens/legal_terms_screen.dart';
import '../screens/legal_privacy_screen.dart';
import '../screens/legal_data_safety_screen.dart';
import '../screens/support_help_screen.dart';
import '../screens/support_contact_screen.dart';
import '../screens/logout_screen.dart';


class AppRouter {
  static GoRouter build() {
    return GoRouter(
      initialLocation: '/splash',
      refreshListenable: GoRouterRefreshStream(FirebaseAuth.instance.authStateChanges()),
      redirect: (context, state) {
        final user = FirebaseAuth.instance.currentUser;
        final path = state.matchedLocation;
        final ownerOnly = path.startsWith('/availability') ||
            path.startsWith('/analytics') ||
            path.startsWith('/settings');
        final profileProvider = context.read<UserProfileProvider>();
        final settingsProvider = context.read<BusinessSettingsProvider>();
        final profile = profileProvider.profile;
        final settings = settingsProvider.settings;
        final isOwner = profile?.role == 'owner';
        final loggingIn = path == '/login' ||
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
        if (profile != null && profile.businessId.isNotEmpty && settings == null && !settingsProvider.isLoading) {
          settingsProvider.load(profile.businessId);
          return '/splash';
        }

        if (loggingIn) {
          return '/dashboard';
        }

        if (ownerOnly && !isOwner) {
          return '/system?mode=permission&from=$path';
        }

        if (settings != null && settings.onboardingComplete == false && path != '/onboarding/welcome' && !path.startsWith('/onboarding/')) {
          return '/onboarding/welcome';
        }

        return null;
      },
      routes: [
        GoRoute(path: '/', builder: (context, state) => const SplashBootScreen()),
        GoRoute(path: '/splash', builder: (context, state) => const SplashBootScreen()),
        GoRoute(path: '/welcome', builder: (context, state) => const WelcomeScreen()),
        GoRoute(path: '/login', builder: (context, state) => const SignInScreen()),
        GoRoute(path: '/signup', builder: (context, state) => const SignUpScreen()),
        GoRoute(path: '/reset', builder: (context, state) => const ForgotPasswordScreen()),
        GoRoute(path: '/verify', builder: (context, state) => const VerifyEmailScreen()),
        GoRoute(path: '/auth/signin', builder: (context, state) => const AuthSigninScreen()),
        GoRoute(path: '/auth/signup', builder: (context, state) => const AuthSignupScreen()),
        GoRoute(path: '/auth/forgot', builder: (context, state) => const AuthForgotScreen()),
        GoRoute(path: '/onboarding/welcome', builder: (context, state) => const OnboardingWelcomeScreen()),
        GoRoute(path: '/onboarding/business', builder: (context, state) => const OnboardingBusinessScreen()),
        GoRoute(path: '/onboarding/brand', builder: (context, state) => const OnboardingBrandScreen()),
        GoRoute(path: '/onboarding/hours', builder: (context, state) => const OnboardingHoursScreen()),
        GoRoute(path: '/onboarding/availability', builder: (context, state) => const OnboardingAvailabilityScreen()),
        GoRoute(path: '/onboarding/finish', builder: (context, state) => const OnboardingCompleteScreen()),
        GoRoute(path: '/dashboard', builder: (context, state) => const DashboardHomeScreen()),
        GoRoute(path: '/search', builder: (context, state) => const GlobalSearchScreen()),
        GoRoute(path: '/activity', builder: (context, state) => const ActivityFeedScreen()),
        GoRoute(path: '/clients', builder: (context, state) => const ClientsListScreen()),
        GoRoute(path: '/clients/new', builder: (context, state) => const ClientNewScreen()),
        GoRoute(path: '/clients/:id', builder: (context, state) => const ClientDetailScreen()),
        GoRoute(path: '/clients/:id/edit', builder: (context, state) => const ClientEditScreen()),
        GoRoute(path: '/clients/:id/archive', builder: (context, state) => const ClientArchiveScreen()),
        GoRoute(path: '/appointments', builder: (context, state) => const ApptsListScreen()),
        GoRoute(path: '/appointments/new/client', builder: (context, state) => const ApptNewClientScreen()),
        GoRoute(path: '/appointments/new/service', builder: (context, state) => const ApptNewServiceScreen()),
        GoRoute(path: '/appointments/new/time', builder: (context, state) => const ApptNewTimeScreen()),
        GoRoute(path: '/appointments/new/review', builder: (context, state) => const ApptNewReviewScreen()),
        GoRoute(path: '/appointments/:id', builder: (context, state) => const ApptDetailScreen()),
        GoRoute(path: '/appointments/:id/reschedule', builder: (context, state) => const ApptRescheduleScreen()),
        GoRoute(path: '/appointments/:id/cancel', builder: (context, state) => const ApptCancelScreen()),
        GoRoute(path: '/appointments/:id/no-show', builder: (context, state) => const ApptNoShowScreen()),
        GoRoute(path: '/appointments/:id/complete', builder: (context, state) => const ApptCompleteScreen()),
        GoRoute(path: '/appointments/new/step-1-client', builder: (context, state) => const ApptNewClientScreen()),
        GoRoute(path: '/appointments/new/step-2-service', builder: (context, state) => const ApptNewServiceScreen()),
        GoRoute(path: '/appointments/new/step-3-datetime', builder: (context, state) => const ApptNewTimeScreen()),
        GoRoute(path: '/appointments/new/step-4-confirm', builder: (context, state) => const ApptNewReviewScreen()),
        GoRoute(path: '/services', builder: (context, state) => const ServicesListScreen()),
        GoRoute(path: '/services/new', builder: (context, state) => const ServiceNewScreen()),
        GoRoute(path: '/services/:id', builder: (context, state) => const ServiceDetailScreen()),
        GoRoute(path: '/services/:id/edit', builder: (context, state) => const ServiceEditScreen()),
        GoRoute(path: '/services/:id/archive', builder: (context, state) => const ServiceArchiveScreen()),
        GoRoute(path: '/templates', builder: (context, state) => const TemplatesListScreen()),
        GoRoute(path: '/templates/new', builder: (context, state) => const TemplateEditScreen()),
        GoRoute(path: '/templates/:id', builder: (context, state) => const TemplateDetailScreen()),
        GoRoute(path: '/templates/:id/edit', builder: (context, state) => const TemplateEditScreen()),
        GoRoute(path: '/templates/:id/use', builder: (context, state) => const TemplateUseScreen()),
        GoRoute(path: '/availability', builder: (context, state) => const AvailabilityOverviewScreen()),
        GoRoute(path: '/availability/hours', builder: (context, state) => const AvailabilityHoursScreen()),
        GoRoute(path: '/availability/blackouts', builder: (context, state) => const AvailabilityBlackoutsScreen()),
        GoRoute(path: '/availability/week', builder: (context, state) => const AvailabilityWeekScreen()),
        GoRoute(path: '/availability/time-off', builder: (context, state) => const TimeoffListScreen()),
        GoRoute(path: '/availability/time-off/new', builder: (context, state) => const TimeoffCreateScreen()),
        GoRoute(path: '/analytics', builder: (context, state) => const AnalyticsOverviewScreen()),
        GoRoute(path: '/analytics/detail', builder: (context, state) => const AnalyticsDetailScreen()),
        GoRoute(path: '/system', builder: (context, state) => const SystemHubScreen()),
        GoRoute(path: '/settings', builder: (context, state) => const SettingsHomeScreen()),
        GoRoute(path: '/settings/business-profile', builder: (context, state) => const SettingsBusinessProfileScreen()),
        GoRoute(path: '/settings/team', builder: (context, state) => const SettingsTeamScreen()),
        GoRoute(path: '/settings/roles', builder: (context, state) => const SettingsRolesScreen()),
        GoRoute(path: '/settings/notifications', builder: (context, state) => const SettingsNotificationsScreen()),
        GoRoute(path: '/settings/policies', builder: (context, state) => const SettingsPoliciesScreen()),
        GoRoute(path: '/settings/integrations', builder: (context, state) => const SettingsIntegrationsScreen()),
        GoRoute(path: '/settings/logout', builder: (context, state) => const SettingsLogoutScreen()),
        GoRoute(path: '/settings/delete-account', builder: (context, state) => const SettingsDeleteAccountScreen()),
        GoRoute(path: '/account/profile', builder: (context, state) => const AccountProfileScreen()),
        GoRoute(path: '/account/change-password', builder: (context, state) => const ChangePasswordScreen()),
        GoRoute(path: '/account/delete', builder: (context, state) => const AccountDeleteScreen()),
        GoRoute(path: '/delete', builder: (context, state) => const AccountDeleteScreen()),
        GoRoute(path: '/legal/terms', builder: (context, state) => const LegalTermsScreen()),
        GoRoute(path: '/legal/privacy', builder: (context, state) => const LegalPrivacyScreen()),
        GoRoute(path: '/legal/data-safety', builder: (context, state) => const LegalDataSafetyScreen()),
        GoRoute(path: '/support/help', builder: (context, state) => const SupportHelpScreen()),
        GoRoute(path: '/support/contact', builder: (context, state) => const SupportContactScreen()),
        GoRoute(path: '/logout', builder: (context, state) => const LogoutScreen()),
      ],
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
