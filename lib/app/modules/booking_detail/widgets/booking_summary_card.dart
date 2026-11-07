import 'package:flutter/material.dart';

import '../../../data/models/booking_detail.dart';
import '../constants/booking_detail_constants.dart';
import '../controllers/booking_detail_controller.dart';
import 'detail_card.dart';

/// "Booking Details" — the main card: listing, partner contact, date and slot,
/// stay composition and the invoice link.
class BookingSummaryCard extends StatelessWidget {
  const BookingSummaryCard({
    required this.detail,
    required this.controller,
    super.key,
  });

  final BookingDetail detail;
  final BookingDetailController controller;

  @override
  Widget build(BuildContext context) {
    return DetailCard(
      title: BookingDetailStrings.bookingDetails,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          _ListingRow(detail: detail, controller: controller),
          if (detail.partnerName.isNotEmpty) ...[
            const _Gap(),
            _CallRow(detail: detail, controller: controller),
          ],
          if (detail.bookingDate.isNotEmpty) ...[
            const _Gap(),
            _DateBlock(detail: detail),
          ],
          if (!detail.stay.isEmpty) ...[
            const _Gap(),
            _StayBlock(stay: detail.stay),
          ],
          const _Gap(),
          DetailLinkRow(
            icon: Icons.download_outlined,
            label: BookingDetailStrings.downloadInvoice,
            onTap: controller.downloadInvoice,
          ),
        ],
      ),
    );
  }
}

/// Rule with the standard spacing either side.
class _Gap extends StatelessWidget {
  const _Gap();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: BookingDetailSizes.sectionGap),
      child: FadingRule(),
    );
  }
}

class _ListingRow extends StatelessWidget {
  const _ListingRow({required this.detail, required this.controller});

  final BookingDetail detail;
  final BookingDetailController controller;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(detail.listingName, style: BookingDetailStyle.listingName),
              if (detail.address.isNotEmpty) ...[
                const SizedBox(height: 20),
                Text(detail.address, style: BookingDetailStyle.address),
              ],
              const SizedBox(height: 23),
              DetailLinkRow(
                icon: Icons.near_me_outlined,
                label: BookingDetailStrings.getDirection,
                onTap: controller.openDirections,
              ),
            ],
          ),
        ),
        const SizedBox(width: 16),
        DetailThumbnail(
          imageUrl: detail.imageUrl,
          size: BookingDetailSizes.thumbLarge,
        ),
      ],
    );
  }
}

class _CallRow extends StatelessWidget {
  const _CallRow({required this.detail, required this.controller});

  final BookingDetail detail;
  final BookingDetailController controller;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: controller.callPartner,
      child: Row(
        children: [
          Container(
            width: 30,
            height: 30,
            decoration: const BoxDecoration(
              color: BookingDetailPalette.greenDark,
              shape: BoxShape.circle,
            ),
            // The Figma export washes the green disc back with 80% white.
            foregroundDecoration: BoxDecoration(
              color: BookingDetailPalette.white.withValues(alpha: 0.8),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.call,
              size: 14,
              color: BookingDetailPalette.greenDark,
            ),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              BookingDetailStrings.call(detail.partnerName),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: BookingDetailStyle.callLabel,
            ),
          ),
        ],
      ),
    );
  }
}

class _DateBlock extends StatelessWidget {
  const _DateBlock({required this.detail});

  final BookingDetail detail;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text(
          BookingDetailStrings.bookingDate,
          style: BookingDetailStyle.sectionLabel,
        ),
        const SizedBox(height: 20),
        _DateSlot(date: detail.bookingDate, type: detail.tripType, slot: detail.timeSlot),
        // Multi-day stays show a second date, with a return arrow between.
        if (detail.checkOutDate.isNotEmpty) ...[
          const SizedBox(height: 20),
          _DateSlot(
            date: detail.checkOutDate,
            type: detail.tripType,
            slot: detail.checkOutTimeSlot,
          ),
        ],
      ],
    );
  }
}

class _DateSlot extends StatelessWidget {
  const _DateSlot({required this.date, required this.type, required this.slot});

  final String date;
  final String type;
  final String slot;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(date, style: BookingDetailStyle.date),
        const SizedBox(height: 12),
        // Wrap so the type and slot stack on a narrow screen rather than
        // overflowing the row.
        Wrap(
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: 20,
          runSpacing: 8,
          children: [
            if (type.isNotEmpty)
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(type, style: BookingDetailStyle.slot),
                  if (slot.isNotEmpty) ...[
                    const SizedBox(width: 30),
                    Container(
                      width: 1,
                      height: 30,
                      color: BookingDetailPalette.black,
                    ),
                  ],
                ],
              ),
            if (slot.isNotEmpty) Text(slot, style: BookingDetailStyle.slot),
          ],
        ),
      ],
    );
  }
}

class _StayBlock extends StatelessWidget {
  const _StayBlock({required this.stay});

  final StayDetails stay;

  @override
  Widget build(BuildContext context) {
    final labels = stay.labels;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text(
          BookingDetailStrings.stayDetails,
          style: BookingDetailStyle.sectionLabel,
        ),
        const SizedBox(height: 20),
        Wrap(
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: 16,
          runSpacing: 8,
          children: [
            for (var index = 0; index < labels.length; index++) ...[
              if (index > 0)
                const SizedBox(
                  width: BookingDetailSizes.bulletSize,
                  height: BookingDetailSizes.bulletSize,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: BookingDetailPalette.black,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              Text(labels[index], style: BookingDetailStyle.stayMeta),
            ],
          ],
        ),
      ],
    );
  }
}
