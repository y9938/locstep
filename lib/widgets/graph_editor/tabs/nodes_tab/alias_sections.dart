import 'package:flutter/material.dart';
import '../../../../app_constants.dart';
import '../../../../l10n/app_localizations.dart';
import 'node_form_controller.dart';

/// Секция авто-алиасов с freeze-режимом и toggle
class AutoAliasesSection extends StatelessWidget {
  final NodeFormController controller;

  const AutoAliasesSection({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final autoAliases = controller.currentAutoAliases;
    final hasName = controller.nodeNameController.text.isNotEmpty;
    final isFrozen = controller.isAutoAliasesFrozen;
    final isEnabled = controller.autoAliasesEnabled;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Заголовок с кнопками управления
        Row(
          children: [
            Text(
              l10n.autoAliases,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
            const Spacer(),
            // Кнопка Freeze
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
            // Кнопка Toggle
            TextButton.icon(
              icon: Icon(isEnabled ? Icons.auto_awesome : Icons.auto_awesome_outlined, size: 18),
              label: Text(isEnabled ? l10n.on : l10n.off),
              onPressed: controller.toggleAutoAliases,
              style: TextButton.styleFrom(
                visualDensity: VisualDensity.compact,
                padding: const EdgeInsets.symmetric(horizontal: AppConstants.kSpacingUnit),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppConstants.kSpacingUnit),
        
        // Контент секции
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

/// Секция кастомных алиасов
class CustomAliasesSection extends StatelessWidget {
  final NodeFormController controller;

  const CustomAliasesSection({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final customAliases = controller.customAliases;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Заголовок
        Text(
          l10n.customAliases,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: AppConstants.kSpacingUnit),

        // Список кастомных алиасов
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
        
        // Поле добавления алиаса
        TextField(
          controller: controller.customAliasController,
          textInputAction: TextInputAction.done,
          decoration: InputDecoration(
            hintText: l10n.addAliasHint,
            border: const OutlineInputBorder(),
            contentPadding: AppConstants.kInputContentPadding,
            suffixIcon: IconButton(
              onPressed: () => _addAlias(controller),
              icon: const Icon(Icons.add),
              tooltip: l10n.addAlias,
            ),
          ),
          onSubmitted: (_) => _addAlias(controller),
        ),
      ],
    );
  }

  void _addAlias(NodeFormController controller) {
    final alias = controller.customAliasController.text.trim();
    if (alias.isNotEmpty) {
      controller.addCustomAlias(alias);
      controller.customAliasController.clear();
    }
  }
}

/// Чип алиаса (общий для авто и кастомных)
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
