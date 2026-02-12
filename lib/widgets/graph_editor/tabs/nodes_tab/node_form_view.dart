import 'package:flutter/material.dart';
import '../../../../app_constants.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../models/graph.dart';

import '../../../common/node_autocomplete_field.dart';
import 'node_form_controller.dart';

/// Форма добавления/редактирования узла
class NodeFormView extends StatelessWidget {
  final NodeFormController controller;
  final BuildingGraph graph;
  final VoidCallback onSubmit;
  final VoidCallback onCancel;

  const NodeFormView({
    super.key,
    required this.controller,
    required this.graph,
    required this.onSubmit,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isEditing = controller.isEditing;

    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(
        AppConstants.kCardBorderRadius,
        AppConstants.kCardBorderRadius,
        AppConstants.kCardBorderRadius,
        MediaQuery.of(context).viewInsets.bottom + AppConstants.kCardBorderRadius,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Основные поля
          Card(
            margin: const EdgeInsets.only(bottom: AppConstants.kListMarginBottom),
            child: Padding(
              padding: const EdgeInsets.all(AppConstants.kCardBorderRadius),
              child: Column(
                children: [
                  _NodeNameField(controller: controller, l10n: l10n),
                  const SizedBox(height: AppConstants.kCardBorderRadius),
                  _NodeIdField(controller: controller, l10n: l10n, isEditing: isEditing),
                ],
              ),
            ),
          ),

          // Секции
          Card(
            margin: const EdgeInsets.only(bottom: AppConstants.kListMarginBottom),
            child: Padding(
              padding: const EdgeInsets.all(AppConstants.kCardBorderRadius),
              child: _AutoAliasesSectionCompact(controller: controller),
            ),
          ),

          Card(
            margin: const EdgeInsets.only(bottom: AppConstants.kListMarginBottom),
            child: Padding(
              padding: const EdgeInsets.all(AppConstants.kCardBorderRadius),
              child: _CustomAliasesSectionCompact(controller: controller),
            ),
          ),

          Card(
            margin: const EdgeInsets.only(bottom: AppConstants.kListMarginBottom),
            child: Padding(
              padding: const EdgeInsets.all(AppConstants.kCardBorderRadius),
              child: _NeighborsSectionCompact(controller: controller, graph: graph),
            ),
          ),

          Card(
            margin: const EdgeInsets.only(bottom: AppConstants.kListMarginBottom),
            child: Padding(
              padding: const EdgeInsets.all(AppConstants.kCardBorderRadius),
              child: _ImageUrlsSection(controller: controller),
            ),
          ),

          Card(
            margin: const EdgeInsets.only(bottom: AppConstants.kListMarginBottom),
            child: Padding(
              padding: const EdgeInsets.all(AppConstants.kCardBorderRadius),
              child: _Tour3dUrlSection(controller: controller),
            ),
          ),

          // Кнопки
          _ActionButtons(
            isEditing: isEditing,
            l10n: l10n,
            onSubmit: onSubmit,
            onCancel: isEditing ? onCancel : null,
          ),
        ],
      ),
    );
  }
}

/// Поле ввода названия узла
class _NodeNameField extends StatelessWidget {
  final NodeFormController controller;
  final AppLocalizations l10n;

  const _NodeNameField({
    required this.controller,
    required this.l10n,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller.nodeNameController,
      textInputAction: TextInputAction.next,
      onEditingComplete: () => controller.nodeIdFocusNode.requestFocus(),
      decoration: InputDecoration(
        labelText: '${l10n.nodeName} *',
        hintText: l10n.nodeNameHint,
        border: const OutlineInputBorder(),
        contentPadding: AppConstants.kInputContentPadding,
      ),
    );
  }
}

/// Поле ввода ID узла
class _NodeIdField extends StatelessWidget {
  final NodeFormController controller;
  final AppLocalizations l10n;
  final bool isEditing;

