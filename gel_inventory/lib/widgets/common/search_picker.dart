import 'package:flutter/material.dart';

/// Shows a dialog with a live-filter search field above a scrollable list.
/// Returns the selected [T] or null if dismissed.
Future<T?> showSearchPicker<T>({
  required BuildContext context,
  required String title,
  required List<T> items,
  required String Function(T) labelOf,
  String? Function(T)? subtitleOf,
  TextStyle? Function(T)? subtitleStyleOf,
  Widget? Function(T)? leadingOf,
}) async {
  return showDialog<T>(
    context: context,
    builder: (ctx) => _SearchPickerDialog<T>(
      title: title,
      items: items,
      labelOf: labelOf,
      subtitleOf: subtitleOf,
      subtitleStyleOf: subtitleStyleOf,
      leadingOf: leadingOf,
    ),
  );
}

class _SearchPickerDialog<T> extends StatefulWidget {
  final String title;
  final List<T> items;
  final String Function(T) labelOf;
  final String? Function(T)? subtitleOf;
  final TextStyle? Function(T)? subtitleStyleOf;
  final Widget? Function(T)? leadingOf;

  const _SearchPickerDialog({
    required this.title,
    required this.items,
    required this.labelOf,
    this.subtitleOf,
    this.subtitleStyleOf,
    this.leadingOf,
  });

  @override
  State<_SearchPickerDialog<T>> createState() => _SearchPickerDialogState<T>();
}

class _SearchPickerDialogState<T> extends State<_SearchPickerDialog<T>> {
  final _ctrl = TextEditingController();
  List<T> _filtered = [];

  @override
  void initState() {
    super.initState();
    _filtered = List.of(widget.items);
    _ctrl.addListener(_onSearch);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _onSearch() {
    final q = _ctrl.text.toLowerCase();
    setState(() {
      _filtered = widget.items
          .where((i) => widget.labelOf(i).toLowerCase().contains(q))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 480, maxHeight: 520),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Text(widget.title,
                  style: Theme.of(context).textTheme.titleMedium),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: TextField(
                controller: _ctrl,
                autofocus: true,
                decoration: const InputDecoration(
                  hintText: 'Search…',
                  prefixIcon: Icon(Icons.search),
                  isDense: true,
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: _filtered.isEmpty
                  ? const Center(child: Text('No results'))
                  : ListView.separated(
                      itemCount: _filtered.length,
                      separatorBuilder: (_, _) => const Divider(height: 1),
                      itemBuilder: (_, i) {
                        final item = _filtered[i];
                        final sub = widget.subtitleOf?.call(item);
                        final subStyle = widget.subtitleStyleOf?.call(item);
                        final leading = widget.leadingOf?.call(item);
                        return ListTile(
                          leading: leading,
                          title: Text(widget.labelOf(item)),
                          subtitle: sub != null
                              ? Text(sub, style: subStyle)
                              : null,
                          onTap: () => Navigator.pop(context, item),
                        );
                      },
                    ),
            ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
