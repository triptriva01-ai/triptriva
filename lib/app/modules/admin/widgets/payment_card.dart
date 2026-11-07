import 'package:flutter/material.dart';

import '../../../data/models/admin_models.dart';
import '../constants/admin_constants.dart';
import '../controllers/admin_controller.dart';
import 'admin_shell.dart';

/// One payment-release row: who and which booking, a three-stop progress
/// track, the headline amount, and — once expanded — the breakdown.
class PaymentCard extends StatelessWidget {
  const PaymentCard({
    required this.payment,
    required this.isExpanded,
    required this.onToggle,
    super.key,
  });

  final PaymentRelease payment;
  final bool isExpanded;
  final VoidCallback onToggle;

  Color get _stageColor => switch (payment.stage) {
        PaymentStage.pending => AdminPalette.stagePending,
        PaymentStage.advancePaid => AdminPalette.stageAdvance,
        PaymentStage.completed => AdminPalette.stageComplete,
      };

  String get _headlineLabel => switch (payment.stage) {
        PaymentStage.pending => AdminStrings.advancePending,
        PaymentStage.advancePaid => AdminStrings.advancePaid,
        PaymentStage.completed => AdminStrings.fullAmountPaid,
      };

  /// The amount is greyed out until something has actually been paid.
  Color get _headlineColor => payment.stage == PaymentStage.pending
      ? AdminPalette.stageIdle
      : AdminPalette.black;

  double get _headlineAmount => payment.stage == PaymentStage.completed
      ? payment.totalAmount
      : payment.advanceAmount;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          decoration: BoxDecoration(
            gradient: AdminGradients.cardWash,
            border: Border.all(color: AdminPalette.hairline),
            borderRadius: BorderRadius.circular(AdminSizes.sheetRadius),
            boxShadow: const [
              BoxShadow(color: Color(0x40000000), blurRadius: 2),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _CustomerRow(payment: payment),
              const SizedBox(height: 20),
              _ProgressTrack(stage: payment.stage),
              const SizedBox(height: 16),
              _StageChips(payment: payment),
              const SizedBox(height: 16),
              _Headline(
                label: _headlineLabel,
                amount: _headlineAmount,
                color: _headlineColor,
                stageColor: _stageColor,
                canExpand: payment.canExpand,
                isExpanded: isExpanded,
                onToggle: onToggle,
              ),
              if (isExpanded) ...[
                const SizedBox(height: 20),
                _Breakdown(payment: payment),
              ],
            ],
          ),
        ),
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Row(
            children: [
              Text(payment.date, style: AdminStyle.slotMeta),
              const Spacer(),
              Flexible(
                child: Text(
                  payment.timeSlot.toUpperCase(),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AdminStyle.slotMeta,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _CustomerRow extends StatelessWidget {
  const _CustomerRow({required this.payment});

  final PaymentRelease payment;

  @override
  Widget build(BuildContext context) {
    // Wraps so the booking id drops below the name at a large system font
    // instead of overflowing.
    return Wrap(
      alignment: WrapAlignment.spaceBetween,
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: 12,
      runSpacing: 8,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            AdminAvatar(
              imageUrl: payment.customerAvatarUrl,
              size: AdminSizes.smallAvatarSize,
            ),
            const SizedBox(width: 6),
            Text(payment.customerName, style: AdminStyle.personName),
          ],
        ),
        Text(
          '${AdminStrings.bookingIdPrefix}${payment.bookingId}',
          style: AdminStyle.personName,
        ),
      ],
    );
  }
}

/// Three stops joined by a rail; filled up to the stage reached.
class _ProgressTrack extends StatelessWidget {
  const _ProgressTrack({required this.stage});

  final PaymentStage stage;

  Color get _color => switch (stage) {
        PaymentStage.pending => AdminPalette.stagePending,
        PaymentStage.advancePaid => AdminPalette.stageAdvance,
        PaymentStage.completed => AdminPalette.stageComplete,
      };

  @override
  Widget build(BuildContext context) {
    final reached = switch (stage) {
      PaymentStage.pending => 0,
      PaymentStage.advancePaid => 1,
      PaymentStage.completed => 2,
    };

    return Row(
      children: [
        for (var index = 0; index < 3; index++) ...[
          if (index > 0)
            Expanded(
              child: Container(
                height: AdminSizes.progressTrackHeight,
                decoration: BoxDecoration(
                  color: index <= reached
                      ? _color
                      : AdminPalette.hairline,
                  borderRadius: BorderRadius.circular(23),
                ),
              ),
            ),
          Container(
            width: AdminSizes.progressDotSize,
            height: AdminSizes.progressDotSize,
            decoration: BoxDecoration(
              color: index <= reached ? _color : AdminPalette.hairline,
              borderRadius: BorderRadius.circular(60),
            ),
          ),
        ],
      ],
    );
  }
}

/// "pending: · ₹18,500 · ₹18,500" — one chip per stop, greyed until reached.
class _StageChips extends StatelessWidget {
  const _StageChips({required this.payment});

  final PaymentRelease payment;

  @override
  Widget build(BuildContext context) {
    final reached = switch (payment.stage) {
      PaymentStage.pending => 0,
      PaymentStage.advancePaid => 1,
      PaymentStage.completed => 2,
    };

    final active = switch (payment.stage) {
      PaymentStage.pending => AdminPalette.stagePending,
      PaymentStage.advancePaid => AdminPalette.stageAdvance,
      PaymentStage.completed => AdminPalette.stageComplete,
    };

    Color colorFor(int index) =>
        index <= reached ? active : AdminPalette.stageIdle;

    // Wraps so the three chips stack rather than overflowing at 320 dp.
    return Wrap(
      spacing: 16,
      runSpacing: 8,
      children: [
        _chip(
          icon: Icons.schedule,
          label: AdminStrings.pending,
          color: colorFor(0),
        ),
        _chip(
          icon: Icons.payments_outlined,
          label: AdminBaseController.formatRupees(payment.advanceAmount),
          color: colorFor(1),
        ),
        _chip(
          icon: Icons.check_circle,
          label: AdminBaseController.formatRupees(payment.secondAmount),
          color: colorFor(2),
        ),
      ],
    );
  }

  Widget _chip({
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: color),
        const SizedBox(width: 2),
        Text(label, style: AdminStyle.stageChip.copyWith(color: color)),
      ],
    );
  }
}

