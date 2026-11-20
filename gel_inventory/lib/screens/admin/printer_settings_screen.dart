import 'package:flutter/material.dart';
import 'package:printing/printing.dart';

import '../../core/services/printer_settings_service.dart';
import '../../widgets/common/app_scaffold.dart';

class PrinterSettingsScreen extends StatefulWidget {
  const PrinterSettingsScreen({super.key});

  @override
  State<PrinterSettingsScreen> createState() => _PrinterSettingsScreenState();
}

class _PrinterSettingsScreenState extends State<PrinterSettingsScreen> {
  List<Printer> _printers = [];
  bool _loading = true;

  // slot → saved printer name (null = use print dialog)
  final Map<String, String?> _selections = {};

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final printers = await PrinterSettingsService.listPrinters();
    final Map<String, String?> saved = {};
    for (final slot in PrinterSettingsService.slotLabels.keys) {
      saved[slot] = await PrinterSettingsService.loadName(slot);
    }
    setState(() {
      _printers   = printers;
      _selections.addAll(saved);
      _loading    = false;
    });
  }

  Future<void> _select(String slot, String? printerName) async {
    await PrinterSettingsService.save(slot, printerName);
    setState(() => _selections[slot] = printerName);
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Printer Settings',
      actions: [
        IconButton(
          icon: const Icon(Icons.refresh),
          tooltip: 'Refresh printer list',
          onPressed: _load,
        ),
      ],
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _printers.isEmpty
              ? const Center(
                  child: Text('No printers found.\n'
                      'Install a printer in Windows Settings and refresh.',
                      textAlign: TextAlign.center))
              : ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    // Info banner
                    Container(
                      padding: const EdgeInsets.all(12),
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: Theme.of(context)
                            .colorScheme
                            .surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.info_outline, size: 18,
                              color: Colors.grey),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Select "Use print dialog" to keep the system '
                              'print dialog for that document type.',
                              style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey.shade700),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // One row per slot
                    ...PrinterSettingsService.slotLabels.entries
                        .map((e) => _SlotRow(
                              slot: e.key,
                              label: e.value,
                              printers: _printers,
                              selectedName: _selections[e.key],
                              onChanged: (name) => _select(e.key, name),
                            )),
                  ],
                ),
    );
  }
}

class _SlotRow extends StatelessWidget {
  final String slot;
  final String label;
  final List<Printer> printers;
  final String? selectedName;
  final void Function(String?) onChanged;

  const _SlotRow({
    required this.slot,
    required this.label,
    required this.printers,
    required this.selectedName,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    // Validate saved name still exists in the printer list
    final validName = printers.any((p) => p.name == selectedName)
        ? selectedName
        : null;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          SizedBox(
            width: 160,
            child: Text(label,
                style: const TextStyle(fontWeight: FontWeight.w600)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: DropdownButtonFormField<String?>(
              initialValue: validName,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                isDense: true,
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              ),
              items: [
                const DropdownMenuItem<String?>(
                  value: null,
                  child: Text('Use print dialog',
                      style: TextStyle(color: Colors.grey)),
                ),
                ...printers.map((p) => DropdownMenuItem<String?>(
                      value: p.name,
                      child: Text(
                        p.name +
                            (p.isDefault ? '  ✓ default' : ''),
                        overflow: TextOverflow.ellipsis,
                      ),
                    )),
              ],
              onChanged: onChanged,
            ),
          ),
        ],
      ),
    );
  }
}
