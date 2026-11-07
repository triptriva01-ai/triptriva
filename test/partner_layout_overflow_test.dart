import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:trip_trivia/app/data/models/partner_activity.dart';
import 'package:trip_trivia/app/data/models/partner_booking.dart';
import 'package:trip_trivia/app/widgets/partner/partner_booking_card.dart';
import 'package:trip_trivia/app/widgets/partner/partner_bottom_nav.dart';
import 'package:trip_trivia/app/widgets/partner/partner_fields.dart';
import 'package:trip_trivia/app/widgets/calendar/month_calendar.dart';
import 'package:trip_trivia/app/widgets/partner/partner_primary_button.dart';
import 'package:trip_trivia/app/widgets/partner/partner_shell_header.dart';
import 'package:trip_trivia/app/widgets/partner/partner_activity_card.dart';
import 'package:trip_trivia/app/widgets/app_bottom_nav.dart';
import 'package:trip_trivia/app/widgets/profile/logout_button.dart';
import 'package:trip_trivia/app/widgets/profile/profile_settings_row.dart';
import 'package:trip_trivia/app/modules/sign_in/widgets/primary_gradient_button.dart';
import 'package:trip_trivia/app/data/models/booking_detail.dart';
import 'package:trip_trivia/app/modules/booking_detail/widgets/about_section.dart';
import 'package:trip_trivia/app/modules/booking_detail/widgets/detail_card.dart';
import 'package:trip_trivia/app/data/models/listing.dart';
import 'package:trip_trivia/app/widgets/listing/listing_grid.dart';
import 'package:trip_trivia/app/modules/wishlist/widgets/no_more_wishes.dart';
import 'package:trip_trivia/app/data/models/app_notification.dart';
import 'package:trip_trivia/app/data/models/listing_detail.dart';
import 'package:trip_trivia/app/modules/notifications/widgets/notification_tile.dart';
import 'package:trip_trivia/app/modules/listing_detail/widgets/listing_sections.dart';
import 'package:trip_trivia/app/modules/listing_detail/widgets/listing_summary.dart';
import 'package:trip_trivia/app/modules/listing_detail/widgets/nearby_section.dart';
import 'package:trip_trivia/app/modules/booking/widgets/date_range_row.dart';
import 'package:trip_trivia/app/modules/booking/widgets/pax_selector.dart';
import 'package:trip_trivia/app/modules/booking/widgets/slot_option_row.dart';
import 'package:trip_trivia/app/widgets/booking/booking_bottom_bar.dart';
import 'package:trip_trivia/app/data/models/admin_models.dart';
import 'package:trip_trivia/app/widgets/charts/donut_chart.dart';
import 'package:trip_trivia/app/modules/admin/widgets/admin_cards.dart';
import 'package:trip_trivia/app/modules/admin/widgets/admin_nav.dart';
import 'package:trip_trivia/app/modules/admin/widgets/admin_shell.dart';
import 'package:trip_trivia/app/modules/admin/widgets/payment_card.dart';

/// Screen sizes to check, from the smallest phone we expect to support up to a
/// large one. Overflow shows up at the narrow end, so that is where the value
/// is; the wide sizes guard against the opposite mistake.
const _viewports = <String, Size>{
  'small phone (320x568)': Size(320, 568),
  'common phone (360x800)': Size(360, 800),
  'large phone (411x914)': Size(411, 914),
  'tablet (768x1024)': Size(768, 1024),
};

/// Font scales to check: the default, and the ceiling `main.dart` clamps to.
const _textScales = <double>[1, 1.3];

