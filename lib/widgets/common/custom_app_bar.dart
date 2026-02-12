import 'package:flutter/material.dart';
import '../../app_constants.dart';

/// Расширение для получения темного/светлого варианта цвета
extension ColorExtension on Color {
  Color darken(int percent) {
    assert(1 <= percent && percent <= 100);
    final f = 1 - percent / 100;
    return Color.fromARGB(
      (a * 255.0).round().clamp(0, 255),
      ((r * 255.0).round().clamp(0, 255) * f).round(),
      ((g * 255.0).round().clamp(0, 255) * f).round(),
      ((b * 255.0).round().clamp(0, 255) * f).round(),
    );
  }

  Color lighten(int percent) {
    assert(1 <= percent && percent <= 100);
    final f = percent / 100;
    return Color.fromARGB(
      (a * 255.0).round().clamp(0, 255),
      (r * 255.0).round().clamp(0, 255) + ((255 - (r * 255.0).round().clamp(0, 255)) * f).round(),
      (g * 255.0).round().clamp(0, 255) + ((255 - (g * 255.0).round().clamp(0, 255)) * f).round(),
      (b * 255.0).round().clamp(0, 255) + ((255 - (b * 255.0).round().clamp(0, 255)) * f).round(),
    );
  }
}

/// Общий градиент для AppBar (как в navigation_screen)
BoxDecoration appBarGradientDecoration(BuildContext context) {
  final c = Theme.of(context).colorScheme;
  return BoxDecoration(
    gradient: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        c.primary,
        c.primaryContainer,
        c.secondary,
      ],
    ),
  );
}

/// Переиспользуемый AppBar с градиентом в стиле приложения
class CustomGradientAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final Widget? leading;
  final bool centerTitle;
  final Color? foregroundColor;
  final PreferredSizeWidget? bottom;
  final VoidCallback? onBack;

  const CustomGradientAppBar({
    super.key,
    required this.title,
    this.actions,
    this.leading,
    this.centerTitle = true,
    this.foregroundColor,
    this.bottom,
    this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final fg = foregroundColor ?? theme.colorScheme.onPrimary;

    return AppBar(
      title: Text(
        title,
        style: theme.textTheme.titleLarge?.copyWith(
          color: fg,
          fontWeight: FontWeight.bold,
        ),
      ),
      centerTitle: centerTitle,
      leading: leading ?? (onBack != null
          ? IconButton(
              icon: Icon(Icons.arrow_back, color: fg),
              onPressed: onBack,
            )
          : null),
      iconTheme: IconThemeData(color: fg),
      flexibleSpace: Container(
        decoration: appBarGradientDecoration(context),
      ),
      actions: actions,
      bottom: bottom,
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight + (bottom?.preferredSize.height ?? 0));
}

/// Переиспользуемый SliverAppBar с градиентом (для экранов с CustomScrollView)
class CustomSliverAppBar extends StatelessWidget {
  final Widget title;
  final List<Widget> actions;
  final double expandedHeight;
  final bool pinned;
  final bool floating;

  const CustomSliverAppBar({
    super.key,
    required this.title,
    this.actions = const [],
    this.expandedHeight = 100,
    this.pinned = true,
    this.floating = false,
  });

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      backgroundColor: Theme.of(context).colorScheme.primary.darken(35),
      expandedHeight: expandedHeight,
      floating: floating,
      pinned: pinned,
      flexibleSpace: FlexibleSpaceBar(
        titlePadding: const EdgeInsets.only(
          left: AppConstants.kScreenPadding,
          bottom: AppConstants.kCardPadding,
        ),
        title: title,
        background: Container(
          decoration: appBarGradientDecoration(context),
        ),
      ),
      iconTheme: IconThemeData(color: Theme.of(context).colorScheme.onPrimary),
      actions: actions,
    );
  }
}
