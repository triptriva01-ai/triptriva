import 'package:flutter/material.dart';

import '../constants/home_constants.dart';
import '../controllers/home_controller.dart';

/// FR-01 (logo) and FR-02 (notification bell).
class HomeAppBar extends StatelessWidget {
  const HomeAppBar({required this.controller, super.key});

  final HomeController controller;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: HomeSizes.pagePadding),
      child: Row(
        children: [
          Expanded(
            child: ShaderMask(
              blendMode: BlendMode.srcIn,
              shaderCallback: HomeGradients.prime.createShader,
              child: const Text.rich(
                TextSpan(
                  style: HomeStyle.logo,
                  children: [
                    TextSpan(text: HomeStrings.logoLight),
                    TextSpan(
                      text: HomeStrings.logoBold,
                      style: TextStyle(fontWeight: FontWeight.w900),
                    ),
                  ],
                ),
                maxLines: 1,
              ),
            ),
          ),
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: controller.openNotifications,
            child: const Icon(
              Icons.notifications,
              size: HomeSizes.bellSize,
              color: HomePalette.black,
            ),
          ),
        ],
      ),
    );
  }
}
