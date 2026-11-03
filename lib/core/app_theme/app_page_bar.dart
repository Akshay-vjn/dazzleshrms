import 'dart:ui' show ImageFilter;
import 'package:flutter/cupertino.dart' show CupertinoIcons;
import 'package:flutter/material.dart';

class AppPageActionButton extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback? onPressed;
  final Color? iconColor;

  const AppPageActionButton({
    super.key,
    required this.icon,
    required this.tooltip,
    required this.onPressed,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dark = theme.brightness == Brightness.dark;

    return DecoratedBox(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: dark
            ? null
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: .10),
                  blurRadius: 12,
                  offset: const Offset(0, 3),
                ),
              ],
      ),
      child: ClipOval(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
          child: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: dark ? .14 : .72),
              shape: BoxShape.circle,
              border: Border.all(
                color: dark
                    ? Colors.white.withValues(alpha: .10)
                    : theme.colorScheme.onSurfaceVariant.withValues(alpha: .25),
                width: dark ? .8 : .5,
              ),
            ),
            child: IconButton(
              tooltip: tooltip,
              onPressed: onPressed,
              icon: Icon(
                icon,
                size: 21,
                color: iconColor ?? (dark ? Colors.white : Colors.black),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class AppPageHeader extends StatelessWidget {
  final String title;
  final bool showBack;
  final List<Widget> actions;

  const AppPageHeader({
    super.key,
    required this.title,
    this.showBack = true,
    this.actions = const [],
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dark = theme.brightness == Brightness.dark;
    final sideSpace = actions.length > 1 ? actions.length * 48.0 + 8 : 56.0;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: SizedBox(
        width: double.infinity,
        height: 48,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: sideSpace),
              child: Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  letterSpacing: -0.4,
                ),
              ),
            ),
            if (showBack)
              Align(
                alignment: Alignment.centerLeft,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: dark
                        ? null
                        : [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: .10),
                              blurRadius: 12,
                              offset: const Offset(0, 3),
                            ),
                          ],
                  ),
                  child: ClipOval(
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
                      child: Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(
                            alpha: dark ? .14 : .72,
                          ),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: dark
                                ? Colors.white.withValues(alpha: .10)
                                : theme.colorScheme.onSurfaceVariant.withValues(
                                    alpha: .25,
                                  ),
                            width: dark ? .8 : .5,
                          ),
                        ),
                        child: IconButton(
                          tooltip: MaterialLocalizations.of(
                            context,
                          ).backButtonTooltip,
                          padding: const EdgeInsets.only(right: 2),
                          onPressed: () => Navigator.of(context).maybePop(),
                          icon: Icon(
                            CupertinoIcons.chevron_back,
                            size: 22,
                            color: dark ? Colors.white : Colors.black,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            if (actions.isNotEmpty)
              Align(
                alignment: Alignment.centerRight,
                child: Row(mainAxisSize: MainAxisSize.min, children: actions),
              ),
          ],
        ),
      ),
    );
  }
}

class AppPageBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget> actions;
  final PreferredSizeWidget? bottom;
  final Widget? flexibleSpace;
  final Color? backgroundColor;
  final bool automaticallyImplyLeading;

  const AppPageBar({
    super.key,
    required this.title,
    this.actions = const [],
    this.bottom,
    this.flexibleSpace,
    this.backgroundColor,
    this.automaticallyImplyLeading = true,
  });

  @override
  Size get preferredSize =>
      Size.fromHeight(64 + (bottom?.preferredSize.height ?? 0));

  @override
  Widget build(BuildContext context) => AppBar(
    automaticallyImplyLeading: false,
    toolbarHeight: 64,
    titleSpacing: 0,
    centerTitle: false,
    backgroundColor: backgroundColor ?? Colors.transparent,
    elevation: 0,
    scrolledUnderElevation: 0,
    surfaceTintColor: Colors.transparent,
    flexibleSpace: flexibleSpace,
    title: AppPageHeader(
      title: title,
      showBack: automaticallyImplyLeading && Navigator.of(context).canPop(),
      actions: actions,
    ),
    bottom: bottom,
  );
}
