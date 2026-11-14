import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../constants/home_constants.dart';
import '../controllers/home_controller.dart';

/// White rounded card the three filter pop-ups share.
class _PanelCard extends StatelessWidget {
  const _PanelCard({required this.width, required this.child, this.padding});

  final double width;
  final Widget child;
  final EdgeInsets? padding;

  @override
  Widget build(BuildContext context) {
    final screen = MediaQuery.sizeOf(context).width - HomeSizes.pagePadding * 2;
    return Material(
      color: HomePalette.white,
      elevation: 0,
      borderRadius: BorderRadius.circular(HomeSizes.panelRadius),
      child: Container(
        width: width > screen ? screen : width,
        padding: padding ?? const EdgeInsets.all(HomeSizes.panelPadding),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(HomeSizes.panelRadius),
          boxShadow: HomeShadows.search,
          color: HomePalette.white,
        ),
        child: child,
      ),
    );
  }
}

class _CloseButton extends StatelessWidget {
  const _CloseButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: const Icon(
        Icons.cancel,
        size: HomeSizes.panelCloseSize,
        color: HomePalette.black,
      ),
    );
  }
}

class _PanelHeader extends StatelessWidget {
  const _PanelHeader({required this.title, required this.onClose});

  final String title;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: Text(title, style: HomeStyle.panelTitle)),
        _CloseButton(onTap: onClose),
      ],
    );
  }
}

class _Option extends StatelessWidget {
  const _Option({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.only(top: HomeSizes.panelOptionGap),
        child: Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: isSelected
                    ? HomeStyle.panelOptionSelected
                    : HomeStyle.panelOption,
              ),
            ),
            if (isSelected)
              const Icon(Icons.check, size: 18, color: HomePalette.green),
          ],
        ),
      ),
    );
  }
}

/// FR-06 — "Filter": party size / boat type.
class FilterPanel extends StatelessWidget {
  const FilterPanel({required this.controller, super.key});

  final HomeController controller;

  @override
  Widget build(BuildContext context) {
    return _PanelCard(
      width: HomeSizes.filterPanelWidth,
      child: Obx(
        () => Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _PanelHeader(
              title: HomeStrings.filter,
              onClose: controller.closePanel,
            ),
            for (var index = 0;
                index < HomeStrings.capacityOptions.length;
                index++)
              _Option(
                label: HomeStrings.capacityOptions[index],
                isSelected: controller.selectedCapacity.value == index,
                onTap: () => controller.selectCapacity(index),
              ),
          ],
        ),
      ),
    );
  }
}

/// FR-08 — "Price Range": preset bands, or a custom above/below.
class PricePanel extends StatelessWidget {
  const PricePanel({required this.controller, super.key});

  final HomeController controller;

