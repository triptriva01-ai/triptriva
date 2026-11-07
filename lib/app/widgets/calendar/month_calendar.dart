import 'package:flutter/material.dart';

/// How one day cell is painted. Returned by [MonthCalendar.styleFor] so each
/// screen can decide what "selected" means — a booked slot, a season day, an
/// off-season day, an available date — without the calendar knowing about any
/// of it.
class DayStyle {
  const DayStyle({this.fill, this.textColor, this.underlined = false});

  /// Filled circle behind the number. Null leaves the cell flat.
  final Color? fill;
  final Color? textColor;

  /// Thin rule under the number, marking "today" in the Figma export.
  final bool underlined;
}

/// Design tokens for the calendar. It is shared by the partner slot screens
/// and the traveller booking flow, so it owns its colours here.
abstract final class CalendarPalette {
  static const green = Color(0xFF1F7A62);
  static const label = Color(0xFF444444);
  static const day = Color(0xFF1D1D1D);

  /// Days that belong to the neighbouring month.
  static const outOfMonth = Color(0xFFD5D5D5);
  static const arrow = Color(0xFF7B7B7B);
  static const black = Colors.black;
}

/// Month grid shared by the partner slot screens and the traveller booking
/// flow. Renders a fixed six-week grid so switching months never reflows the
/// surrounding layout.
class MonthCalendar extends StatelessWidget {
  const MonthCalendar({
    required this.month,
    required this.onPreviousMonth,
    required this.onNextMonth,
    this.onDayTap,
    this.styleFor,
    super.key,
  });

  /// Any date inside the month being shown; only year and month are read.
  final DateTime month;
  final VoidCallback onPreviousMonth;
  final VoidCallback onNextMonth;
  final ValueChanged<DateTime>? onDayTap;

  /// Called for every in-month day. Days outside the month are always muted.
  final DayStyle Function(DateTime day)? styleFor;

  static const _weekdays = ['Sun', 'Mon', 'Tue', 'Wed', 'Thur', 'Fri', 'Sat'];
  static const _months = [
    'January', 'February', 'March', 'April', 'May', 'June',
    'July', 'August', 'September', 'October', 'November', 'December',
  ];

  /// Widest a day circle is allowed to get, from the Figma export.
  static const _maxCellSize = 45.0;

  @override
  Widget build(BuildContext context) {
    final first = DateTime(month.year, month.month);
    // DateTime.weekday is Mon=1..Sun=7; the grid starts on Sunday.
    final leadingBlanks = first.weekday % 7;
    final gridStart = first.subtract(Duration(days: leadingBlanks));

    return LayoutBuilder(
      builder: (context, constraints) {
        // Seven columns have to share whatever width the page gives us, so the
        // circle is sized from the cell rather than the other way round.
        final cellSize = (constraints.maxWidth / 7).clamp(0.0, _maxCellSize);
        return _buildCalendar(gridStart, cellSize);
      },
    );
  }

  Widget _buildCalendar(DateTime gridStart, double cellSize) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Row(
            children: [
              for (final day in _weekdays)
                Expanded(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      day,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: CalendarPalette.label,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
        Container(
          height: 1,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color(0x00000000),
                Color(0xFFB5B5B5),
                Color(0x00000000),
              ],
            ),
          ),
        ),
        const SizedBox(height: 14),
        for (var week = 0; week < 6; week++)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Row(
              children: [
                for (var weekday = 0; weekday < 7; weekday++)
                  Expanded(
                    child: _DayCell(
                      date: gridStart.add(
                        Duration(days: week * 7 + weekday),
                      ),
                      month: month.month,
                      size: cellSize,
                      styleFor: styleFor,
                      onTap: onDayTap,
                    ),
                  ),
              ],
            ),
          ),
        const SizedBox(height: 16),
        Row(
          children: [
            _MonthArrow(icon: Icons.chevron_left, onTap: onPreviousMonth),
            // Flexible gaps rather than fixed ones, so the month label keeps
            // its space on narrow screens.
            Expanded(
              child: Center(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    '${_months[month.month - 1]} ${month.year}',
                    style: const TextStyle(
                      color: CalendarPalette.black,
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ),
            _MonthArrow(icon: Icons.chevron_right, onTap: onNextMonth),
          ],
        ),
      ],
    );
  }
}

class _DayCell extends StatelessWidget {
  const _DayCell({
    required this.date,
    required this.month,
    required this.size,
    required this.styleFor,
    required this.onTap,
  });

  final DateTime date;
  final int month;

  /// Side of the square cell, derived from the available width.
  final double size;
  final DayStyle Function(DateTime day)? styleFor;
  final ValueChanged<DateTime>? onTap;

  @override
  Widget build(BuildContext context) {
    final inMonth = date.month == month;
    final style = inMonth ? styleFor?.call(date) : null;
    final label = date.day.toString().padLeft(2, '0');

    final text = FittedBox(
      // The glyph shrinks with the cell instead of spilling out of it.
      fit: BoxFit.scaleDown,
      child: Text(
        label,
        textAlign: TextAlign.center,
        style: TextStyle(
          color: inMonth
              ? (style?.textColor ?? CalendarPalette.day)
              : CalendarPalette.outOfMonth,
          fontSize: 18,
          fontWeight: FontWeight.w500,
          decoration:
              style?.underlined ?? false ? TextDecoration.underline : null,
          decorationColor: CalendarPalette.green,
        ),
      ),
    );

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: inMonth && onTap != null ? () => onTap!(date) : null,
      child: SizedBox(
        height: size,
        child: Center(
          child: style?.fill == null
              ? Padding(padding: const EdgeInsets.all(4), child: text)
              : Container(
                  width: size,
                  height: size,
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: style!.fill,
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: text,
                ),
        ),
      ),
    );
  }
}

class _MonthArrow extends StatelessWidget {
  const _MonthArrow({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
        child: Icon(icon, size: 24, color: CalendarPalette.arrow),
      ),
    );
  }
}

/// Colour key under the calendar: "Full Filled", "offer", "Season".
class CalendarLegend extends StatelessWidget {
  const CalendarLegend({required this.entries, super.key});

  final List<({Color color, String label})> entries;

  @override
  Widget build(BuildContext context) {
    // Wrap rather than Row: the key drops onto a second line on narrow
    // screens instead of overflowing.
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 28,
      runSpacing: 12,
      children: [
        for (final entry in entries)
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: entry.color,
                  borderRadius: BorderRadius.circular(40),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                entry.label,
                style: const TextStyle(
                  color: CalendarPalette.black,
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
      ],
    );
  }
}
