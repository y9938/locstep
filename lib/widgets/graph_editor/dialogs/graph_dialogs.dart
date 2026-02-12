import 'package:flutter/material.dart';
import '../../../l10n/app_localizations.dart';
import '../../../models/graph.dart';
import '../../../app_constants.dart';

/// Диалоги для управления графами
/// 
/// Ответственность:
/// - Создание нового графа
/// - Переименование графа
/// - Подтверждение удаления графа
class GraphDialogs {
  /// Показывает диалог создания нового графа
  /// 
  /// Возвращает название нового графа или null, если отменено
  static Future<String?> showCreateDialog(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;
    final controller = TextEditingController();

    return showDialog<String>(
      context: context,
      builder: (context) => _buildAdaptiveDialog(
        context: context,
        title: l10n.createNewGraph,
        content: TextField(
          controller: controller,
          decoration: InputDecoration(
            labelText: l10n.graphName,
            hintText: l10n.graphNameHint,
          ),
          autofocus: true,
          onSubmitted: (value) => Navigator.pop(context, value.trim()),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, null),
            child: Text(l10n.cancel),
          ),
          ElevatedButton(
            onPressed: () {
              final name = controller.text.trim();
              if (name.isNotEmpty) {
                Navigator.pop(context, name);
              }
            },
            child: Text(l10n.create),
          ),
        ],
      ),
    );
  }

  /// Показывает диалог переименования графа
  /// 
  /// Возвращает новое название или null, если отменено
  static Future<String?> showRenameDialog(
    BuildContext context,
    String currentName,
  ) async {
    final l10n = AppLocalizations.of(context)!;
    final controller = TextEditingController(text: currentName);

    return showDialog<String>(
      context: context,
      builder: (context) => _buildAdaptiveDialog(
        context: context,
        title: l10n.renameGraph,
        content: TextField(
          controller: controller,
          decoration: InputDecoration(labelText: l10n.newName),
          autofocus: true,
          onSubmitted: (value) => Navigator.pop(context, value.trim()),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, null),
            child: Text(l10n.cancel),
          ),
          ElevatedButton(
            onPressed: () {
              final name = controller.text.trim();
              if (name.isNotEmpty) {
                Navigator.pop(context, name);
              }
            },
            child: Text(l10n.save),
          ),
        ],
      ),
    );
  }

  /// Показывает диалог подтверждения удаления графа
  /// 
  /// Возвращает true, если удаление подтверждено
  static Future<bool> showDeleteConfirmation(
    BuildContext context,
    String graphName,
  ) async {
    final l10n = AppLocalizations.of(context)!;

    return await showDialog<bool>(
          context: context,
          builder: (context) => _buildAdaptiveDialog(
            context: context,
            title: l10n.deleteGraphTitle,
            content: Text('${l10n.deleteGraphConfirm} "$graphName"?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text(l10n.cancel),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: Text(
                  l10n.delete,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              ),
            ],
          ),
        ) ??
        false;
  }

  /// Строит адаптивный диалог с ограничением ширины на больших экранах
  static Widget _buildAdaptiveDialog({
    required BuildContext context,
    required String title,
    required Widget content,
    required List<Widget> actions,
  }) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    
    // На больших экранах ограничиваем ширину диалога
    if (screenWidth > AppConstants.kDialogMaxWidth + 64) {
      return Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: AppConstants.kDialogMaxWidth),
          child: AlertDialog(
            title: Text(title),
            content: content,
            actions: actions,
          ),
        ),
      );
    }
    
    return AlertDialog(
      title: Text(title),
      content: content,
      actions: actions,
    );
  }
}

/// Виджет статуса операции
/// 
/// Ответственность: показ временного статусного сообщения
class StatusBar extends StatelessWidget {
  final String message;

  const StatusBar({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Theme.of(context).colorScheme.primaryContainer,
      child: SafeArea(
        top: false,
        bottom: true,
        child: Container(
          width: double.infinity,
          padding: AppConstants.kInputContentPadding,
          child: Text(
            message,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
          ),
        ),
      ),
    );
  }
}

/// Виджет статистики графа
/// 
/// Ответственность: показ количества узлов и связей
class GraphStatsBar extends StatelessWidget {
  final BuildingGraph graph;

  const GraphStatsBar({super.key, required this.graph});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Container(
      padding: const EdgeInsets.all(AppConstants.kSpacingUnit),
      color: Theme.of(context).colorScheme.surfaceContainer,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('${l10n.nodes}: ${graph.nodeCount}'),
          const SizedBox(width: 20),
          Text('${l10n.connections}: ${graph.connectionCount}'),
        ],
      ),
    );
  }
}
