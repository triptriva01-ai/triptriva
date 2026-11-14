import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../../data/models/booking_detail.dart';
import '../constants/booking_detail_constants.dart';
import '../controllers/booking_detail_controller.dart';
import '../widgets/about_section.dart';
import '../widgets/booking_summary_card.dart';
import '../widgets/detail_card.dart';
import '../widgets/total_price_card.dart';

/// Booking detail — the "reservation inside" page.
///
/// Same layout for an upcoming and a completed trip; the status headline, the
/// reminder chip and the review prompt are what differ.
class BookingDetailView extends GetView<BookingDetailController> {
  const BookingDetailView({super.key});

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark.copyWith(
        statusBarColor: Colors.transparent,
        systemNavigationBarColor: BookingDetailPalette.white,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: BookingDetailPalette.white,
        body: Obx(() {
          final detail = controller.detail.value;

          if (detail == null) {
            return _PlaceholderState(controller: controller);
          }

          return Stack(
            children: [
              // Brand wash behind the top of the page, fading into white.
              const Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: SizedBox(
                  height: BookingDetailSizes.headerWashHeight,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: BookingDetailGradients.headerWash,
                    ),
                  ),
                ),
              ),
              SafeArea(
                child: RefreshIndicator(
                  onRefresh: controller.loadDetail,
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(
                      BookingDetailSizes.pagePadding,
                      12,
                      BookingDetailSizes.pagePadding,
                      40,
                    ),
                    children: [
                      _Header(detail: detail, controller: controller),
                      const SizedBox(height: 30),
                      _BookingIdRow(detail: detail, controller: controller),
                      if (detail.canReview) ...[
                        const SizedBox(height: BookingDetailSizes.cardGap),
                        _ReviewPrompt(controller: controller),
                      ],
                      const SizedBox(height: BookingDetailSizes.cardGap),
                      BookingSummaryCard(
                        detail: detail,
                        controller: controller,
                      ),
                      if (detail.total > 0) ...[
                        const SizedBox(height: BookingDetailSizes.cardGap),
                        TotalPriceCard(detail: detail),
                      ],
                      if (detail.facilities.isNotEmpty) ...[
                        const SizedBox(height: BookingDetailSizes.cardGap),
                        _BulletCard(
                          title: BookingDetailStrings.facilities,
                          items: detail.facilities,
                        ),
                      ],
                      if (detail.policies.isNotEmpty) ...[
                        const SizedBox(height: BookingDetailSizes.cardGap),
                        _BulletCard(
                          title: BookingDetailStrings.policies,
                          items: detail.policies,
                        ),
                      ],
                      if (detail.related != null) ...[
                        const SizedBox(height: BookingDetailSizes.cardGap),
                        RelatedListingCard(
                          listing: detail.related!,
                          onTap: controller.openListing,
                        ),
                      ],
                      if (detail.about.isNotEmpty) ...[
                        const SizedBox(height: BookingDetailSizes.cardGap),
                        AboutSection(
                          about: detail.about,
                          controller: controller,
                        ),
                      ],
                      if (detail.canCancel) ...[
                        const SizedBox(height: BookingDetailSizes.cardGap),
                        Center(
                          child: TextButton(
                            onPressed: controller.cancelBooking,
                            style: TextButton.styleFrom(
                              foregroundColor: Colors.red,
                            ),
                            child: const Text(
                              BookingDetailStrings.cancelBooking,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          );
        }),
      ),
    );
  }
}

/// Back button, status headline, reminder chip and the supporting line.
class _Header extends StatelessWidget {
  const _Header({required this.detail, required this.controller});

  final BookingDetail detail;
  final BookingDetailController controller;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: controller.goBack,
          child: Container(
            width: BookingDetailSizes.backButtonSize,
            height: BookingDetailSizes.backButtonSize,
            decoration: BoxDecoration(
              color: BookingDetailPalette.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: BookingDetailPalette.black.withValues(alpha: 0.25),
                  blurRadius: 10,
                ),
              ],
            ),
            child: const Icon(
              Icons.arrow_back_ios_new,
              size: BookingDetailSizes.backIconSize,
              color: BookingDetailPalette.black,
            ),
          ),
        ),
        const SizedBox(height: 30),
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: ShaderMask(
                blendMode: BlendMode.srcIn,
                shaderCallback: BookingDetailGradients.prime.createShader,
                child: Text(
                  detail.isCompleted
                      ? BookingDetailStrings.statusCompleted
                      : BookingDetailStrings.statusBooked,
                  style: BookingDetailStyle.status,
                ),
              ),
            ),
            if (detail.canRemind) _ReminderChip(controller: controller),
          ],
        ),
        const SizedBox(height: 16),
        const Text(
          BookingDetailStrings.subtitle,
          style: BookingDetailStyle.subtitle,
        ),
      ],
    );
  }
}

