import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../constants/admin_constants.dart';
import 'admin_nav.dart';

/// The page frame every admin screen sits in: tinted background, gradient
/// title, and the shared bottom navigation.
class AdminShell extends StatelessWidget {
  const AdminShell({
    required this.title,
    required this.currentIndex,
    required this.onTabSelected,
    required this.child,
    this.header,
    this.wash = false,
    super.key,
  });

  final String title;
  final int currentIndex;
  final ValueChanged<int> onTabSelected;

  /// Scrollable page body.
  final Widget child;

  /// Extra row under the title, e.g. the Accepted / Pending tabs.
  final Widget? header;

  /// Mint wash behind the header, used by the Revenue dashboard.
  final bool wash;

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark.copyWith(
        statusBarColor: Colors.transparent,
        systemNavigationBarColor: AdminPalette.white,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: AdminPalette.page,
        body: SafeArea(
          bottom: false,
          child: Column(
            children: [
              Container(
                width: double.infinity,
                decoration: wash
                    ? const BoxDecoration(
                        gradient: AdminGradients.headerWash,
                        borderRadius: BorderRadius.vertical(
                          bottom: Radius.circular(AdminSizes.headerRadius),
                        ),
                      )
                    : null,
                padding: const EdgeInsets.fromLTRB(
                  AdminSizes.pagePadding,
                  24,
                  AdminSizes.pagePadding,
                  AdminSizes.headerBottom,
                ),
                child: Column(
                  children: [
                    ShaderMask(
                      blendMode: BlendMode.srcIn,
                      shaderCallback: AdminGradients.prime.createShader,
                      child: Text(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                        style: AdminStyle.pageTitle,
                      ),
                    ),
                    if (header != null) ...[
                      const SizedBox(height: 16),
                      header!,
                    ],
                  ],
                ),
              ),
              Expanded(child: child),
            ],
          ),
        ),
        bottomNavigationBar: AdminNav(
          currentIndex: currentIndex,
          onTap: onTabSelected,
        ),
      ),
    );
  }
}

/// The white, rounded card the admin sections sit on.
class AdminCard extends StatelessWidget {
  const AdminCard({
    required this.child,
    this.padding = AdminSizes.cardPadding,
    super.key,
  });

  final Widget child;
  final double padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(padding),
      decoration: BoxDecoration(
        color: AdminPalette.white,
        border: Border.all(color: AdminPalette.softBorder),
        borderRadius: BorderRadius.circular(AdminSizes.cardRadius),
        boxShadow: const [
          BoxShadow(color: Color(0x0D000000), blurRadius: 2, offset: Offset(0, 1)),
        ],
      ),
      child: child,
    );
  }
}

/// A bold section heading, e.g. "Income Categories".
class AdminSectionTitle extends StatelessWidget {
  const AdminSectionTitle(this.label, {this.trailing, super.key});

  final String label;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AdminStyle.sectionTitle,
            ),
          ),
          ?trailing,
        ],
      ),
    );
  }
}

/// Horizontal filter pills; the active one carries the brand gradient.
class AdminFilterChips extends StatelessWidget {
  const AdminFilterChips({
    required this.labels,
    required this.selectedIndex,
    required this.onSelected,
    super.key,
  });

  final List<String> labels;
  final int selectedIndex;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    // A horizontal scroller needs a bounded cross-axis size, so the chips
    // live in a Row inside a scroll view rather than a ListView.
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          for (var index = 0; index < labels.length; index++) ...[
            if (index > 0) const SizedBox(width: AdminSizes.chipGap),
            _Chip(
              label: labels[index],
              isActive: index == selectedIndex,
              onTap: () => onSelected(index),
            ),
          ],
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  final String label;
  final bool isActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final text = Text(
      label,
      maxLines: 1,
      style: isActive ? AdminStyle.chipActive : AdminStyle.chip,
    );

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        // A minimum, not a cap.
        constraints: const BoxConstraints(minHeight: AdminSizes.chipHeight),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AdminSizes.chipRadius),
        ),
        child: isActive
            ? ShaderMask(
                blendMode: BlendMode.srcIn,
                shaderCallback: AdminGradients.prime.createShader,
                child: text,
              )
            : text,
      ),
    );
  }
}

/// Round photo with a neutral placeholder, used for people and listings.
class AdminAvatar extends StatelessWidget {
  const AdminAvatar({
    required this.imageUrl,
    required this.size,
    this.radius,
    super.key,
  });

  final String imageUrl;
  final double size;

  /// Corner radius; defaults to a circle.
  final double? radius;

  @override
  Widget build(BuildContext context) {
    const placeholder = ColoredBox(
      color: AdminPalette.hairline,
      child: Icon(Icons.person, color: AdminPalette.white, size: 18),
    );

    return ClipRRect(
      borderRadius: BorderRadius.circular(radius ?? size),
      child: SizedBox(
        width: size,
        height: size,
        child: imageUrl.isEmpty
            ? placeholder
            : Image.network(
                imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => placeholder,
              ),
      ),
    );
  }
}