class _Headline extends StatelessWidget {
  const _Headline({
    required this.label,
    required this.amount,
    required this.color,
    required this.stageColor,
    required this.canExpand,
    required this.isExpanded,
    required this.onToggle,
  });

  final String label;
  final double amount;
  final Color color;
  final Color stageColor;
  final bool canExpand;
  final bool isExpanded;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: canExpand ? onToggle : null,
      child: Row(
        children: [
          Icon(Icons.payments_outlined, size: 14, color: stageColor),
          const SizedBox(width: 6),
          // The label takes the slack so it wraps rather than pushing the
          // amount off the edge.
          Expanded(
            child: Text(
              label,
              style: AdminStyle.stageLabel.copyWith(color: stageColor),
            ),
          ),
          const SizedBox(width: 12),
          // Scaled down rather than ellipsised: a truncated price
          // ("₹37,00…") is worse than a slightly smaller one.
          Flexible(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerRight,
              child: Text(
                AdminBaseController.formatRupees(amount),
                style: AdminStyle.stageAmount.copyWith(color: color),
              ),
            ),
          ),
          if (canExpand) ...[
            const SizedBox(width: 4),
            Icon(
              isExpanded ? Icons.expand_less : Icons.chevron_right,
              size: 18,
              color: AdminPalette.black,
            ),
          ],
        ],
      ),
    );
  }
}

/// Advance / second payment / full amount, shown once the row is expanded.
class _Breakdown extends StatelessWidget {
  const _Breakdown({required this.payment});

  final PaymentRelease payment;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        Center(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: const [
              Icon(Icons.expand_less, size: 18, color: AdminPalette.black),
              SizedBox(width: 12),
              Text(
                AdminStrings.viewLess,
                style: TextStyle(
                  color: AdminPalette.black,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        _row(
          AdminStrings.advancePaid,
          AdminBaseController.formatRupees(payment.advanceAmount),
        ),
        const SizedBox(height: 16),
        _row(
          AdminStrings.secondPayment,
          payment.isCompleted
              ? AdminBaseController.formatRupees(payment.secondAmount)
              : 'Pending',
        ),
        const SizedBox(height: 20),
        const SizedBox(
          height: 1,
          width: double.infinity,
          child: DecoratedBox(
            decoration: BoxDecoration(gradient: AdminGradients.rule),
          ),
        ),
        const SizedBox(height: 20),
        _row(
          AdminStrings.fullAmount,
          AdminBaseController.formatRupees(payment.totalAmount),
          isTotal: true,
        ),
      ],
    );
  }

  Widget _row(String label, String value, {bool isTotal = false}) {
    final style = isTotal ? AdminStyle.billTotal : AdminStyle.billLabel;
    return Row(
      children: [
        Expanded(child: Text(label, style: style)),
        const SizedBox(width: 12),
        Text(value, style: style),
      ],
    );
  }
}
