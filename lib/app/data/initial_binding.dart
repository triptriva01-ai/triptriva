import 'package:get/get.dart';

import 'providers/api_client.dart';
import 'providers/token_store.dart';
import 'services/admin_service.dart';
import 'services/auth_service.dart';
import 'services/booking_service.dart';
import 'services/apple_auth_service.dart';
import 'services/google_auth_service.dart';
import 'services/home_service.dart';
import 'services/media_service.dart';
import 'services/notification_service.dart';
import 'services/geo_service.dart';
import 'services/partner_service.dart';
import 'services/pricing_service.dart';
import 'services/profile_service.dart';
import 'services/property_service.dart';
import 'services/review_service.dart';
import 'services/users_service.dart';
import 'services/search_service.dart';
import 'services/slot_service.dart';
import 'services/wishlist_service.dart';

/// Registers the networking layer with GetX before the first route loads.
///
/// Wire this into `GetMaterialApp(initialBinding: InitialBinding())`.
/// `TokenStore` and `ApiClient` are created eagerly (the client reads the
/// store on init); services are lazy so they are only built when a screen
/// first asks for them.
class InitialBinding extends Bindings {
  @override
  void dependencies() {
    // main() normally registers TokenStore after loading the saved session;
    // this covers tests and any entry point that skips that step.
    if (!Get.isRegistered<TokenStore>()) {
      Get.put<TokenStore>(TokenStore(), permanent: true);
    }
    Get.put<ApiClient>(ApiClient(), permanent: true);

    Get.lazyPut<AuthService>(AuthService.new, fenix: true);
    Get.lazyPut<GoogleAuthService>(GoogleAuthService.new, fenix: true);
    Get.lazyPut<AppleAuthService>(AppleAuthService.new, fenix: true);
    Get.lazyPut<HomeService>(HomeService.new, fenix: true);
    Get.lazyPut<SearchService>(SearchService.new, fenix: true);
    Get.lazyPut<PropertyService>(PropertyService.new, fenix: true);
    Get.lazyPut<SlotService>(SlotService.new, fenix: true);
    Get.lazyPut<PricingService>(PricingService.new, fenix: true);
    Get.lazyPut<BookingService>(BookingService.new, fenix: true);
    Get.lazyPut<WishlistService>(WishlistService.new, fenix: true);
    Get.lazyPut<ProfileService>(ProfileService.new, fenix: true);
    Get.lazyPut<UsersService>(UsersService.new, fenix: true);
    Get.lazyPut<NotificationService>(NotificationService.new, fenix: true);
    Get.lazyPut<ReviewService>(ReviewService.new, fenix: true);
    Get.lazyPut<MediaService>(MediaService.new, fenix: true);
    Get.lazyPut<AdminService>(AdminService.new, fenix: true);
    Get.lazyPut<PartnerService>(PartnerService.new, fenix: true);
    Get.lazyPut<GeoService>(GeoService.new, fenix: true);
  }
}