  const _NodeIdField({
    required this.controller,
    required this.l10n,
    required this.isEditing,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller.nodeIdController,
      focusNode: controller.nodeIdFocusNode,
      enabled: !isEditing,
      decoration: InputDecoration(
        labelText: '${l10n.nodeId} *',
        hintText: l10n.autoFromName,
        border: const OutlineInputBorder(),
        contentPadding: AppConstants.kInputContentPadding,
        suffixIcon: isEditing ? null : _AutoGenerateToggle(controller: controller),
      ),
    );
  }
}

/// Кнопка переключения авто-генерации ID
class _AutoGenerateToggle extends StatelessWidget {
  final NodeFormController controller;

  const _AutoGenerateToggle({required this.controller});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        final isEnabled = controller.autoGenerateId;
        return IconButton(
          icon: Icon(
            isEnabled ? Icons.auto_fix_high : Icons.auto_fix_off,
            color: isEnabled ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.outline,
          ),
          onPressed: controller.toggleAutoGenerateId,
          tooltip: isEnabled ? l10n.autoGenerateEnabled : l10n.autoGenerateDisabled,
        );
      },
    );
  }
}

/// Компактная секция авто-алиасов
class _AutoAliasesSectionCompact extends StatelessWidget {
  final NodeFormController controller;

  const _AutoAliasesSectionCompact({required this.controller});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final autoAliases = controller.currentAutoAliases;
    final hasName = controller.nodeNameController.text.isNotEmpty;
    final isFrozen = controller.isAutoAliasesFrozen;
    final isEnabled = controller.autoAliasesEnabled;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Заголовок с кнопками
        Row(
          children: [
            Text(
              l10n.autoAliases,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
            const Spacer(),
            if (isEnabled && autoAliases.isNotEmpty)
              TextButton.icon(
                onPressed: controller.toggleFreezeAutoAliases,
                icon: Icon(isFrozen ? Icons.ac_unit : Icons.ac_unit_outlined, size: 18),
                label: Text(isFrozen ? l10n.frozen : l10n.freeze),
                style: TextButton.styleFrom(
                  visualDensity: VisualDensity.compact,
                  padding: const EdgeInsets.symmetric(horizontal: AppConstants.kSpacingUnit),
                ),
              ),
            TextButton.icon(
              onPressed: controller.toggleAutoAliases,
              icon: Icon(isEnabled ? Icons.auto_awesome : Icons.auto_awesome_outlined, size: 18),
              label: Text(isEnabled ? l10n.on : l10n.off),
              style: TextButton.styleFrom(
                visualDensity: VisualDensity.compact,
                padding: const EdgeInsets.symmetric(horizontal: AppConstants.kSpacingUnit),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppConstants.kSpacingUnit),

        // Контент
        if (!isEnabled)
          Text(
            l10n.autoAliasesDisabled,
            style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant, fontStyle: FontStyle.italic),
          )
        else if (autoAliases.isEmpty)
          Text(
            hasName ? l10n.noAutoAliases : l10n.enterNameForAliases,
            style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant, fontStyle: FontStyle.italic),
          )
        else
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: autoAliases.map((alias) {
              return _AliasChip(
                alias: alias,
                isFrozen: isFrozen,
                onDelete: isFrozen ? () => controller.removeAutoAlias(alias) : null,
              );
            }).toList(),
          ),
      ],
    );
  }
}

/// Компактная секция кастомных алиасов
class _CustomAliasesSectionCompact extends StatelessWidget {
  final NodeFormController controller;

