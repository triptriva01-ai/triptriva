import 'package:flutter/material.dart';

import '../../../widgets/partner/partner_theme.dart';

/// Copy for the four headline steps, shown on the welcome overview and again
/// as a full-bleed card when each step begins.
class OnboardingStepCopy {
  const OnboardingStepCopy({
    required this.title,
    required this.description,
    required this.icon,
  });

  final String title;
  final String description;
  final IconData icon;

  static const all = [
    OnboardingStepCopy(
      title: '1. Tell us about your place',
      description:
          'Share some basic info, like where it is and how many guests can stay.',
      icon: Icons.holiday_village_outlined,
    ),
    OnboardingStepCopy(
      title: '2. Make it stand out',
      description:
          "Add at least 5 photos plus a title and description—we'll help you out.",
      icon: Icons.photo_library_outlined,
    ),
    OnboardingStepCopy(
      title: '3. Pricing and booking type',
      description: 'Choose a starting price, before publish your list.',
      icon: Icons.sell_outlined,
    ),
    OnboardingStepCopy(
      title: '4. Finish up and publish',
      description:
          'Verify a your details & documents, then publish your listing.',
      icon: Icons.verified_outlined,
    ),
  ];
}

/// The "Welcome!" overview listing all four steps before the partner starts.
class OnboardingWelcomeStep extends StatelessWidget {
  const OnboardingWelcomeStep({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Welcome!',
          style: TextStyle(
            color: PartnerPalette.black,
            fontSize: 32,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          "It's easy to use. Just follow these three simple steps to publish "
          'your place.',
          textAlign: TextAlign.center,
          style: PartnerStyle.wizardSubtitle,
        ),
        const SizedBox(height: 30),
        for (var index = 0; index < OnboardingStepCopy.all.length; index++) ...[
          Text(
            'Step ${index + 1}',
            style: const TextStyle(
              color: Color(0xFF191C1D),
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          _StepSummaryCard(copy: OnboardingStepCopy.all[index]),
          if (index != OnboardingStepCopy.all.length - 1) ...[
            const SizedBox(height: 20),
            const Divider(color: PartnerPalette.hairline, height: 1),
            const SizedBox(height: 20),
          ],
        ],
      ],
    );
  }
}

class _StepSummaryCard extends StatelessWidget {
  const _StepSummaryCard({required this.copy});

  final OnboardingStepCopy copy;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: PartnerPalette.white,
        border: Border.all(color: const Color(0xFFF0FDFA)),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF147D7D).withValues(alpha: 0.03),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(copy.icon, size: 48, color: PartnerPalette.headerGreen),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  copy.title,
                  style: const TextStyle(
                    color: Color(0xFF191C1D),
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  copy.description,
                  style: const TextStyle(
                    color: Color(0xFF4E635E),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0.24,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Full-card introduction shown when each headline step begins.
class OnboardingIntroStep extends StatelessWidget {
  const OnboardingIntroStep({required this.stepIndex, super.key});

  /// Zero-based index into [OnboardingStepCopy.all].
  final int stepIndex;

  @override
  Widget build(BuildContext context) {
    final copy = OnboardingStepCopy.all[stepIndex];

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 40),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: PartnerPalette.white,
          border: Border.all(color: const Color(0xFFF0FDFA)),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF147D7D).withValues(alpha: 0.03),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(copy.icon, size: 150, color: PartnerPalette.headerGreen),
            const SizedBox(height: 24),
            Text(
              copy.title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Color(0xFF191C1D),
                fontSize: 26,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              copy.description,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Color(0xFF4E635E),
                fontSize: 16,
                fontWeight: FontWeight.w500,
                letterSpacing: 0.24,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Centred heading + optional subtitle used at the top of every form step.
class OnboardingStepHeading extends StatelessWidget {
  const OnboardingStepHeading({
    required this.title,
    this.subtitle,
    this.alignment = CrossAxisAlignment.center,
    super.key,
  });

  final String title;
  final String? subtitle;
  final CrossAxisAlignment alignment;

  @override
  Widget build(BuildContext context) {
    final centred = alignment == CrossAxisAlignment.center;

    return Column(
      crossAxisAlignment: alignment,
      children: [
        Text(
          title,
          textAlign: centred ? TextAlign.center : TextAlign.start,
          style: PartnerStyle.wizardTitle,
        ),
        if (subtitle != null) ...[
          const SizedBox(height: 10),
          Text(
            subtitle!,
            textAlign: centred ? TextAlign.center : TextAlign.start,
            style: PartnerStyle.wizardSubtitle,
          ),
        ],
        const SizedBox(height: 30),
      ],
    );
  }
}
