import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../data/image_cache_service.dart';
import 'cached_node_image_io.dart' as file_impl;

/// Displays an image by URL with disk cache.
class CachedNodeImage extends StatelessWidget {
  const CachedNodeImage({
    super.key,
    required this.url,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.errorBuilder,
  });

  final String url;
  final double? width;
  final double? height;
  final BoxFit fit;
  final Widget Function(BuildContext, Object, StackTrace?)? errorBuilder;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cache = context.read<ImageCacheService>();
    return FutureBuilder<String>(
      future: cache.getOrDownload(url),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Container(
            width: width,
            height: height,
            color: theme.colorScheme.surfaceContainerLow,
            alignment: Alignment.center,
            child: const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          );
        }
        if (snapshot.hasError || !snapshot.hasData) {
          if (errorBuilder != null) {
            return errorBuilder!(
              context,
              snapshot.error ?? Exception('Failed to load image'),
              snapshot.stackTrace,
            );
          }
          return Container(
            width: width,
            height: height,
            color: theme.colorScheme.surfaceContainerLow,
            child: Icon(
              Icons.broken_image_outlined,
              size: 32,
              color: theme.colorScheme.outline,
            ),
          );
        }
        return file_impl.buildFileImage(
          context,
          snapshot.data!,
          width: width,
          height: height,
          fit: fit,
          errorBuilder: errorBuilder,
        );
      },
    );
  }
}
