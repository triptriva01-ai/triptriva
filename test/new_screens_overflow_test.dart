import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

import 'package:trip_trivia/app/data/providers/api_client.dart';
import 'package:trip_trivia/app/data/providers/token_store.dart';
import 'package:trip_trivia/app/data/services/auth_service.dart';
import 'package:trip_trivia/app/data/services/booking_service.dart';
import 'package:trip_trivia/app/data/services/geo_service.dart';
import 'package:trip_trivia/app/data/services/search_service.dart';
import 'package:trip_trivia/app/data/services/wishlist_service.dart';
import 'package:trip_trivia/app/modules/otp_verification/controllers/otp_controller.dart';
import 'package:trip_trivia/app/modules/otp_verification/views/otp_view.dart';
import 'package:trip_trivia/app/modules/payment/controllers/payment_controller.dart';
import 'package:trip_trivia/app/modules/payment/views/booking_success_view.dart';
import 'package:trip_trivia/app/modules/payment/views/payment_view.dart';
import 'package:trip_trivia/app/modules/search/controllers/search_controller.dart';
import 'package:trip_trivia/app/modules/search/views/search_view.dart';
import 'package:trip_trivia/app/widgets/charts/revenue_chart.dart';

/// Same sizes as `partner_layout_overflow_test.dart`.
const _viewports = <String, Size>{
  'small phone (320x568)': Size(320, 568),
  'common phone (360x800)': Size(360, 800),
  'large phone (411x914)': Size(411, 914),
};

const _textScales = <double>[1, 1.3];

void main() {
  // The screens' controllers find their services on creation. Requests go
  // nowhere in a widget test and fail quietly, leaving the empty states.
  setUp(() {
    Get.put(TokenStore());
    Get.put(ApiClient());
    Get.put(SearchService());
    Get.put(WishlistService());
    Get.put(GeoService());
    Get.put(BookingService());
    Get.put(AuthService());
  });

  tearDown(Get.reset);

  /// Pumps a full screen at every size and fails on any overflow.
  Future<void> expectNoOverflow(
    WidgetTester tester,
    Widget Function() build, {
    Future<void> Function()? arrange,
  }) async {
    for (final viewport in _viewports.entries) {
      for (final scale in _textScales) {
        tester.view.physicalSize = viewport.value;
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.reset);

        final errors = <FlutterErrorDetails>[];
        final previousOnError = FlutterError.onError;
        FlutterError.onError = errors.add;

        await tester.pumpWidget(
          MediaQuery(
            data: MediaQueryData(
              size: viewport.value,
              textScaler: TextScaler.linear(scale),
            ),
            child: GetMaterialApp(home: build()),
          ),
        );
        await tester.pump();
        if (arrange != null) {
          await arrange();
          await tester.pump();
        }

        FlutterError.onError = previousOnError;
        final overflows = errors
            .where((error) => '${error.exception}'.contains('overflowed'))
            .toList();
        expect(
          overflows,
          isEmpty,
          reason: '${viewport.key} at ${scale}x: ${overflows.map((e) => e.exception)}',
        );
      }
    }
  }

  testWidgets('search, idle and typing', (tester) async {
    final controller = Get.put(AppSearchController());
    await expectNoOverflow(tester, () => const SearchView());

    controller.textController.text = 'Al';
    controller.onQueryChanged('Al');
    controller.suggestions.assignAll(const [
      SearchSuggestion(name: 'Alapuzha', stayCount: 30),
      SearchSuggestion(name: 'Aluva'),
    ]);
    await expectNoOverflow(tester, () => const SearchView());
    controller.mode.value = SearchMode.results;
    await expectNoOverflow(tester, () => const SearchView());
    // Let the suggestion debounce fire before the test ends.
    await tester.pump(const Duration(milliseconds: 400));
  });

  testWidgets('payment, UPI and card expanded', (tester) async {
    final controller = Get.put(PaymentController());
    await expectNoOverflow(tester, () => const PaymentView());

    controller.toggle(PaymentMethod.upi);
    await expectNoOverflow(tester, () => const PaymentView());

    controller.toggle(PaymentMethod.card);
    await expectNoOverflow(tester, () => const PaymentView());
  });

  testWidgets('booking success', (tester) async {
    final controller = Get.put(BookingSuccessController());
    controller.reveal.value = 1;
    await expectNoOverflow(tester, () => const BookingSuccessView());
  });

  testWidgets('OTP code boxes', (tester) async {
    final controller = Get.put(OtpController());
    await expectNoOverflow(tester, () => const OtpView());
    controller.code.value = '1234';
    await expectNoOverflow(tester, () => const OtpView());
    // Stop the resend countdown before the test ends.
    Get.delete<OtpController>();
  });

  testWidgets('revenue chart with a 30-day series', (tester) async {
    await expectNoOverflow(
      tester,
      () => Scaffold(
        body: Padding(
          // The admin card leaves the chart about 262 wide on a 360 phone.
          padding: const EdgeInsets.symmetric(horizontal: 49),
          child: RevenueChart(
            values: [for (var day = 0; day < 30; day++) (day % 7) * 100.0],
            labels: [for (var day = 1; day <= 30; day++) '$day'],
          ),
        ),
      ),
    );
  });
}
