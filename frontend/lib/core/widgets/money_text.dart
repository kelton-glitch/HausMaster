import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// An XAF amount: bold figure with a small unit, e.g. `150 000 XAF`
/// (NFR-11: thousands separators, no minor unit).
class MoneyText extends StatelessWidget {
  const MoneyText(this.amount, {super.key, this.style, this.color});

  final num amount;
  final TextStyle? style;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context).toLanguageTag();
    final base = (style ?? Theme.of(context).textTheme.titleMedium)!.copyWith(
      color: color,
      fontWeight: FontWeight.w800,
    );
    final figure = NumberFormat.decimalPattern(locale).format(amount);
    return Text.rich(
      TextSpan(
        text: figure,
        style: base,
        children: [
          TextSpan(
            text: ' XAF',
            style: base.copyWith(
              fontSize: (base.fontSize ?? 16) * 0.65,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
      semanticsLabel: '$figure XAF',
    );
  }
}
