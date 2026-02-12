import 'package:flutter/material.dart';

/// Обёртка, снимающая фокус с текущего поля ввода при тапе вне его.
///
/// Использует [HitTestBehavior.translucent], чтобы тапы по пустым/прозрачным
/// областям тоже обрабатывались (иначе фокус не снимается при тапе «в пустое»).
class UnfocusOnTap extends StatelessWidget {
  final Widget child;

  const UnfocusOnTap({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      behavior: HitTestBehavior.translucent,
      child: child,
    );
  }
}
