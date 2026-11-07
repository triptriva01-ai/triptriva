import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../constants/otp_constants.dart';
import '../controllers/otp_controller.dart';
import '../widgets/otp_code_field.dart';

/// One-time code verification, reached from the sign-in screen.
class OtpView extends GetView<OtpController> {
  const OtpView({super.key});

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark.copyWith(
        statusBarColor: Colors.transparent,
        systemNavigationBarColor: OtpPalette.white,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: OtpPalette.white,
        body: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: OtpSizes.pagePadding,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _BackButton(controller: controller),
                        SizedBox(
                          height:
                              constraints.maxHeight * OtpSizes.topSpacingFactor,
                        ),
                        const Text(OtpStrings.title, style: OtpStyle.title),
                        const SizedBox(height: OtpSizes.titleToSubtitle),
                        Text(
                          '${OtpStrings.subtitlePrefix} ${controller.identifier}',
                          style: OtpStyle.subtitle,
                        ),
                        const SizedBox(height: OtpSizes.subtitleToBoxes),
                        OtpCodeField(controller: controller),
                        const SizedBox(height: OtpSizes.boxesToButton),
                        _VerifyButton(controller: controller),
                        const SizedBox(height: OtpSizes.buttonToResend),
                        _ResendRow(controller: controller),
                        const _DevCodeHint(),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _BackButton extends StatelessWidget {
  const _BackButton({required this.controller});

  final OtpController controller;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: controller.goBack,
        child: const Padding(
          padding: EdgeInsets.symmetric(vertical: OtpSizes.headerToBody / 2),
          child: Icon(
            Icons.arrow_back,
            size: OtpSizes.backIconSize,
            color: OtpPalette.black,
          ),
        ),
      ),
    );
  }
}

class _VerifyButton extends StatelessWidget {
  const _VerifyButton({required this.controller});

  final OtpController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final enabled = controller.canVerify && !controller.isVerifying.value;

      return Opacity(
        opacity: enabled ? 1 : 0.5,
        child: DecoratedBox(
          decoration: BoxDecoration(
            gradient: OtpGradients.prime,
            borderRadius: BorderRadius.circular(OtpSizes.buttonRadius),
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: enabled ? controller.verify : null,
              borderRadius: BorderRadius.circular(OtpSizes.buttonRadius),
              child: SizedBox(
                height: OtpSizes.buttonHeight,
                child: Center(
                  child: controller.isVerifying.value
                      ? const SizedBox.square(
                          dimension: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: OtpPalette.white,
                          ),
                        )
                      : const Text(
                          OtpStrings.verifyButton,
                          style: OtpStyle.button,
                        ),
                ),
              ),
            ),
          ),
        ),
      );
    });
  }
}

class _ResendRow extends StatelessWidget {
  const _ResendRow({required this.controller});

  final OtpController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final seconds = controller.secondsUntilResend.value;

      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(OtpStrings.resendPrompt, style: OtpStyle.resend),
          if (seconds > 0)
            Text(OtpStrings.resendIn(seconds), style: OtpStyle.resend)
          else
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: controller.resend,
              child: const Text(
                OtpStrings.resendAction,
                style: OtpStyle.resendAction,
              ),
            ),
        ],
      );
    });
  }
}

/// Visible only while the server is configured to return codes for local
/// testing, so the flow can be exercised without an SMS provider.
class _DevCodeHint extends StatelessWidget {
  const _DevCodeHint();

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<OtpController>();

    return Obx(() {
      final code = controller.devCode.value;
      if (code == null || code.isEmpty) {
        return const SizedBox.shrink();
      }

      return Padding(
        padding: const EdgeInsets.only(top: OtpSizes.titleToSubtitle),
        child: Text(
          OtpStrings.devCode(code),
          textAlign: TextAlign.center,
          style: OtpStyle.devCode,
        ),
      );
    });
  }
}
