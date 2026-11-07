import 'package:get/get.dart';

import '../modules/account_settings/bindings/account_settings_bindings.dart';
import '../modules/account_settings/views/payment_methods_view.dart';
import '../modules/account_settings/views/simple_settings_views.dart';
import '../modules/booking_detail/bindings/booking_detail_binding.dart';
import '../modules/booking_detail/views/booking_detail_view.dart';
import '../modules/admin/bindings/admin_bindings.dart';
import '../modules/admin/views/admin_activities_view.dart';
import '../modules/admin/views/admin_payments_view.dart';
import '../modules/admin/views/admin_profile_view.dart';
import '../modules/admin/views/admin_revenue_view.dart';
import '../modules/admin/views/admin_users_view.dart';
import '../modules/booking/bindings/booking_binding.dart';
import '../modules/booking/views/booking_view.dart';
import '../modules/edit_profile/bindings/edit_profile_binding.dart';
import '../modules/listing_detail/bindings/listing_detail_binding.dart';
import '../modules/listing_detail/views/listing_detail_view.dart';
import '../modules/notifications/bindings/notifications_binding.dart';
import '../modules/notifications/views/notifications_view.dart';
import '../modules/edit_profile/views/edit_profile_view.dart';
import '../modules/home/bindings/home_binding.dart';
import '../modules/home/views/home_view.dart';
import '../modules/partner_confirm_customer/bindings/confirm_customer_binding.dart';
import '../modules/partner_confirm_customer/views/confirm_customer_view.dart';
import '../modules/partner_dashboard/bindings/partner_dashboard_binding.dart';
import '../modules/partner_dashboard/views/partner_dashboard_view.dart';
import '../modules/partner_edit_allocation/bindings/edit_allocation_binding.dart';
import '../modules/partner_edit_allocation/views/edit_allocation_view.dart';
import '../modules/partner_edit_pricing/bindings/edit_pricing_binding.dart';
import '../modules/partner_edit_pricing/views/edit_pricing_view.dart';
import '../modules/partner_manual_booking/bindings/manual_booking_binding.dart';
import '../modules/partner_manual_booking/views/manual_booking_view.dart';
import '../modules/partner_my_business/bindings/my_business_binding.dart';
import '../modules/partner_my_business/views/my_business_view.dart';
import '../modules/partner_notifications/bindings/partner_notifications_binding.dart';
import '../modules/partner_notifications/views/partner_notifications_view.dart';
import '../modules/partner_onboarding/bindings/partner_onboarding_binding.dart';
import '../modules/partner_onboarding/views/partner_onboarding_view.dart';
import '../modules/partner_revenue/bindings/revenue_binding.dart';
import '../modules/partner_revenue/views/revenue_view.dart';
import '../modules/otp_verification/bindings/otp_binding.dart';
import '../modules/otp_verification/views/otp_view.dart';
import '../modules/partner_profile/bindings/partner_profile_binding.dart';
import '../modules/partner_profile/views/partner_profile_view.dart';
import '../modules/partner_quick_updates/bindings/quick_updates_binding.dart';
import '../modules/partner_quick_updates/views/quick_updates_view.dart';
import '../modules/profile/bindings/profile_binding.dart';
import '../modules/reservations/bindings/reservations_binding.dart';
import '../modules/reservations/views/reservations_view.dart';
import '../modules/profile/views/profile_view.dart';
import '../modules/sign_in/bindings/sign_in_binding.dart';
import '../modules/sign_in/views/sign_in_view.dart';
import '../modules/splash/bindings/splash_binding.dart';
import '../modules/splash/views/splash_view.dart';
import '../modules/wishlist/bindings/wishlist_binding.dart';
import '../modules/wishlist/views/wishlist_view.dart';

import 'admin_guard.dart';

part 'app_routes.dart';

class AppPages {
  AppPages._();

  static const INITIAL = Routes.SPLASH;