class _ReminderChip extends StatelessWidget {
  const _ReminderChip({required this.controller});

  final BookingDetailController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: controller.toggleReminder,
        child: Container(
          constraints: const BoxConstraints(minHeight: 36),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(20)),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                BookingDetailStrings.reminder,
                style: BookingDetailStyle.reminder,
              ),
              const SizedBox(width: 6),
              Icon(
                controller.hasReminder.value
                    ? Icons.notifications_active
                    : Icons.notifications_none,
                size: 16,
                color: BookingDetailPalette.black,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// "Booking ID : XXX" with a copy action, ruled above and below.
class _BookingIdRow extends StatelessWidget {
  const _BookingIdRow({required this.detail, required this.controller});

  final BookingDetail detail;
  final BookingDetailController controller;

  @override
  Widget build(BuildContext context) {
    // A completed trip's ID is no longer actionable, so the copy affordance
    // is greyed out to match the design.
    final copyColour = detail.isCompleted
        ? BookingDetailPalette.inactiveCopy
        : BookingDetailPalette.blue;

    return Column(
      children: [
        const Divider(color: BookingDetailPalette.rule, thickness: 2, height: 2),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  '${BookingDetailStrings.bookingIdPrefix}${detail.bookingId}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: BookingDetailStyle.bookingId,
                ),
              ),
              const SizedBox(width: 12),
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: controller.copyBookingId,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.copy_outlined, size: 14, color: copyColour),
                    const SizedBox(width: 10),
                    Text(
                      BookingDetailStrings.copy,
                      style: BookingDetailStyle.bookingId.copyWith(
                        color: copyColour,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const Divider(color: BookingDetailPalette.rule, thickness: 2, height: 2),
        if (detail.checkInCode.isNotEmpty) ...[
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Row(
              children: [
                const Expanded(
                  child: Text(
                    BookingDetailStrings.checkInCodePrefix,
                    style: BookingDetailStyle.bookingId,
                  ),
                ),
                Text(
                  detail.checkInCode,
                  style: BookingDetailStyle.bookingId.copyWith(
                    fontWeight: FontWeight.w700,
                    letterSpacing: 4,
                  ),
                ),
              ],
            ),
          ),
          const Divider(
            color: BookingDetailPalette.rule,
            thickness: 2,
            height: 2,
          ),
        ],
      ],
    );
  }
}

/// Shown once a trip is finished and has no review yet.
class _ReviewPrompt extends StatelessWidget {
  const _ReviewPrompt({required this.controller});

  final BookingDetailController controller;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          BookingDetailStrings.reviewPrompt,
          style: BookingDetailStyle.bookingId,
        ),
        const SizedBox(height: 16),
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: controller.writeReview,
          child: Container(
            constraints: const BoxConstraints(minHeight: 43),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            decoration: BoxDecoration(
              gradient: BookingDetailGradients.prime,
              borderRadius: BorderRadius.circular(30),
            ),
            child: const Text(
              BookingDetailStrings.writeReview,
              style: TextStyle(
                color: BookingDetailPalette.white,
                fontSize: 16,
                height: 1.19,
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        const Divider(color: BookingDetailPalette.rule, thickness: 2, height: 2),
      ],
    );
  }
}

class _BulletCard extends StatelessWidget {
  const _BulletCard({required this.title, required this.items});

  final String title;
  final List<String> items;

  @override
  Widget build(BuildContext context) {
    return DetailCard(
      title: title,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          for (var index = 0; index < items.length; index++) ...[
            if (index > 0)
              const SizedBox(height: BookingDetailSizes.bulletGap),
            BulletRow(label: items[index]),
          ],
        ],
      ),
    );
  }
}

/// Loading spinner, or the failure message when there is nothing to show.
class _PlaceholderState extends StatelessWidget {
  const _PlaceholderState({required this.controller});

  final BookingDetailController controller;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(BookingDetailSizes.pagePadding),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  controller.errorMessage.value.isEmpty
                      ? 'This booking could not be found.'
                      : controller.errorMessage.value,
                  textAlign: TextAlign.center,
                  style: BookingDetailStyle.subtitle,
                ),
                const SizedBox(height: 20),
                TextButton(
                  onPressed: controller.loadDetail,
                  child: const Text('Try again'),
                ),
                TextButton(
                  onPressed: controller.goBack,
                  child: const Text('Go back'),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }
}
