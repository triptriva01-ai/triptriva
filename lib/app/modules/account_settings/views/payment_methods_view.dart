import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../../widgets/partner/partner_primary_button.dart';
import '../../../widgets/partner/partner_theme.dart';
import '../constants/account_settings_constants.dart';
import '../controllers/account_settings_controllers.dart';
import '../widgets/settings_widgets.dart';

const _panelGrey = Color(0xFFE4E4E4);

/// Payment Method — UPI apps and IDs, plus saved debit/credit cards.
class PaymentMethodsView extends GetView<PaymentMethodsController> {
  const PaymentMethodsView({super.key});

  @override
  Widget build(BuildContext context) {
    return SettingsPage(
      title: AccountSettingsStrings.paymentTitle,
      onBack: controller.goBack,
      child: Obx(() {
        if (controller.isLoading.value && controller.methods.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }
        return RefreshIndicator(
          onRefresh: controller.load,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(
              PartnerSizes.pagePadding,
              0,
              PartnerSizes.pagePadding,
              40,
            ),
            children: [
              _UpiSection(controller: controller),
              const SizedBox(height: 16),
              _CardSection(controller: controller),
            ],
          ),
        );
      }),
    );
  }
}

/// Grey outlined panel with a tappable header; the body shows when expanded.
class _Panel extends StatelessWidget {
  const _Panel({
    required this.icon,
    required this.title,
    required this.caption,
    required this.expanded,
    required this.onToggle,
    required this.body,
    this.collapsedTrailing,
  });

  final IconData icon;
  final String title;
  final String caption;
  final bool expanded;
  final VoidCallback onToggle;
  final Widget body;

  /// Replaces the chevron while collapsed, e.g. the card "ADD" link.
  final Widget? collapsedTrailing;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(22, 4, 22, 4),
      decoration: BoxDecoration(
        color: expanded ? _panelGrey : PartnerPalette.white,
        border: Border.all(color: PartnerPalette.border),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          InkWell(
            onTap: onToggle,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Row(
                children: [
                  Icon(icon, size: 26, color: PartnerPalette.black),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(title, style: settingsTileTitle),
                        const SizedBox(height: 6),
                        Text(caption, style: settingsTileCaption),
                      ],
                    ),
                  ),
                  if (!expanded && collapsedTrailing != null)
                    collapsedTrailing!
                  else
                    Icon(
                      expanded ? Icons.expand_less : Icons.expand_more,
                      color: PartnerPalette.border,
                    ),
                ],
              ),
            ),
          ),
          if (expanded) ...[body, const SizedBox(height: 18)],
        ],
      ),
    );
  }
}

class _WhiteCard extends StatelessWidget {
  const _WhiteCard({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
        color: PartnerPalette.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: child,
    );
  }
}

// ─────────────────────────────── UPI ───────────────────────────────

class _UpiSection extends StatelessWidget {
  const _UpiSection({required this.controller});