  static final routes = [
    GetPage(
      name: _Paths.SPLASH,
      page: () => const SplashView(),
      binding: SplashBinding(),
    ),
    GetPage(
      name: _Paths.SIGN_IN,
      page: () => const SignInView(),
      binding: SignInBinding(),
    ),
    GetPage(
      name: _Paths.HOME,
      page: () => const HomeView(),
      binding: HomeBinding(),
    ),
    GetPage(
      name: _Paths.PROFILE,
      page: () => const ProfileView(),
      binding: ProfileBinding(),
    ),
    GetPage(
      name: _Paths.PARTNER_DASHBOARD,
      page: () => const PartnerDashboardView(),
      binding: PartnerDashboardBinding(),
    ),
    GetPage(
      name: _Paths.RESERVATIONS,
      page: () => const ReservationsView(),
      binding: ReservationsBinding(),
    ),
    GetPage(
      name: _Paths.PARTNER_QUICK_UPDATES,
      page: () => const QuickUpdatesView(),
      binding: QuickUpdatesBinding(),
    ),
    GetPage(
      name: _Paths.PARTNER_PROFILE,
      page: () => const PartnerProfileView(),
      binding: PartnerProfileBinding(),
    ),
    GetPage(
      name: _Paths.OTP,
      page: () => const OtpView(),
      binding: OtpBinding(),
    ),
    GetPage(
      name: _Paths.EDIT_PROFILE,
      page: () => const EditProfileView(),
      binding: EditProfileBinding(),
    ),
    GetPage(
      name: _Paths.PARTNER_MANUAL_BOOKING,
      page: () => const ManualBookingView(),
      binding: ManualBookingBinding(),
    ),
    GetPage(
      name: _Paths.PARTNER_CONFIRM_CUSTOMER,
      page: () => const ConfirmCustomerView(),
      binding: ConfirmCustomerBinding(),
    ),
    GetPage(
      name: _Paths.PARTNER_EDIT_ALLOCATION,
      page: () => const EditAllocationView(),
      binding: EditAllocationBinding(),
    ),
    GetPage(
      name: _Paths.PARTNER_EDIT_PRICING,
      page: () => const EditPricingView(),
      binding: EditPricingBinding(),
    ),
    GetPage(
      name: _Paths.PARTNER_MY_BUSINESS,
      page: () => const MyBusinessView(),
      binding: MyBusinessBinding(),
    ),
    GetPage(
      name: _Paths.PARTNER_REVENUE,
      page: () => const RevenueView(),
      binding: RevenueBinding(),
    ),
    GetPage(
      name: _Paths.PARTNER_NOTIFICATIONS,
      page: () => const PartnerNotificationsView(),
      binding: PartnerNotificationsBinding(),
    ),
    GetPage(
      name: _Paths.PARTNER_ONBOARDING,
      page: () => const PartnerOnboardingView(),
      binding: PartnerOnboardingBinding(),
    ),
    GetPage(
      name: _Paths.BOOKING_DETAIL,
      page: () => const BookingDetailView(),
      binding: BookingDetailBinding(),
    ),
    GetPage(
      name: _Paths.WISHLIST,
      page: () => const WishlistView(),
      binding: WishlistBinding(),
    ),
    GetPage(
      name: _Paths.NOTIFICATIONS,
      page: () => const NotificationsView(),
      binding: NotificationsBinding(),
    ),
    GetPage(
      name: _Paths.LISTING_DETAIL,
      page: () => const ListingDetailView(),
      binding: ListingDetailBinding(),
    ),
    GetPage(
      name: _Paths.BOOKING,
      page: () => const BookingView(),
      binding: BookingBinding(),
    ),
    // Admin panel. Every route is behind [AdminGuard]; see admin_access.dart
    // for why the server must check the role as well.
    GetPage(
      name: _Paths.ADMIN_REVENUE,
      page: () => const AdminRevenueView(),
      binding: AdminRevenueBinding(),
      middlewares: [AdminGuard()],
    ),
    GetPage(
      name: _Paths.ADMIN_ACTIVITIES,
      page: () => const AdminActivitiesView(),
      binding: AdminActivitiesBinding(),
      middlewares: [AdminGuard()],
    ),
    GetPage(
      name: _Paths.ADMIN_PAYMENTS,
      page: () => const AdminPaymentsView(),
      binding: AdminPaymentsBinding(),
      middlewares: [AdminGuard()],
    ),
    GetPage(
      name: _Paths.ADMIN_USERS,
      page: () => const AdminUsersView(),
      binding: AdminUsersBinding(),
      middlewares: [AdminGuard()],
    ),
    GetPage(
      name: _Paths.ADMIN_PROFILE,
      page: () => const AdminProfileView(),
      binding: AdminProfileBinding(),
      middlewares: [AdminGuard()],
    ),
    GetPage(
      name: _Paths.PAYMENT_METHODS,
      page: () => const PaymentMethodsView(),
      binding: PaymentMethodsBinding(),
    ),
    GetPage(
      name: _Paths.LANGUAGE,
      page: () => const LanguageView(),
      binding: LanguageBinding(),
    ),
    GetPage(
      name: _Paths.FEEDBACK,
      page: () => const FeedbackView(),
      binding: FeedbackBinding(),
    ),
    GetPage(
      name: _Paths.CUSTOMER_SUPPORT,
      page: () => const CustomerSupportView(),
      binding: CustomerSupportBinding(),
    ),
    GetPage(
      name: _Paths.ABOUT,
      page: () => const AboutView(),
    ),
  ];
}
