import 'package:flutter/material.dart';

import '../../../data/models/booking.dart';
import '../constants/reservations_constants.dart';

/// One reservation: thumbnail, booking id, title, party size, and a footer
/// with the date/time and the booking status (FR-01).
class BookingCard extends StatelessWidget {
  const BookingCard({
    required this.booking,
    required this.onTap,
    super.key,
  });

  final Booking booking;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: ReservationsPalette.white,
        border: Border.all(color: ReservationsPalette.border),
        borderRadius: BorderRadius.circular(ReservationsSizes.cardRadius),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(ReservationsSizes.cardRadius),
          child: Padding(
            padding: const EdgeInsets.all(ReservationsSizes.cardPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _Thumbnail(booking: booking),
                    const SizedBox(width: ReservationsSizes.thumbToDetails),
                    Expanded(child: _Details(booking: booking)),
                    const Icon(
                      Icons.chevron_right,
                      size: ReservationsSizes.chevronSize,
                      color: ReservationsPalette.blue,
                    ),
                  ],
                ),
                const SizedBox(height: ReservationsSizes.detailsToFooter),
                _Footer(booking: booking),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Thumbnail extends StatelessWidget {
  const _Thumbnail({required this.booking});

  final Booking booking;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(ReservationsSizes.thumbRadius),
      child: SizedBox.square(
        dimension: ReservationsSizes.thumbSize,
        child: Stack(
          fit: StackFit.expand,
          children: [
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: ReservationsGradients.thumbBase,
              ),
            ),
            ColoredBox(color: ReservationsGradients.thumbVeil),
            if (booking.imageUrl.isNotEmpty)
              Image.network(
                booking.imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) =>
                    const _ThumbnailFallback(),
              )
            else
              const _ThumbnailFallback(),
          ],
        ),
      ),
    );
  }
}

class _ThumbnailFallback extends StatelessWidget {
  const _ThumbnailFallback();

  @override
  Widget build(BuildContext context) {
    // TODO(design): swap for the per-category artwork from the Figma file.
    return const Center(
      child: Icon(
        Icons.card_travel,
        size: ReservationsSizes.thumbIconSize,
        color: ReservationsPalette.thumbGreen,
      ),
    );
  }
}

class _Details extends StatelessWidget {
  const _Details({required this.booking});

  final Booking booking;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          '${ReservationsStrings.bookingIdPrefix}${booking.bookingId}',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: ReservationsStyle.bookingId,
        ),
        const SizedBox(height: ReservationsSizes.detailGap),
        Text(
          booking.title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: ReservationsStyle.bookingTitle,
        ),
        const SizedBox(height: ReservationsSizes.detailGap),
        Row(
          children: [
            const Icon(
              Icons.person,
              size: ReservationsSizes.personIconSize,
              color: ReservationsPalette.black,
            ),
            const SizedBox(width: ReservationsSizes.personToLabel),
            Flexible(
              child: Text(
                ReservationsStrings.people(booking.people),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: ReservationsStyle.people,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _Footer extends StatelessWidget {
  const _Footer({required this.booking});

  final Booking booking;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Flexible(
          child: Text(
            booking.date,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: ReservationsStyle.meta,
          ),
        ),
        const SizedBox(width: ReservationsSizes.metaGap),
        const ColoredBox(
          color: ReservationsPalette.divider,
          child: SizedBox(
            width: ReservationsSizes.metaDividerWidth,
            height: ReservationsSizes.metaDividerHeight,
          ),
        ),
        const SizedBox(width: ReservationsSizes.metaGap),
        Flexible(
          child: Text(
            booking.timeSlot,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: ReservationsStyle.meta,
          ),
        ),
        const SizedBox(width: ReservationsSizes.metaGap),
        const Icon(
          Icons.notifications,
          size: ReservationsSizes.statusIconSize,
          color: ReservationsPalette.bell,
        ),
        const Spacer(),
        _StatusChip(booking: booking),
      ],
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.booking});

  final Booking booking;

  @override
  Widget build(BuildContext context) {
    final completed = booking.isCompleted;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          completed ? Icons.check_circle_outline : Icons.send,
          size: ReservationsSizes.statusIconSize,
          color: completed
              ? ReservationsPalette.completed
              : ReservationsPalette.booked,
        ),
        const SizedBox(width: ReservationsSizes.statusIconToLabel),
        Text(
          completed
              ? ReservationsStrings.tabCompleted
              : ReservationsStrings.tabBooked,
          style: completed
              ? ReservationsStyle.completed
              : ReservationsStyle.booked,
        ),
      ],
    );
  }
}
