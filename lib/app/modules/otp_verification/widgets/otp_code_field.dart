import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../constants/otp_constants.dart';
import '../controllers/otp_controller.dart';

/// Six digit boxes driven by one hidden [TextField].
///
/// Using a single field rather than six keeps focus handling, paste, backspace
/// and SMS autofill working the way the platform expects — six separate fields
/// break all four in subtle ways.
class OtpCodeField extends StatefulWidget {
  const OtpCodeField({required this.controller, super.key});

  final OtpController controller;

  @override
  State<OtpCodeField> createState() => _OtpCodeFieldState();
}

class _OtpCodeFieldState extends State<OtpCodeField> {
  final FocusNode _focusNode = FocusNode();
  final TextEditingController _text = TextEditingController();
  late final Worker _clearWorker;

  @override
  void initState() {
    super.initState();
    // The controller clears the code after a wrong attempt.
    _clearWorker = ever<String>(widget.controller.code, (value) {
      if (value.isEmpty && _text.text.isNotEmpty) _text.clear();
    });
    // Open the keyboard as soon as the screen appears.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _clearWorker.dispose();
    _text.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => _focusNode.requestFocus(),
      child: Stack(
        alignment: Alignment.center,
        children: [
          LayoutBuilder(
            builder: (context, constraints) {
              // Full-size boxes when they fit; on a narrow screen the boxes
              // and gaps shrink together so the row never overflows.
              const length = OtpSizes.codeLength;
              const natural =
                  OtpSizes.boxWidth * length + OtpSizes.boxGap * (length - 1);
              final scale = constraints.maxWidth < natural
                  ? constraints.maxWidth / natural
                  : 1.0;
              return Obx(() {
                final value = widget.controller.code.value;
                return Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    for (var index = 0; index < length; index++) ...[
                      if (index > 0) SizedBox(width: OtpSizes.boxGap * scale),
                      _DigitBox(
                        digit: index < value.length ? value[index] : '',
                        isFocused: index == value.length,
                        width: OtpSizes.boxWidth * scale,
                      ),
                    ],
                  ],
                );
              });
            },
          ),
          // The real input, kept invisible behind the boxes.
          SizedBox(
            height: OtpSizes.boxHeight,
            child: Opacity(
              opacity: 0,
              child: TextField(
                controller: _text,
                focusNode: _focusNode,
                onChanged: widget.controller.onCodeChanged,
                keyboardType: TextInputType.number,
                autofillHints: const [AutofillHints.oneTimeCode],
                maxLength: OtpSizes.codeLength,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                showCursor: false,
                decoration: const InputDecoration(
                  counterText: '',
                  border: InputBorder.none,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DigitBox extends StatelessWidget {
  const _DigitBox({
    required this.digit,
    required this.isFocused,
    required this.width,
  });

  final String digit;
  final bool isFocused;
  final double width;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: OtpSizes.boxHeight,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: OtpPalette.white,
        border: Border.all(
          color: isFocused ? OtpPalette.green : OtpPalette.boxBorder,
          width: isFocused ? 2 : 1,
        ),
        borderRadius: BorderRadius.circular(OtpSizes.boxRadius),
      ),
      child: Text(digit, style: OtpStyle.digit),
    );
  }
}