  final PaymentMethodsController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => _Panel(
        icon: Icons.account_balance_wallet_outlined,
        title: AccountSettingsStrings.upiTitle,
        caption: AccountSettingsStrings.upiCaption,
        expanded: controller.upiExpanded.value,
        onToggle: controller.toggleUpi,
        body: _WhiteCard(
          child: Column(
            children: [
              for (final app in PaymentMethodsController.upiApps)
                _ChoiceRow(
                  label: app.label,
                  selected: controller.walletFor(app.provider)?.isDefault ??
                      false,
                  busy: controller.busyId.value ==
                      (controller.walletFor(app.provider)?.id ?? app.provider),
                  onTap: () => controller.chooseUpiApp(app),
                  trailing: _AppMark(provider: app.provider),
                ),
              for (final upi in controller.upiIds)
                _ChoiceRow(
                  label: upi.displayName,
                  selected: upi.isDefault,
                  busy: controller.busyId.value == upi.id,
                  onTap: () => controller.makeDefault(upi),
                  trailing: _RemoveButton(
                    onTap: () => _confirmRemove(controller, upi),
                  ),
                ),
              InkWell(
                onTap: () => _askUpiId(controller),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 10, 20, 4),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              AccountSettingsStrings.addOtherUpi,
                              style: settingsTileTitle.copyWith(
                                color: PartnerPalette.blue,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              AccountSettingsStrings.addOtherUpiCaption,
                              style: settingsTileCaption.copyWith(
                                color: PartnerPalette.blue,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Obx(
                        () => controller.busyId.value == 'upi'
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Icon(
                                Icons.chevron_right,
                                color: PartnerPalette.blue,
                              ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ChoiceRow extends StatelessWidget {
  const _ChoiceRow({
    required this.label,
    required this.selected,
    required this.busy,
    required this.onTap,
    this.trailing,
  });

  final String label;
  final bool selected;
  final bool busy;
  final VoidCallback onTap;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Row(
          children: [
            SettingsRadio(selected: selected, busy: busy),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: settingsTileTitle,
              ),
            ),
            ?trailing,
          ],
        ),
      ),
    );
  }
}

/// A coloured initial standing in for each UPI app's logo.
class _AppMark extends StatelessWidget {
  const _AppMark({required this.provider});

  final String provider;

  @override
  Widget build(BuildContext context) {
    final (letter, color) = switch (provider) {
      'google_pay' => ('G', const Color(0xFF4285F4)),
      'phonepe' => ('Pe', const Color(0xFF5F259F)),
      _ => ('P', const Color(0xFF00BAF2)),
    };
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      alignment: Alignment.center,
      child: Text(
        letter,
        style: const TextStyle(
          color: PartnerPalette.white,
          fontSize: 13,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _RemoveButton extends StatelessWidget {
  const _RemoveButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: AccountSettingsStrings.remove,
      visualDensity: VisualDensity.compact,
      onPressed: onTap,
      icon: const Icon(
        Icons.delete_outline,
        size: 20,
        color: PartnerPalette.mutedStrong,
      ),
    );
  }
}

Future<void> _askUpiId(PaymentMethodsController controller) async {
  final input = TextEditingController();
  await Get.dialog<void>(
    AlertDialog(
      title: const Text(AccountSettingsStrings.upiIdTitle),
      content: TextField(
        controller: input,
        autofocus: true,
        keyboardType: TextInputType.emailAddress,
        decoration: const InputDecoration(
          hintText: AccountSettingsStrings.upiIdHint,
        ),
        onSubmitted: controller.addUpiId,
      ),
      actions: [
        TextButton(
          onPressed: Get.back,
          child: const Text(AccountSettingsStrings.cancel),
        ),
        TextButton(
          onPressed: () => controller.addUpiId(input.text),
          child: const Text(AccountSettingsStrings.save),
        ),
      ],
    ),
  );
  input.dispose();
}

Future<void> _confirmRemove(
  PaymentMethodsController controller,
  SavedPaymentMethod method,
) async {
  final confirmed = await Get.dialog<bool>(
    AlertDialog(
      title: const Text(AccountSettingsStrings.removeTitle),
      content: Text(AccountSettingsStrings.removeMessage(method.displayName)),
      actions: [
        TextButton(
          onPressed: () => Get.back(result: false),
          child: const Text(AccountSettingsStrings.cancel),
        ),
        TextButton(
          onPressed: () => Get.back(result: true),
          child: const Text(AccountSettingsStrings.remove),
        ),
      ],
    ),
  );
  if (confirmed == true) {
    await controller.remove(method);
  }
}

// ─────────────────────────────── Cards ───────────────────────────────

class _CardSection extends StatelessWidget {
  const _CardSection({required this.controller});

  final PaymentMethodsController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final cards = controller.cards;
      return _Panel(
        icon: Icons.credit_card,
        title: AccountSettingsStrings.cardTitle,
        caption: AccountSettingsStrings.cardCaption,
        expanded: controller.cardExpanded.value,
        onToggle: controller.toggleCards,
        collapsedTrailing: GestureDetector(
          onTap: controller.openNewCard,
          child: ShaderMask(
            blendMode: BlendMode.srcIn,
            shaderCallback: PartnerGradients.prime.createShader,
            child: const Text(
              AccountSettingsStrings.add,
              style: TextStyle(
                color: PartnerPalette.white,
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (final card in cards) ...[
              _SavedCardTile(controller: controller, card: card),
              const SizedBox(height: 10),
            ],
            if (controller.cardFormOpen.value)
              _CardForm(controller: controller)
            else
              Align(
                alignment: Alignment.centerRight,
                child: TextButton.icon(
                  onPressed: controller.openNewCard,
                  icon: const Icon(Icons.add, color: PartnerPalette.green),
                  label: const Text(
                    AccountSettingsStrings.add,
                    style: TextStyle(
                      color: PartnerPalette.green,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
          ],
        ),
      );
    });
  }
}

class _SavedCardTile extends StatelessWidget {
  const _SavedCardTile({required this.controller, required this.card});

  final PaymentMethodsController controller;
  final SavedPaymentMethod card;

  @override
  Widget build(BuildContext context) {
    final badges = [
      if (card.isDefault) AccountSettingsStrings.defaultBadge,
      if (card.isExpired) AccountSettingsStrings.expiredBadge,
    ];
    return _WhiteCard(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(card.displayName, style: settingsTileTitle),
                  const SizedBox(height: 4),
                  Text(
                    [
                      if (card.cardHolderName?.isNotEmpty ?? false)
                        card.cardHolderName!,
                      card.expiryLabel,
                      ...badges,
                    ].where((part) => part.isNotEmpty).join('  ·  '),
                    style: settingsTileCaption.copyWith(
                      color: card.isExpired
                          ? PartnerPalette.danger
                          : const Color(0xFF989898),
                    ),
                  ),
                ],
              ),
            ),
            if (!card.isDefault)
              IconButton(
                tooltip: AccountSettingsStrings.defaultBadge,
                visualDensity: VisualDensity.compact,
                onPressed: () => controller.makeDefault(card),
                icon: const Icon(
                  Icons.star_border,
                  size: 20,
                  color: PartnerPalette.mutedStrong,
                ),
              ),
            IconButton(
              tooltip: AccountSettingsStrings.edit,
              visualDensity: VisualDensity.compact,
              onPressed: () => controller.openEditCard(card),
              icon: const Icon(
                Icons.edit_outlined,
                size: 20,
                color: PartnerPalette.green,
              ),
            ),
            _RemoveButton(onTap: () => _confirmRemove(controller, card)),
          ],
        ),
      ),
    );
  }
}

class _CardForm extends StatelessWidget {
  const _CardForm({required this.controller});

  final PaymentMethodsController controller;

  @override
  Widget build(BuildContext context) {
    final isEditing = controller.editingCardId.value.isNotEmpty;
    return _WhiteCard(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _FormField(
              label: AccountSettingsStrings.nameOnCard,
              hint: AccountSettingsStrings.nameHint,
              controller: controller.cardName,
              icon: Icons.person_outline,
              capitalization: TextCapitalization.words,
            ),
            _FormField(
              label: AccountSettingsStrings.cardNumber,
              hint: AccountSettingsStrings.cardNumberHint,
              controller: controller.cardNumber,
              icon: Icons.credit_card,
              enabled: !isEditing,
              keyboardType: TextInputType.number,
              formatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(19),
                _CardNumberFormatter(),
              ],
            ),
            _FormField(
              label: AccountSettingsStrings.cardExpiry,
              hint: AccountSettingsStrings.cardExpiryHint,
              controller: controller.cardExpiry,
              keyboardType: TextInputType.number,
              formatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(4),
                _ExpiryFormatter(),
              ],
            ),
            if (!isEditing)
              const Padding(
                padding: EdgeInsets.only(bottom: 10),
                child: Text(
                  AccountSettingsStrings.cardNumberNote,
                  style: TextStyle(color: Color(0xFF989898), fontSize: 12),
                ),
              ),
            if (controller.cardError.value.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Text(
                  controller.cardError.value,
                  style: const TextStyle(
                    color: PartnerPalette.danger,
                    fontSize: 13,
                  ),
                ),
              ),
            PartnerPrimaryButton(
              label: controller.isSavingCard.value
                  ? '…'
                  : AccountSettingsStrings.save,
              height: 49,
              expand: true,
              onPressed:
                  controller.isSavingCard.value ? null : controller.saveCard,
            ),
            TextButton(
              onPressed: controller.closeCardForm,
              child: const Text(
                AccountSettingsStrings.cancel,
                style: TextStyle(color: PartnerPalette.mutedStrong),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FormField extends StatelessWidget {
  const _FormField({
    required this.label,
    required this.hint,
    required this.controller,
    this.icon,
    this.enabled = true,
    this.keyboardType,
    this.formatters,
    this.capitalization = TextCapitalization.none,
  });

  final String label;
  final String hint;
  final TextEditingController controller;
  final IconData? icon;
  final bool enabled;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? formatters;
  final TextCapitalization capitalization;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: PartnerPalette.black,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: controller,
            enabled: enabled,
            keyboardType: keyboardType,
            inputFormatters: formatters,
            textCapitalization: capitalization,
            style: PartnerStyle.fieldValue,
            decoration: InputDecoration(
              isDense: true,
              hintText: hint,
              hintStyle: const TextStyle(
                color: PartnerPalette.border,
                fontWeight: FontWeight.w600,
              ),
              suffixIcon: icon == null
                  ? null
                  : Icon(icon, size: 18, color: PartnerPalette.border),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 16,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: PartnerPalette.hairline),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: PartnerPalette.hairline),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Groups digits in fours: "4242424242424242" → "4242 4242 4242 4242".
class _CardNumberFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final digits = newValue.text.replaceAll(' ', '');
    final buffer = StringBuffer();
    for (var i = 0; i < digits.length; i++) {
      if (i > 0 && i % 4 == 0) buffer.write(' ');
      buffer.write(digits[i]);
    }
    final text = buffer.toString();
    return TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
  }
}

/// "0729" → "07/29".
class _ExpiryFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final digits = newValue.text.replaceAll('/', '');
    final text = digits.length > 2
        ? '${digits.substring(0, 2)}/${digits.substring(2)}'
        : digits;
    return TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
  }
}