  const _CustomAliasesSectionCompact({required this.controller});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final customAliases = controller.customAliases;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          l10n.customAliases,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: AppConstants.kSpacingUnit),
        if (customAliases.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: AppConstants.kListMarginBottom),
            child: Wrap(
              spacing: 6,
              runSpacing: 6,
              children: customAliases.map((alias) {
                return _AliasChip(
                  alias: alias,
                  isCustom: true,
                  onDelete: () => controller.removeCustomAlias(alias),
                );
              }).toList(),
            ),
          ),
        TextField(
          controller: controller.customAliasController,
          textInputAction: TextInputAction.done,
          decoration: InputDecoration(
            hintText: l10n.addAliasHint,
            border: const OutlineInputBorder(),
            contentPadding: AppConstants.kInputContentPadding,
            suffixIcon: IconButton(
              onPressed: () {
                final alias = controller.customAliasController.text.trim();
                if (alias.isNotEmpty) {
                  controller.addCustomAlias(alias);
                  controller.customAliasController.clear();
                }
              },
              icon: const Icon(Icons.add),
            ),
          ),
          onSubmitted: (_) {
            final alias = controller.customAliasController.text.trim();
            if (alias.isNotEmpty) {
              controller.addCustomAlias(alias);
              controller.customAliasController.clear();
            }
          },
        ),
      ],
    );
  }
}

/// Компактная секция соседей
class _NeighborsSectionCompact extends StatelessWidget {
  final NodeFormController controller;
  final BuildingGraph graph;

  const _NeighborsSectionCompact({
    required this.controller,
    required this.graph,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          l10n.neighbors,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: AppConstants.kSpacingUnit),
        if (controller.selectedNeighbors.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: AppConstants.kListMarginBottom),
            child: Wrap(
              spacing: 6,
              runSpacing: 6,
              children: controller.selectedNeighbors.map((neighborId) {
                final node = graph.getNode(neighborId);
                final displayName = node?.name ?? neighborId;
                return Chip(
                  label: Text(displayName),
                  deleteIcon: const Icon(Icons.close, size: 18),
                  onDeleted: () => controller.removeNeighbor(neighborId),
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  visualDensity: VisualDensity.compact,
                );
              }).toList(),
            ),
          ),
        NodeAutocompleteField(
          graph: graph,
          controller: controller.neighborSearchController,
          labelText: l10n.add,
          hintText: l10n.searchNodesHint,
          prefixIcon: const Icon(Icons.search, size: 20),
          excludeNodeIds: [
            if (controller.editingNodeId != null) controller.editingNodeId!,
            ...controller.selectedNeighbors,
          ],
          onSelected: (node) {
            controller.addNeighbor(node.id);
            controller.neighborSearchController.clear();
          },
        ),
      ],
    );
  }
}

/// Секция ссылок на 3D-туры
class _Tour3dUrlSection extends StatelessWidget {
  final NodeFormController controller;

  const _Tour3dUrlSection({required this.controller});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final tour3dUrls = controller.tour3dUrls;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          l10n.tour3dUrlLabel,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: AppConstants.kSpacingUnit),
        if (tour3dUrls.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: AppConstants.kListMarginBottom),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: List.generate(tour3dUrls.length, (index) {
                final url = tour3dUrls[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: AppConstants.kSpacingTiny),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: SelectableText(
                          url,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, size: 18),
                        onPressed: () => controller.removeTour3dUrl(index),
                        style: IconButton.styleFrom(
                          visualDensity: VisualDensity.compact,
                          padding: const EdgeInsets.all(AppConstants.kSpacingTiny),
                          minimumSize: const Size(32, 32),
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ),
          ),
        TextField(
          controller: controller.tour3dUrlController,
          keyboardType: TextInputType.url,
          decoration: InputDecoration(
            hintText: l10n.tour3dUrlAddHint,
            border: const OutlineInputBorder(),
            contentPadding: AppConstants.kInputContentPadding,
            suffixIcon: IconButton(
              onPressed: () {
                final text = controller.tour3dUrlController.text.trim();
                if (text.isNotEmpty) {
                  controller.addTour3dUrl(text);
                  controller.tour3dUrlController.clear();
                }
              },
              icon: const Icon(Icons.add, size: 20),
            ),
          ),
          onSubmitted: (_) {
            final text = controller.tour3dUrlController.text.trim();
            if (text.isNotEmpty) {
              controller.addTour3dUrl(text);
              controller.tour3dUrlController.clear();
            }
          },
        ),
      ],
    );
  }
}

/// Секция ссылок на фото
class _ImageUrlsSection extends StatelessWidget {
  final NodeFormController controller;