void main() {
  /// Renders [child] at every viewport and text scale, failing on any
  /// "RenderFlex overflowed" error raised during layout or paint.
  Future<void> expectNoOverflow(
    WidgetTester tester,
    String description,
    Widget Function() build,
  ) async {
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
            child: MaterialApp(
              home: Scaffold(body: SingleChildScrollView(child: build())),
            ),
          ),
        );
        await tester.pump();

        FlutterError.onError = previousOnError;

        final overflows = errors
            .where((error) => '${error.exception}'.contains('overflowed'))
            .toList();
        expect(
          overflows,
          isEmpty,
          reason: '$description overflowed at ${viewport.key}, '
              'text scale $scale:\n'
              '${overflows.map((e) => e.exception).join('\n')}',
        );
      }
    }
  }

  testWidgets('shell header fits every viewport', (tester) async {
    await expectNoOverflow(
      tester,
      'PartnerShellHeader',
      () => PartnerShellHeader(
        // A deliberately long name: the header must ellipsise, not overflow.
        name: 'Akhil Krishnan Vijayaraghavan',
        onNotificationsTap: () {},
        onProfileTap: () {},
        tabs: const ['Prices & Discount', 'Slot Allocation'],
        selectedTab: 0,
        onTabSelected: (_) {},
      ),
    );
  });

  testWidgets('bottom nav fits every viewport', (tester) async {
    await expectNoOverflow(
      tester,
      'PartnerBottomNav',
      () => PartnerBottomNav(currentIndex: 0, onTap: (_) {}),
    );
  });

  testWidgets('month calendar fits every viewport', (tester) async {
    await expectNoOverflow(
      tester,
      'MonthCalendar',
      () => MonthCalendar(
        month: DateTime(2024, 7),
        onPreviousMonth: () {},
        onNextMonth: () {},
        styleFor: (_) => const DayStyle(fill: Color(0xFF1F7A62)),
      ),
    );
  });

  testWidgets('calendar legend fits every viewport', (tester) async {
    await expectNoOverflow(
      tester,
      'CalendarLegend',
      () => const CalendarLegend(
        entries: [
          (color: Color(0xFFD9D9D9), label: 'Full Filled'),
          (color: Color(0xFF1F7A62), label: 'offer'),
          (color: Color(0xFF2D9CDB), label: 'Season'),
        ],
      ),
    );
  });

  testWidgets('category chips fit every viewport', (tester) async {
    await expectNoOverflow(
      tester,
      'PartnerCategoryChips',
      () => const PartnerCategoryChips(
        categories: ['All', 'House boat', 'Stay', 'Advneture'],
        selectedIndex: 0,
        onSelected: _noop,
      ),
    );
  });

  testWidgets('primary button fits every viewport', (tester) async {
    await expectNoOverflow(
      tester,
      'PartnerPrimaryButton',
      () => PartnerPrimaryButton.add(
        label: 'Add Manual Slot',
        onPressed: () {},
      ),
    );
  });

  testWidgets('option card fits every viewport', (tester) async {
    await expectNoOverflow(
      tester,
      'PartnerOptionCard',
      () => PartnerOptionCard(
        label: 'Refreshing room',
        icon: Icons.bed_outlined,
        axis: Axis.vertical,
        selected: false,
        onTap: () {},
      ),
    );
  });

  testWidgets('booking card fits every viewport', (tester) async {
    await expectNoOverflow(
      tester,
      'PartnerBookingCard',
      () => PartnerBookingCard(
        booking: PartnerBooking(
          id: '1',
          listingId: 'l1',
          listingTitle: 'The Blue Lagoon Houseboat',
          guestName: 'John Smith',
          date: DateTime(2026, 4, 20),
          slotStartTime: '10:00',
          slotEndTime: '16:00',
          pax: 4,
          status: 'confirmed',
        ),
        customerName: 'John Smith',
        onConfirm: () {},
      ),
    );
  });

  testWidgets('activity card fits every viewport', (tester) async {
    await expectNoOverflow(
      tester,
      'PartnerActivityCard',
      () => PartnerActivityCard(
        activity: const PartnerActivity(
          id: '1',
          name: 'Tree hut in Thrissur',
          location: 'Palarivattam',
          basePrice: 1200,
          discountPercent: 58,
          status: 'pending',
        ),
        onTap: () {},
      ),
    );
  });

  testWidgets('counter row fits every viewport', (tester) async {
    await expectNoOverflow(
      tester,
      'PartnerCounterRow',
      () => PartnerCounterRow(
        label: 'Bathrooms',
        value: 12,
        onDecrement: () {},
        onIncrement: () {},
      ),
    );
  });

  testWidgets('value row fits every viewport', (tester) async {
    await expectNoOverflow(
      tester,
      'PartnerValueRow',
      () => const PartnerValueRow(
        title: 'Off season discounts',
        caption: 'Disappears after 3 days of booking',
        value: '20%',
      ),
    );
  });

  // ── Traveller-side chrome ───────────────────────────────────────────
  // The same fixed-size patterns exist outside the partner app, so the
  // shared pieces are covered here too.

  testWidgets('traveller bottom nav fits every viewport', (tester) async {
    await expectNoOverflow(
      tester,
      'AppBottomNav',
      () => AppBottomNav(currentIndex: 0, onTap: (_) {}),
    );
  });

  testWidgets('profile settings row fits every viewport', (tester) async {
    await expectNoOverflow(
      tester,
      'ProfileSettingsRow',
      () => ProfileSettingsRow(
        icon: Icons.privacy_tip_outlined,
        label: 'Data Control & Privacy',
        onTap: () {},
      ),
    );
  });

  testWidgets('logout button fits every viewport', (tester) async {
    await expectNoOverflow(
      tester,
      'LogoutButton',
      () => LogoutButton(label: 'Log Out', onTap: () {}),
    );
  });

  testWidgets('sign-in primary button fits every viewport', (tester) async {
    await expectNoOverflow(
      tester,
      'PrimaryGradientButton',
      () => PrimaryGradientButton(label: 'Continue', onTap: () {}),
    );
  });

  // ── Booking detail ──────────────────────────────────────────────────

  testWidgets('booking detail card fits every viewport', (tester) async {
    await expectNoOverflow(
      tester,
      'DetailCard',
      () => const DetailCard(
        title: 'Booking Details',
        child: BulletRow(
          label: 'Cancellation is allowed before 10 days before the slot date',
        ),
      ),
    );
  });

  testWidgets('booking detail link row fits every viewport', (tester) async {
    await expectNoOverflow(
      tester,
      'DetailLinkRow',
      () => DetailLinkRow(
        icon: Icons.download_outlined,
        label: 'Download invoice',
        onTap: () {},
        trailing: const Icon(Icons.chevron_right),
      ),
    );
  });

  testWidgets('related listing card fits every viewport', (tester) async {
    await expectNoOverflow(
      tester,
      'RelatedListingCard',
      () => RelatedListingCard(
        listing: const RelatedListing(
          id: '1',
          name: 'Kerala Tree House Ac',
          address: 'Palarivattam , Kochi , Kerala',
        ),
        onTap: () {},
      ),
    );
  });

  // ── Listing card / Wishlist ─────────────────────────────────────────
  // The card is narrowest in a two-column grid, which is how Wishlist and
  // most of Home use it — so the grid is what gets measured.

  testWidgets('listing grid fits every viewport', (tester) async {
    await expectNoOverflow(
      tester,
      'ListingGrid',
      () => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: ListingGrid(
          listings: const [
            Listing(
              id: '1',
              // Long enough to need ellipsis at 320 dp.
              title: 'Kerala Backwater Houseboat Deluxe',
              location: 'Palarivattam, Ernakulam',
              rating: 4.5,
              price: 500,
              originalPrice: 1200,
              discountPercent: 14,
              isWishlisted: true,
            ),
            Listing(
              id: '2',
              title: 'Tree hut in Thrissur',
              location: 'Palarivattam',
              rating: 4.5,
              price: 12500,
              originalPrice: 18000,
              discountPercent: 30,
            ),
          ],
          onListingTap: _noopListing,
          onWishlistTap: _noopListing,
        ),
      ),
    );
  });

  testWidgets('no more wishes fits every viewport', (tester) async {
    await expectNoOverflow(
      tester,
      'NoMoreWishes',
      () => const NoMoreWishes(showIllustration: true),
    );
  });

  // ── Notifications ───────────────────────────────────────────────────

  testWidgets('notification tile fits every viewport', (tester) async {
    await expectNoOverflow(
      tester,
      'NotificationTile',
      () => NotificationTile(
        notification: const AppNotification(
          id: '1',
          title: 'House Boat Booking',
          message: 'Your booking is for the kerala house boat is incomplete.'
              'Hurry up! before the slot filled.',
          timeAgo: '3 hours ago',
          kind: NotificationKind.booking,
        ),
        onTap: () {},
      ),
    );
  });

  testWidgets('offer notification fits every viewport', (tester) async {
    await expectNoOverflow(
      tester,
      'NotificationTile (offer)',
      () => NotificationTile(
        notification: const AppNotification(
          id: '2',
          title: 'Offers',
          timeAgo: '3 hours ago',
          kind: NotificationKind.offer,
          imageUrl: 'placeholder',
        ),
        onTap: () {},
      ),
    );
  });

  // ── Listing detail ──────────────────────────────────────────────────

  testWidgets('listing summary fits every viewport', (tester) async {
    await expectNoOverflow(
      tester,
      'ListingSummary',
      () => const ListingSummary(
        detail: ListingDetail(
          id: '1',
          name: 'Thrissur Tree House',
          address: 'Palarivattam , Kochi , Kerala',
          rooms: 3,
          bathrooms: 3,
          beds: 6,
          rating: 4.5,
          ratingLabel: 'Great',
          ratingCaption: 'For the user',
          reviewCount: 5,
        ),
      ),
    );
  });

  testWidgets('host row fits every viewport', (tester) async {
    await expectNoOverflow(
      tester,
      'HostRow',
      () => const HostRow(
        host: ListingHost(name: 'Raju Manikkoth Narayanan Kutty'),
      ),
    );
  });

  testWidgets('bullet section fits every viewport', (tester) async {
    await expectNoOverflow(
      tester,
      'BulletSection',
      () => const BulletSection(
        title: 'Our Policies',
        items: [
          'Cancellation is allowed before 10 days before the slot date',
          'Guests are not allowed',
        ],
      ),
    );
  });

  testWidgets('nearby section fits every viewport', (tester) async {
    await expectNoOverflow(
      tester,
      'NearbySection',
      () => NearbySection(
        title: 'Near By Tree House',
        listings: const [
          Listing(
            id: '1',
            title: 'Tree House',
            location: 'Palarivattam',
            rating: 4.5,
            price: 500,
            originalPrice: 1200,
            discountPercent: 14,
          ),
        ],
        onListingTap: _noopListing,
        onWishlistTap: _noopListing,
      ),
    );
  });

  // ── Booking flow ────────────────────────────────────────────────────

  testWidgets('slot option row fits every viewport', (tester) async {
    await expectNoOverflow(
      tester,
      'SlotOptionRow',
      () => SlotOptionRow(
        slot: const ListingSlot(
          id: 'night',
          name: 'Night Stay',
          timeRange: '5:30 PM - 09 AM',
        ),
        isSelected: true,
        onTap: () {},
      ),
    );
  });

  testWidgets('date range row fits every viewport', (tester) async {
    await expectNoOverflow(
      tester,
      'DateRangeRow',
      () => const DateRangeRow(
        checkIn: '30 July Sun 2026',
        checkOut: '31 July Mon 2026',
      ),
    );
  });

  testWidgets('pax selector fits every viewport', (tester) async {
    await expectNoOverflow(
      tester,
      'PaxSelector',
      () => PaxSelector(value: 30, min: 1, max: 60, onChanged: _noop),
    );
  });

  testWidgets('booking bottom bar fits every viewport', (tester) async {
    await expectNoOverflow(
      tester,
      'BookingBottomBar (wide)',
      () => BookingBottomBar(
        label: 'Check Slot Avaliability',
        leadingIcon: Icons.calendar_month,
        note: 'Free cancellation before 24 hours',
        onPressed: () {},
      ),
    );
  });

  testWidgets('booking bottom bar with price fits every viewport',
      (tester) async {
    await expectNoOverflow(
      tester,
      'BookingBottomBar (price)',
      () => BookingBottomBar(
        label: 'Book now',
        note: 'Free cancellation before 24 hours',
        priceCaption: 'For Day Trip',
        price: '₹1,21,500',
        originalPrice: '₹1,80,000',
        onPriceTap: () {},
        onPressed: () {},
      ),
    );
  });

  // ── Admin panel ─────────────────────────────────────────────────────

  testWidgets('admin nav fits every viewport', (tester) async {
    await expectNoOverflow(
      tester,
      'AdminNav',
      () => AdminNav(currentIndex: 0, onTap: _noop),
    );
  });

  testWidgets('admin stat card fits every viewport', (tester) async {
    await expectNoOverflow(
      tester,
      'AdminStatCard',
      () => const Padding(
        padding: EdgeInsets.symmetric(horizontal: 20),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: AdminStatCard(
                label: 'THIS MONTH TOTAL',
                value: '₹1,24,50,000',
                trendPercent: 12,
              ),
            ),
            SizedBox(width: 16),
            Expanded(
              child: AdminStatCard(
                label: 'YEAR TOTAL',
                value: '₹14,82,00,000',
                caption: '1,248 Bookings',
              ),
            ),
          ],
        ),
      ),
    );
  });

  testWidgets('admin filter chips fit every viewport', (tester) async {
    await expectNoOverflow(
      tester,
      'AdminFilterChips',
      () => AdminFilterChips(
        labels: const ['All', 'House boat', 'Stay', 'Advneture'],
        selectedIndex: 0,
        onSelected: _noop,
      ),
    );
  });

  testWidgets('admin booking card fits every viewport', (tester) async {
    await expectNoOverflow(
      tester,
      'AdminBookingCard',
      () => AdminBookingCard(
        booking: const AdminBooking(
          id: '1',
          title: 'Kerala Backwater Houseboat Deluxe',
          listingName: 'Kerala boat',
          category: 'House Boat',
          amount: 1850000,
          dateRange: 'Sep 12 - Sep 14, 2023',
        ),
        onTap: () {},
      ),
    );
  });

  testWidgets('admin activity card fits every viewport', (tester) async {
    await expectNoOverflow(
      tester,
      'AdminActivityCard',
      () => AdminActivityCard(
        activity: const AdminActivitySubmission(
          id: '1',
          name: 'Adventure Pack',
          category: 'Refreshing room',
          ownerName: 'john ty',
          dateRange: 'Sep 12 - Sep 14, 2023',
        ),
        onTap: () {},
        onReject: () {},
      ),
    );
  });

  testWidgets('payment card fits every viewport', (tester) async {
    await expectNoOverflow(
      tester,
      'PaymentCard',
      () => PaymentCard(
        payment: const PaymentRelease(
          id: '1',
          bookingId: '301928',
          customerName: 'John Smith',
          stage: PaymentStage.completed,
          advanceAmount: 1850000,
          secondAmount: 1850000,
          totalAmount: 3700000,
          date: '20 April',
          timeSlot: '10:00 AM - 4:00 PM',
        ),
        isExpanded: true,
        onToggle: () {},
      ),
    );
  });

  testWidgets('donut chart fits every viewport', (tester) async {
    await expectNoOverflow(
      tester,
      'DonutChart + legend',
      () => const Padding(
        padding: EdgeInsets.all(24),
        child: Wrap(
          spacing: 32,
          runSpacing: 20,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            DonutChart(
              slices: _slices,
              centreValue: '₹4500',
              centreLabel: 'Total',
            ),
            SizedBox(width: 140, child: DonutLegend(slices: _slices)),
          ],
        ),
      ),
    );
  });
}

const _slices = <DonutSlice>[
  DonutSlice(label: 'House Boat', value: 2500, color: Color(0xFF1F7A63)),
  DonutSlice(label: 'Stay', value: 1500, color: Color(0xFF2D9CDB)),
  DonutSlice(label: 'Adventure', value: 500, color: Color(0xFF004A6D)),
];

void _noop(int _) {}

void _noopListing(Listing _) {}
