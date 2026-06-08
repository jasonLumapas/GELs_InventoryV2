import 'package:flutter/material.dart';

/// A named filter option for [showSearchPicker].
/// When [filters] are provided the dialog shows a chip row that narrows
/// the list to items matching [test].
class SearchFilter<T> {
  final String label;
  final bool Function(T) test;
  const SearchFilter({required this.label, required this.test});
}

/// Shows a dialog with a live-filter search field above a scrollable list.
///
/// Single-pick mode (default): returns the selected [T] or null if dismissed.
///
/// Multi-pick mode: when [onSelected] is provided, tapping an item calls the
/// callback and removes the item from the list without closing the dialog.
/// The dialog stays open until the user taps "Done" or dismisses it.
Future<T?> showSearchPicker<T>({
  required BuildContext context,
  required String title,
  required List<T> items,
  required String Function(T) labelOf,
  String Function(T)? searchableOf,
  String? Function(T)? subtitleOf,
  TextStyle? Function(T)? subtitleStyleOf,
  Widget? Function(T)? leadingOf,
  bool Function(T)? isDisabledOf,
  void Function(T)? onSelected, // multi-pick mode when provided
  List<SearchFilter<T>>? filters,
  // Called when the user taps the add button; receives the current item list
  // for duplicate checking. Return the new item to insert it into the list,
  // or null to cancel.
  Future<T?> Function(List<T> existing)? onAdd,
}) async {
  return showDialog<T>(
    context: context,
    builder: (ctx) => _SearchPickerDialog<T>(
      title: title,
      items: items,
      labelOf: labelOf,
      searchableOf: searchableOf,
      subtitleOf: subtitleOf,
      subtitleStyleOf: subtitleStyleOf,
      leadingOf: leadingOf,
      isDisabledOf: isDisabledOf,
      onSelected: onSelected,
      filters: filters,
      onAdd: onAdd,
    ),
  );
}

class _SearchPickerDialog<T> extends StatefulWidget {
  final String title;
  final List<T> items;
  final String Function(T) labelOf;
  final String Function(T)? searchableOf;
  final String? Function(T)? subtitleOf;
  final TextStyle? Function(T)? subtitleStyleOf;
  final Widget? Function(T)? leadingOf;
  final bool Function(T)? isDisabledOf;
  final void Function(T)? onSelected;
  final List<SearchFilter<T>>? filters;
  final Future<T?> Function(List<T> existing)? onAdd;

  const _SearchPickerDialog({
    required this.title,
    required this.items,
    required this.labelOf,
    this.searchableOf,
    this.subtitleOf,
    this.subtitleStyleOf,
    this.leadingOf,
    this.isDisabledOf,
    this.onSelected,
    this.filters,
    this.onAdd,
  });

  @override
  State<_SearchPickerDialog<T>> createState() => _SearchPickerDialogState<T>();
}

class _SearchPickerDialogState<T> extends State<_SearchPickerDialog<T>> {
  final _ctrl = TextEditingController();
  late List<T> _remaining;
  List<T> _filtered = [];
  final _selected = <T>{};
  SearchFilter<T>? _activeFilter;

  bool get _multiPick => widget.onSelected != null;

  @override
  void initState() {
    super.initState();
    _remaining = List.of(widget.items);
    _filtered  = List.of(_remaining);
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
      _filtered = _remaining.where((i) {
        final searchable =
            (widget.searchableOf ?? widget.labelOf)(i).toLowerCase();
        if (!searchable.contains(q)) return false;
        if (_activeFilter != null && !_activeFilter!.test(i)) return false;
        return true;
      }).toList();
    });
  }

  void _onTap(T item) {
    if (_multiPick) {
      widget.onSelected!(item);
      setState(() => _selected.add(item));
    } else {
      Navigator.pop(context, item);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 480, maxHeight: 520),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 8, 8),
              child: Row(
                children: [
                  Expanded(
                    child: Text(widget.title,
                        style: Theme.of(context).textTheme.titleMedium),
                  ),
                  if (widget.onAdd != null)
                    IconButton(
                      icon: const Icon(Icons.add),
                      tooltip: 'Add new',
                      onPressed: () async {
                        final newItem = await widget.onAdd!(_remaining);
                        if (newItem != null) {
                          setState(() {
                            _remaining.insert(0, newItem);
                            _onSearch();
                          });
                        }
                      },
                    ),
                ],
              ),
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
            if (widget.filters != null && widget.filters!.isNotEmpty) ...[
              const SizedBox(height: 6),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Row(
                  children: [
                    const Text('Supplier:',
                        style: TextStyle(fontSize: 13, color: Colors.grey)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: DropdownButton<SearchFilter<T>?>(
                        value: _activeFilter,
                        isDense: true,
                        isExpanded: true,
                        underline: const SizedBox(),
                        items: [
                          const DropdownMenuItem(
                              value: null, child: Text('All Suppliers')),
                          ...widget.filters!.map((f) => DropdownMenuItem(
                                value: f,
                                child: Text(f.label),
                              )),
                        ],
                        onChanged: (f) {
                          setState(() => _activeFilter = f);
                          _onSearch();
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ],
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
                        final disabled =
                            widget.isDisabledOf?.call(item) ?? false;
                        final checked =
                            _multiPick && _selected.contains(item);
                        return ListTile(
                          enabled: !disabled,
                          leading: leading,
                          title: Text(widget.labelOf(item)),
                          subtitle: sub != null
                              ? Text(sub, style: subStyle)
                              : null,
                          trailing: checked
                              ? Icon(Icons.check_circle,
                                  color: Theme.of(context).colorScheme.primary)
                              : null,
                          onTap: disabled ? null : () => _onTap(item),
                        );
                      },
                    ),
            ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(_multiPick ? 'Done' : 'Cancel'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
