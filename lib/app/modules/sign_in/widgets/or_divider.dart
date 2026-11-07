import 'package:flutter/material.dart';

import '../constants/sign_in_constants.dart';

/// Hairline rule broken by a centred "or" label.
class OrDivider extends StatelessWidget {
  const OrDivider({super.key});

  @override
  Widget build(BuildContext context) {
    return const Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(child: _Rule()),
        Padding(
          padding: EdgeInsets.symmetric(
            horizontal: SignInSizes.dividerLabelPadding,
          ),
          child: Text(SignInStrings.orLabel, style: SignInStyle.orLabel),
        ),
        Expanded(child: _Rule()),
      ],
    );
  }
}

class _Rule extends StatelessWidget {
  const _Rule();

  @override
  Widget build(BuildContext context) {
    return const ColoredBox(
      color: SignInPalette.divider,
      child: SizedBox(
        width: double.infinity,
        height: SignInSizes.dividerThickness,
      ),
    );
  }
}
