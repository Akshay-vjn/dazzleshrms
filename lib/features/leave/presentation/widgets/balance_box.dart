import 'package:flutter/material.dart';
import 'package:dazzleshrms/core/app_theme/app_theme.dart';

class BalanceBox extends StatefulWidget {
  final String label;
  final String value;

  const BalanceBox({
    super.key,
    required this.label,
    required this.value,
  });

  @override
  State<BalanceBox> createState() => _BalanceBoxState();
}

class _BalanceBoxState extends State<BalanceBox> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final surfaceColor =
    isDark ? AppTheme.surfaceDark : AppTheme.surfaceLight;

    final textColor =
    isDark ? Colors.white : Colors.black.withOpacity(0.85);

    final borderColor = AppTheme.PrimaryColor.withOpacity(
      isDark ? 0.35 : 0.18,
    );

    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),

          onTapDown: (_) {
            setState(() => _pressed = true);

            Future.delayed(const Duration(milliseconds: 90), () {
              if (mounted) {
                setState(() => _pressed = false);
              }
            });
          },

          onTap: () {},

          child: AnimatedContainer(
            duration: const Duration(milliseconds: 140),
            transform: Matrix4.identity()
              ..translate(0.0, _pressed ? 3.0 : -5.0)
              ..scale(_pressed ? 0.97 : 1.0),
            padding: const EdgeInsets.symmetric(vertical: 16),
            decoration: BoxDecoration(
              color: surfaceColor,
              borderRadius: BorderRadius.circular(16),

              border: Border.all(
                color: borderColor,
                width: 1,
              ),

              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(isDark ? 0.45 : 0.12),
                  blurRadius: _pressed ? 6 : 16,
                  offset: Offset(0, _pressed ? 3 : 8),
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  widget.value,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppTheme.PrimaryColor,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  widget.label,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: textColor.withOpacity(0.75),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
