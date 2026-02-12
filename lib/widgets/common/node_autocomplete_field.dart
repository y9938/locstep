import 'dart:async';

import 'package:flutter/material.dart';
import '../../app_constants.dart';
import '../../models/graph.dart';
import '../../models/node.dart';

/// Переиспользуемое поле автодополнения для выбора узла графа
///
/// Ищет по имени, ID и алиасам узла (использует node.matches())
class NodeAutocompleteField extends StatefulWidget {
  final BuildingGraph graph;
  final TextEditingController controller;
  final String? labelText;
  final String? hintText;
  final Widget? prefixIcon;
  final void Function(Node node)? onSelected;
  final String? Function(String?)? validator;
  final List<String> excludeNodeIds;

  const NodeAutocompleteField({
    super.key,
    required this.graph,
    required this.controller,
    this.labelText,
    this.hintText,
    this.prefixIcon,
    this.onSelected,
    this.validator,
    this.excludeNodeIds = const [],
  });

  @override
  State<NodeAutocompleteField> createState() => _NodeAutocompleteFieldState();
}

class _NodeAutocompleteFieldState extends State<NodeAutocompleteField> {
  late List<Node> _filteredNodes;
  final FocusNode _focusNode = FocusNode();
  Timer? _clearListTimer;

  @override
  void initState() {
    super.initState();
    _filteredNodes = [];
    widget.controller.addListener(_filterNodes);
    _focusNode.addListener(_filterNodes);
  }

  @override
  void dispose() {
    _clearListTimer?.cancel();
    _clearListTimer = null;
    widget.controller.removeListener(_filterNodes);
    _focusNode.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant NodeAutocompleteField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.graph != widget.graph || oldWidget.excludeNodeIds != widget.excludeNodeIds) {
      _filterNodes();
    }
  }

  void _filterNodes() {
    if (!_focusNode.hasFocus || widget.controller.text.isEmpty) {
      _clearListTimer?.cancel();
      _clearListTimer = Timer(const Duration(milliseconds: 150), () {
        if (mounted && !_focusNode.hasFocus) {
          setState(() {
            _filteredNodes = [];
          });
        }
        _clearListTimer = null;
      });
      return;
    }

    _clearListTimer?.cancel();
    _clearListTimer = null;

    final query = widget.controller.text.toLowerCase();
    final availableNodes = widget.graph.allNodes
        .where((node) => !widget.excludeNodeIds.contains(node.id) && node.matches(query))
        .toList();

    setState(() {
      _filteredNodes = availableNodes;
    });
  }

  void _selectNode(Node node) {
    widget.controller.text = node.name;
    widget.controller.selection = TextSelection.fromPosition(
      TextPosition(offset: widget.controller.text.length),
    );
    widget.onSelected?.call(node);
    setState(() {
      _filteredNodes = [];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        TextFormField(
          controller: widget.controller,
          focusNode: _focusNode,
          validator: widget.validator,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w500),
          decoration: InputDecoration(
            labelText: widget.labelText,
            hintText: widget.hintText,
            prefixIcon: widget.prefixIcon,
            filled: true,
            fillColor: Theme.of(context).colorScheme.surface,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppConstants.kCardBorderRadius),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppConstants.kCardBorderRadius),
              borderSide: BorderSide(color: Theme.of(context).colorScheme.outline),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppConstants.kCardBorderRadius),
              borderSide: BorderSide(color: Theme.of(context).colorScheme.primary, width: 2),
            ),
            contentPadding: AppConstants.kInputContentPadding,
            suffixIcon: widget.controller.text.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear, size: 20),
                    onPressed: () {
                      widget.controller.clear();
                      setState(() {
                        _filteredNodes = [];
                      });
                    },
                  )
                : null,
          ),
          onChanged: (value) {
            // Вызываем фильтрацию при изменении текста
            _filterNodes();
          },
          onTap: () {
            // При клике на поле показываем список, если есть текст
            if (widget.controller.text.isNotEmpty) {
              _filterNodes();
            }
          },
        ),
        if (_filteredNodes.isNotEmpty)
          AnimatedSize(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeInOut,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 200),
              child: Card(
                margin: const EdgeInsets.only(top: AppConstants.kSpacingTiny),
                elevation: 4,
                child: ListView.builder(
                  padding: EdgeInsets.zero,
                  shrinkWrap: true,
                  itemCount: _filteredNodes.length,
                  itemBuilder: (context, index) {
                    final node = _filteredNodes[index];
                    return ListTile(
                      title: Text(
                        node.name,
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                      subtitle: node.aliases.isNotEmpty
                          ? Text(
                              node.aliases.join(', '),
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                                  ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            )
                          : null,
                      onTap: () {
                        _selectNode(node);
                      },
                    );
                  },
                ),
              ),
            ),
          ),
      ],
    );
  }
}
