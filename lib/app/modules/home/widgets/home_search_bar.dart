import 'package:flutter/material.dart';

import '../constants/home_constants.dart';
import '../controllers/home_controller.dart';

/// FR-03 — search field with voice search.
class HomeSearchBar extends StatelessWidget {
  const HomeSearchBar({required this.controller, super.key});

  final HomeController controller;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: HomeSizes.pagePadding),
      child: Container(
        height: HomeSizes.searchHeight,
        decoration: BoxDecoration(
          color: HomePalette.white,
          border: Border.all(color: HomePalette.border),
          borderRadius: BorderRadius.circular(HomeSizes.searchRadius),
          boxShadow: HomeShadows.search,
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: controller.openSearch,
            borderRadius: BorderRadius.circular(HomeSizes.searchRadius),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: HomeSizes.pagePadding,
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.search,
                    size: HomeSizes.searchIconSize,
                    color: HomePalette.black,
                  ),
                  const SizedBox(width: HomeSizes.searchIconToLabel),
                  const Expanded(
                    child: Text(
                      HomeStrings.searchHint,
                      maxLines: 1,
                      style: HomeStyle.searchHint,
                    ),
                  ),
                  GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: controller.startVoiceSearch,
                    child: const Icon(
                      Icons.mic,
                      size: 20,
                      color: HomePalette.black,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