  @override
  Widget build(BuildContext context) {
    return _PanelCard(
      width: HomeSizes.pricePanelWidth,
      child: Obx(
        () => Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _PanelHeader(
              title: HomeStrings.priceRange,
              onClose: controller.closePanel,
            ),
            for (var index = 0; index < HomeStrings.priceOptions.length; index++)
              _Option(
                label: HomeStrings.priceOptions[index],
                isSelected: controller.selectedPrice.value == index,
                onTap: () => controller.selectPrice(index),
              ),
            const SizedBox(height: HomeSizes.panelOptionGap),
            Row(
              children: [
                Expanded(
                  child: _PriceField(
                    label: HomeStrings.above,
                    controller: controller.minPriceController,
                    onChanged: controller.onCustomPriceChanged,
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: _PriceField(
                    label: HomeStrings.below,
                    controller: controller.maxPriceController,
                    onChanged: controller.onCustomPriceChanged,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _PriceField extends StatelessWidget {
  const _PriceField({
    required this.label,
    required this.controller,
    required this.onChanged,
  });

  final String label;
  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: HomeStyle.panelOption),
        const SizedBox(height: 8),
        Container(
          height: HomeSizes.priceFieldHeight,
          padding: const EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(
            color: HomePalette.priceField,
            borderRadius: BorderRadius.circular(HomeSizes.priceFieldRadius),
          ),
          alignment: Alignment.centerLeft,
          child: TextField(
            controller: controller,
            onChanged: onChanged,
            keyboardType: TextInputType.number,
            style: HomeStyle.panelOption,
            decoration: const InputDecoration(
              prefixText: '${HomeStrings.rupee} ',
              prefixStyle: HomeStyle.panelOption,
              border: InputBorder.none,
              isCollapsed: true,
            ),
          ),
        ),
      ],
    );
  }
}

/// FR-07 — "Calender": month grid; picking a day closes the pop-up.
class CalendarPanel extends StatelessWidget {
  const CalendarPanel({required this.controller, super.key});

  final HomeController controller;

  @override
  Widget build(BuildContext context) {
    return _PanelCard(
      width: HomeSizes.calendarPanelWidth,
      padding: const EdgeInsets.only(bottom: 12),
      child: Obx(() {
        final month = controller.calendarMonth.value;
        final selected = controller.selectedDate.value;
        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                HomeSizes.panelPadding,
                HomeSizes.panelPadding,
                HomeSizes.panelPadding,
                12,
              ),
              child: Row(
                children: [
                  const Icon(Icons.calendar_today_outlined, size: 20),
                  const SizedBox(width: 10),
                  const Expanded(
                    child: Text(
                      HomeStrings.calendar,
                      style: HomeStyle.panelTitleSmall,
                    ),
                  ),
                  _CloseButton(onTap: controller.closePanel),
                ],
              ),
            ),
            Container(
              height: HomeSizes.calendarHeaderHeight,
              color: HomePalette.panelStrip,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  IconButton(
                    onPressed: controller.previousCalendarMonth,
                    icon: const Icon(Icons.chevron_left, color: HomePalette.blue),
                  ),
                  Container(
                    padding: const EdgeInsets.only(bottom: 2),
                    decoration: const BoxDecoration(
                      border: Border(
                        bottom: BorderSide(color: HomePalette.green),
                      ),
                    ),
                    child: Text(
                      '${HomeStrings.months[month.month - 1]} ${month.year}',
                      style: HomeStyle.calendarMonth,
                    ),
                  ),
                  IconButton(
                    onPressed: controller.nextCalendarMonth,
                    icon: const Icon(Icons.chevron_right, color: HomePalette.blue),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            _MonthGrid(
              month: month,
              selected: selected,
              onSelect: controller.selectDate,
            ),
          ],
        );
      }),
    );
  }
}

class _MonthGrid extends StatelessWidget {
  const _MonthGrid({
    required this.month,
    required this.selected,
    required this.onSelect,
  });

  final DateTime month;
  final DateTime? selected;
  final ValueChanged<DateTime> onSelect;

  @override
  Widget build(BuildContext context) {
    final first = DateTime(month.year, month.month);
    // Sunday-first grid: Dart's weekday is 1 (Mon) … 7 (Sun).
    final start = first.subtract(Duration(days: first.weekday % 7));
    final today = DateUtils.dateOnly(DateTime.now());
    final daysInMonth = DateUtils.getDaysInMonth(month.year, month.month);
    final rows = ((first.weekday % 7) + daysInMonth + 6) ~/ 7;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Column(
        children: [
          Row(
            children: [
              for (final day in HomeStrings.weekdays)
                Expanded(
                  child: Center(
                    child: Text(day, style: HomeStyle.calendarWeekday),
                  ),
                ),
            ],
          ),
          for (var row = 0; row < rows; row++)
            Row(
              children: [
                for (var col = 0; col < 7; col++)
                  Expanded(
                    child: _DayCell(
                      day: start.add(Duration(days: row * 7 + col)),
                      month: month,
                      today: today,
                      selected: selected,
                      onSelect: onSelect,
                    ),
                  ),
              ],
            ),
        ],
      ),
    );
  }
}

class _DayCell extends StatelessWidget {
  const _DayCell({
    required this.day,
    required this.month,
    required this.today,
    required this.selected,
    required this.onSelect,
  });

  final DateTime day;
  final DateTime month;
  final DateTime today;
  final DateTime? selected;
  final ValueChanged<DateTime> onSelect;

  @override
  Widget build(BuildContext context) {
    final inMonth = day.month == month.month;
    final isPast = day.isBefore(today);
    final isSelected = selected != null && DateUtils.isSameDay(day, selected);
    final isToday = DateUtils.isSameDay(day, today);
    final enabled = inMonth && !isPast;

    var style = HomeStyle.calendarDay;
    if (!enabled) {
      style = style.copyWith(color: HomePalette.mutedDay);
    } else if (day.weekday == DateTime.sunday) {
      style = style.copyWith(color: HomePalette.green);
    }
    if (isToday && !isSelected) {
      style = style.copyWith(
        color: HomePalette.green,
        decoration: TextDecoration.underline,
        decorationColor: HomePalette.green,
      );
    }
    if (isSelected) {
      style = style.copyWith(color: HomePalette.white, fontWeight: FontWeight.w600);
    }

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: enabled ? () => onSelect(day) : null,
      child: SizedBox(
        height: HomeSizes.calendarCellHeight,
        child: Center(
          child: Container(
            width: 30,
            height: 30,
            alignment: Alignment.center,
            decoration: isSelected
                ? const BoxDecoration(
                    gradient: HomeGradients.prime,
                    shape: BoxShape.circle,
                  )
                : null,
            child: Text(day.day.toString().padLeft(2, '0'), style: style),
          ),
        ),
      ),
    );
  }
}