  const _ImageUrlsSection({required this.controller});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final imageUrls = controller.imageUrls;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            Text(
              l10n.imageUrlsLabel,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
            const Spacer(),
            InkWell(
              onTap: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: Text(l10n.imageUrlsLabel),
                    content: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 560),
                      child: Text(l10n.imageUrlsHelp),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: Text(l10n.ok),
                      ),
                    ],
                  ),
                );
              },
              borderRadius: BorderRadius.circular(4),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 2),
                child: Text(
                  '?',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppConstants.kSpacingUnit),
        if (imageUrls.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: AppConstants.kListMarginBottom),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: List.generate(imageUrls.length, (index) {
                final url = imageUrls[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: AppConstants.kSpacingTiny),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: SelectableText(
                          url,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, size: 18),
                        onPressed: () => controller.removeImageUrl(index),
                        style: IconButton.styleFrom(
                          visualDensity: VisualDensity.compact,
                          padding: const EdgeInsets.all(AppConstants.kSpacingTiny),
                          minimumSize: const Size(32, 32),
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ),
          ),
        TextField(
          controller: controller.imageUrlController,
          keyboardType: TextInputType.url,
          decoration: InputDecoration(
            hintText: l10n.imageUrlAddHint,
            border: const OutlineInputBorder(),
            contentPadding: AppConstants.kInputContentPadding,
            suffixIcon: IconButton(
              onPressed: () {
                final text = controller.imageUrlController.text.trim();
                if (text.isNotEmpty) {
                  controller.addImageUrl(text);
                  controller.imageUrlController.clear();
                }
              },
              icon: const Icon(Icons.add, size: 20),
            ),
          ),
          onSubmitted: (_) {
            final text = controller.imageUrlController.text.trim();
            if (text.isNotEmpty) {
              controller.addImageUrl(text);
              controller.imageUrlController.clear();
            }
          },
        ),
      ],
    );
  }
}

/// Чип алиаса
class _AliasChip extends StatelessWidget {
  final String alias;
  final bool isFrozen;
  final bool isCustom;
  final VoidCallback? onDelete;

  const _AliasChip({
    required this.alias,
    this.isFrozen = false,
    this.isCustom = false,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final isDeletable = onDelete != null;

    Color bgColor;
    Color borderColor;
    if (isCustom) {
      bgColor = Theme.of(context).colorScheme.tertiaryContainer;
      borderColor = Theme.of(context).colorScheme.tertiary;
    } else if (isFrozen) {
      bgColor = Theme.of(context).colorScheme.primaryContainer;
      borderColor = Theme.of(context).colorScheme.primary;
    } else {
      bgColor = Theme.of(context).colorScheme.surfaceContainerLow;
      borderColor = Theme.of(context).colorScheme.outline;
    }

    return Chip(
      label: Text(alias),
      padding: const EdgeInsets.symmetric(horizontal: AppConstants.kSpacingTiny),
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      backgroundColor: bgColor,
      side: BorderSide(color: borderColor),
      deleteIcon: isDeletable ? const Icon(Icons.close, size: 18) : null,
      onDeleted: isDeletable ? onDelete : null,
      visualDensity: VisualDensity.compact,
    );
  }
}

/// Кнопки действий формы
class _ActionButtons extends StatelessWidget {
  final bool isEditing;
  final AppLocalizations l10n;
  final VoidCallback onSubmit;
  final VoidCallback? onCancel;

  const _ActionButtons({
    required this.isEditing,
    required this.l10n,
    required this.onSubmit,
    this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: onSubmit,
            icon: Icon(isEditing ? Icons.save : Icons.add),
            label: Text(isEditing ? l10n.save : l10n.add),
          ),
        ),
        if (isEditing && onCancel != null) ...[
          const SizedBox(width: AppConstants.kSpacingUnit),
          Expanded(
            child: OutlinedButton.icon(
              onPressed: onCancel,
              icon: const Icon(Icons.close),
              label: Text(l10n.cancel),
            ),
          ),
        ],
      ],
    );
  }
}
