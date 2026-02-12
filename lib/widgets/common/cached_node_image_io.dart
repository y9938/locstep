import 'dart:io';

import 'package:flutter/material.dart';

/// Builds an image widget from a local file path (used when cache returns a path).
Widget buildFileImage(
  BuildContext context,
  String path, {
  required double? width,
  required double? height,
  required BoxFit fit,
  Widget Function(BuildContext, Object, StackTrace?)? errorBuilder,
}) {
  return Image.file(
    File(path),
    width: width,
    height: height,
    fit: fit,
    errorBuilder: errorBuilder ??
        (context, error, stackTrace) => Container(
              color: Theme.of(context).colorScheme.surfaceContainerLow,
              child: Icon(
                Icons.broken_image_outlined,
                size: 32,
                color: Theme.of(context).colorScheme.outline,
              ),
            ),
  );
}
