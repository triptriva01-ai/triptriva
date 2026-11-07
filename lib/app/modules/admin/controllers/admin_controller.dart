import 'package:get/get.dart';

import '../../../data/models/admin_models.dart';
import '../../../data/models/user.dart';
import '../../../data/providers/api_exception.dart';
import '../../../data/services/admin_service.dart';
import '../../../routes/app_pages.dart';
import '../constants/admin_constants.dart';
import '../widgets/admin_nav.dart';

/// Shared behaviour for every admin tab: the bottom navigation and the
/// snackbar for features that have no screen yet.
abstract class AdminBaseController extends GetxController {
  final AdminService adminService = Get.find<AdminService>();

  /// Which bottom-nav destination this screen is.
  int get tabIndex;

  late final currentTab = tabIndex.obs;

  static const _routes = <String>[
    Routes.ADMIN_REVENUE,
    Routes.ADMIN_ACTIVITIES,
    Routes.ADMIN_PAYMENTS,
    Routes.ADMIN_USERS,
    Routes.ADMIN_PROFILE,
  ];

  void onTabSelected(int index) {
    if (index == currentTab.value) return;
    Get.offNamed(_routes[index]);
  }

  void pending(String feature) {
    Get.snackbar(
      AdminStrings.pendingTitle,
      AdminStrings.pendingMessage(feature),
      duration: AdminDurations.snackbar,
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  /// Indian digit grouping: ₹1,21,500.
  static String formatRupees(double amount) {
    final whole = amount.round().abs().toString();
    if (whole.length <= 3) {
      return '₹$whole';
    }
    final last3 = whole.substring(whole.length - 3);
    var rest = whole.substring(0, whole.length - 3);
    final groups = <String>[];
    while (rest.length > 2) {
      groups.insert(0, rest.substring(rest.length - 2));
      rest = rest.substring(0, rest.length - 2);
    }
    if (rest.isNotEmpty) {
      groups.insert(0, rest);
    }
    return '₹${groups.join(',')},$last3';
  }
}

// ── Revenue ───────────────────────────────────────────────────────────

class AdminRevenueController extends AdminBaseController {
  @override
  int get tabIndex => AdminNav.revenue;

  final summary = const RevenueSummary().obs;
  final curve = <RevenuePoint>[].obs;
  final categories = <({String label, double value})>[].obs;
  final bookings = <AdminBooking>[].obs;
  final isLoading = false.obs;
  final selectedCategory = 0.obs;

  static const categoryFilters = <String>[
    AdminStrings.filterAll,
    AdminStrings.filterHouseBoat,
    AdminStrings.filterStay,
    AdminStrings.filterAdventure,
  ];

  @override
  void onInit() {
    super.onInit();
    load();
  }

  Future<void> load() async {
    isLoading.value = true;
    try {
      final results = await Future.wait([
        adminService.revenueSummary(),
        adminService.revenueGrowthCurve(),
        adminService.revenueCategories(),
        adminService.revenueBookings(query: _bookingQuery()),
      ]);

      if (results[0] is Map<String, dynamic>) {
        summary.value =
            RevenueSummary.fromJson(results[0] as Map<String, dynamic>);
      }
      curve.assignAll(_points(results[1]));
      categories.assignAll(_categories(results[2]));
      bookings.assignAll(_bookings(results[3]));
    } on ApiException catch (error) {
      Get.log('Admin revenue load failed: $error');
      _loadSample();
    } finally {
      isLoading.value = false;
    }
  }

  Map<String, dynamic>? _bookingQuery() {
    final index = selectedCategory.value;
    if (index == 0) return null;
    return {'category': categoryFilters[index]};
  }

  List<RevenuePoint> _points(dynamic data) {
    if (data is! List) return const [];
    return data
        .whereType<Map<String, dynamic>>()
        .map(RevenuePoint.fromJson)
        .toList();
  }

  List<({String label, double value})> _categories(dynamic data) {
    if (data is! List) return const [];
    return data.whereType<Map<String, dynamic>>().map((json) {
      return (
        label: '${json['label'] ?? json['category'] ?? ''}',
        value: (json['value'] is num)
            ? (json['value'] as num).toDouble()
            : 0.0,
      );
    }).toList();
  }

  List<AdminBooking> _bookings(dynamic data) {
    if (data is! List) return const [];
    return data
        .whereType<Map<String, dynamic>>()
        .map(AdminBooking.fromJson)
        .toList();
  }

  void selectCategory(int index) {
    if (index == selectedCategory.value) return;
    selectedCategory.value = index;
    load();
  }

  void openBooking(AdminBooking booking) => pending(booking.title);

  // -------------------------------------------------------------------
  // Development placeholder — remove once `/api/admin/revenue/*` serves
  // real data.
  // -------------------------------------------------------------------

  void _loadSample() {
    summary.value = const RevenueSummary(
      monthTotal: 12450,
      yearTotal: 148200,
      monthGrowthPercent: 12,
      bookingCount: 1248,
    );
    curve.assignAll(const [
      RevenuePoint(label: 'J', value: 4200),
      RevenuePoint(label: 'F', value: 6100),
      RevenuePoint(label: 'M', value: 5400),
      RevenuePoint(label: 'A', value: 8300),
      RevenuePoint(label: 'M', value: 12450),
    ]);
    categories.assignAll(const [
      (label: 'House Boat', value: 2500),
      (label: 'Stay', value: 1500),
      (label: 'Adventure', value: 500),
    ]);
    bookings.assignAll(const [
      AdminBooking(
        id: '1',
        title: 'Kerala Boat Ac',
        listingName: 'Kerala boat',
        category: 'House Boat',
        amount: 18500,
        dateRange: 'Sep 12 - Sep 14, 2023',
      ),
      AdminBooking(
        id: '2',
        title: 'Kayaking in Thrissur',
        listingName: 'Kayaking',
        category: 'Adventure',
        amount: 18500,
        dateRange: 'Sep 12 - Sep 14, 2023',
      ),
      AdminBooking(
        id: '3',
        title: 'Tent House Stay',
        listingName: 'Tent house',
        category: 'home stay',
        amount: 18500,
        dateRange: 'Sep 12 - Sep 14, 2023',
      ),
      AdminBooking(
        id: '4',
        title: 'Refreshing Room',
        listingName: 'Refreshing room',
        category: 'Refreshing room',
        amount: 18500,
        dateRange: 'Sep 12 - Sep 14, 2023',
      ),
    ]);
  }
}

// ── Activities ────────────────────────────────────────────────────────

class AdminActivitiesController extends AdminBaseController {
  @override
  int get tabIndex => AdminNav.activities;

  final activities = <AdminActivitySubmission>[].obs;
  final categories = <({String label, double value})>[].obs;
  final isLoading = false.obs;

  /// False shows the Accepted tab, true the Pending tab.
  final showPending = false.obs;
  final selectedCategory = 0.obs;

  static const categoryFilters = AdminRevenueController.categoryFilters;

  @override
  void onInit() {
    super.onInit();
    load();
  }

  Future<void> load() async {
    isLoading.value = true;
    try {
      final results = await Future.wait([
        adminService.getActivities(query: {
          'status': showPending.value ? 'pending' : 'accepted',
          if (selectedCategory.value > 0)
            'category': categoryFilters[selectedCategory.value],
        }),
        adminService.activityAnalytics(),
      ]);

      final list = results[0];
      activities.assignAll(
        list is List
            ? list
                .whereType<Map<String, dynamic>>()
                .map(AdminActivitySubmission.fromJson)
            : const <AdminActivitySubmission>[],
      );

      final analytics = results[1];
      if (analytics is List) {
        categories.assignAll(
          analytics.whereType<Map<String, dynamic>>().map((json) {
            return (
              label: '${json['label'] ?? ''}',
              value: (json['value'] is num)
                  ? (json['value'] as num).toDouble()
                  : 0.0,
            );
          }),
        );
      }
    } on ApiException catch (error) {
      Get.log('Admin activities load failed: $error');
      _loadSample();
    } finally {
      isLoading.value = false;
    }
  }

  void showAccepted() {
    if (!showPending.value) return;
    showPending.value = false;
    load();
  }

  void showPendingTab() {
    if (showPending.value) return;
    showPending.value = true;
    load();
  }

  void selectCategory(int index) {
    if (index == selectedCategory.value) return;
    selectedCategory.value = index;
    load();
  }

  /// Approving removes the row from the pending list straight away, and puts
  /// it back if the request fails.
  Future<void> accept(AdminActivitySubmission activity) =>
      _review(activity, accepted: true);

  Future<void> reject(AdminActivitySubmission activity) =>
      _review(activity, accepted: false);

  Future<void> _review(
    AdminActivitySubmission activity, {
    required bool accepted,
  }) async {
    final index = activities.indexWhere((item) => item.id == activity.id);
    if (index < 0) return;

    final removed = activities.removeAt(index);
    try {
      if (accepted) {
        await adminService.acceptActivity(activity.id);
      } else {
        await adminService.rejectActivity(activity.id);
      }
    } on ApiException catch (error) {
      Get.log('Activity review failed: $error');
      activities.insert(index, removed);
      Get.snackbar(
        AdminStrings.pendingTitle,
        error.message,
        duration: AdminDurations.snackbar,
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  void openActivity(AdminActivitySubmission activity) => pending(activity.name);

  void _loadSample() {
    categories.assignAll(const [
      (label: 'House Boat', value: 500),
      (label: 'Stay', value: 150),
      (label: 'Adventure', value: 50),
    ]);
    activities.assignAll([
      for (var index = 0; index < 4; index++)
        AdminActivitySubmission(
          id: '${index + 1}',
          name: 'Adventure Pack',
          category: const [
            'House Boat',
            'Adventure',
            'Home stay',
            'Refreshing room',
          ][index],
          ownerName: 'john ty',
          dateRange: 'Sep 12 - Sep 14, 2023',
          status: showPending.value
              ? ActivityStatus.pending
              : ActivityStatus.accepted,
        ),
    ]);
  }
}

// ── Payment release ───────────────────────────────────────────────────

class AdminPaymentsController extends AdminBaseController {
  @override
  int get tabIndex => AdminNav.payment;

  final payments = <PaymentRelease>[].obs;
  final isLoading = false.obs;

  /// False sorts by user, true by date.
  final sortByDate = false.obs;

  /// The row currently showing its breakdown.
  final expandedId = ''.obs;

  @override
  void onInit() {
    super.onInit();
    load();
  }

  Future<void> load() async {
    isLoading.value = true;
    try {
      // Payment release has no dedicated endpoint yet; the revenue bookings
      // feed carries the same rows.
      final data = await adminService.revenueBookings(
        query: {'sort': sortByDate.value ? 'date' : 'user'},
      );
      payments.assignAll(
        data is List
            ? data.whereType<Map<String, dynamic>>().map(PaymentRelease.fromJson)
            : const <PaymentRelease>[],
      );
    } on ApiException catch (error) {
      Get.log('Admin payments load failed: $error');
      _loadSample();
    } finally {
      isLoading.value = false;
    }
  }

  void sortByUser() {
    if (!sortByDate.value) return;
    sortByDate.value = false;
    load();
  }

  void sortByDateSelected() {
    if (sortByDate.value) return;
    sortByDate.value = true;
    load();
  }

  void toggleExpanded(PaymentRelease payment) {
    if (!payment.canExpand) return;
    expandedId.value = expandedId.value == payment.id ? '' : payment.id;
  }

  void _loadSample() {
    payments.assignAll(const [
      PaymentRelease(
        id: '1',
        bookingId: '301928',
        customerName: 'John Smith',
        advanceAmount: 18500,
        secondAmount: 18500,
        totalAmount: 37000,
        date: '20 April',
        timeSlot: '10:00 AM - 4:00 PM',
      ),
      PaymentRelease(
        id: '2',
        bookingId: '301928',
        customerName: 'John Smith',
        stage: PaymentStage.advancePaid,
        advanceAmount: 18500,
        secondAmount: 18500,
        totalAmount: 37000,
        date: '20 April',
        timeSlot: '10:00 AM - 4:00 PM',
      ),
      PaymentRelease(
        id: '3',
        bookingId: '301928',
        customerName: 'John Smith',
        stage: PaymentStage.completed,
        advanceAmount: 18500,
        secondAmount: 18500,
        totalAmount: 37000,
        date: '20 April',
        timeSlot: '10:00 AM - 4:00 PM',
      ),
    ]);
  }
}

// ── Users ─────────────────────────────────────────────────────────────

class AdminUsersController extends AdminBaseController {
  @override
  int get tabIndex => AdminNav.users;

  final users = <User>[].obs;
  final isLoading = false.obs;
  final selectedFilter = 0.obs;

  static const filters = <String>[
    AdminStrings.filterAll,
    AdminStrings.filterPartner,
    AdminStrings.filterNormal,
  ];

  @override
  void onInit() {
    super.onInit();
    load();
  }

  Future<void> load() async {
    isLoading.value = true;
    try {
      final data = await adminService.getUsers(query: {
        'type': switch (selectedFilter.value) {
          1 => 'partner',
          2 => 'normal',
          _ => 'all',
        },
      });
      users.assignAll(
        data is List
            ? data.whereType<Map<String, dynamic>>().map(User.fromJson)
            : const <User>[],
      );
    } on ApiException catch (error) {
      Get.log('Admin users load failed: $error');
      _loadSample();
    } finally {
      isLoading.value = false;
    }
  }

  void selectFilter(int index) {
    if (index == selectedFilter.value) return;
    selectedFilter.value = index;
    load();
  }

  void openUser(User user) => pending(user.name);

  void _loadSample() {
    users.assignAll(const [
      User(id: '1', name: 'Raju MNK', role: 'partner'),
      User(id: '2', name: 'John Smith', role: 'partner'),
      User(id: '3', name: 'Fahad', role: 'normal'),
      User(id: '4', name: 'Anitha K', role: 'normal'),
    ]);
  }
}
