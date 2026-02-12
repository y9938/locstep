import '../models/node.dart';
import '../l10n/app_localizations.dart';
import 'pathfinder.dart';

/// Человекочитаемая инструкция
class Instruction {
  final String text;
  final String? detail;
  final Node? targetNode; // Целевой узел для доступа к изображениям и 3D-турам

  Instruction({required this.text, this.detail, this.targetNode});

  @override
  String toString() => text;
}

/// Генератор инструкций из пути
class InstructionBuilder {
  final AppLocalizations l10n;

  InstructionBuilder(this.l10n);

  /// Строит список инструкций по маршруту
  List<Instruction> build(PathResult path) {
    if (path.isEmpty) return [Instruction(text: l10n.noRoute)];

    final instructions = <Instruction>[];
    final nodes = path.nodes;

    for (int i = 0; i < nodes.length - 1; i++) {
      final to = nodes[i + 1];

      // Минималистичный формат: только номер и название узла
      instructions.add(Instruction(
        text: '${i + 1}. ${to.name}',
        detail: null, // Убрали detail - дублирует название
        targetNode: to, // Передаем целевой узел для доступа к изображениям и 3D-турам
      ));
    }

    return instructions;
  }

  /// Краткая сводка маршрута
  String buildSummary(PathResult path, String targetName) {
    if (path.isEmpty) return l10n.noRoute;

    final start = path.nodes.first;
    final steps = path.steps;

    return '${l10n.from} ${start.name} ${l10n.to} $targetName. ${l10n.steps}: $steps';
  }
}
