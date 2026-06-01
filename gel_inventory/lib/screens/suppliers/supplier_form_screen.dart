import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';
import '../../models/supplier.dart';
import '../../repositories/supplier_repository.dart';
import '../../widgets/common/app_scaffold.dart';

class SupplierFormScreen extends ConsumerStatefulWidget {
  final String? supplierId;
  const SupplierFormScreen({super.key, this.supplierId});

  @override
  ConsumerState<SupplierFormScreen> createState() => _SupplierFormScreenState();
}

class _SupplierFormScreenState extends ConsumerState<SupplierFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _contactCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  bool _loading = false;
  Supplier? _existing;

  bool get isNew => widget.supplierId == null || widget.supplierId == 'new';

  @override
  void initState() {
    super.initState();
    if (!isNew) _loadExisting();
  }

  Future<void> _loadExisting() async {
    setState(() => _loading = true);
    final all = await ref.read(supplierRepositoryProvider).getAll();
    _existing = all.where((s) => s.id == widget.supplierId).firstOrNull;
    if (_existing != null) {
      _nameCtrl.text = _existing!.name;
      _contactCtrl.text = _existing!.contact ?? '';
      _addressCtrl.text = _existing!.address ?? '';
    }
    setState(() => _loading = false);
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _contactCtrl.dispose();
    _addressCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    final supplier = Supplier(
      id: _existing?.id ?? const Uuid().v4(), // ignore: avoid_dynamic_calls
      name: _nameCtrl.text.trim(),
      contact: _contactCtrl.text.trim().isEmpty ? null : _contactCtrl.text.trim(),
      address: _addressCtrl.text.trim().isEmpty ? null : _addressCtrl.text.trim(),
      createdAt: _existing?.createdAt ?? DateTime.now(),
    );
    await ref.read(supplierRepositoryProvider).upsert(supplier);
    ref.invalidate(suppliersListProvider);
    if (mounted) context.go('/suppliers');
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: isNew ? 'New Supplier' : 'Edit Supplier',
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: _nameCtrl,
                      decoration: const InputDecoration(labelText: 'Name *'),
                      validator: (v) =>
                          v == null || v.trim().isEmpty ? 'Required' : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _contactCtrl,
                      decoration:
                          const InputDecoration(labelText: 'Contact (optional)'),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _addressCtrl,
                      decoration:
                          const InputDecoration(labelText: 'Address (optional)'),
                      maxLines: 2,
                    ),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        OutlinedButton(
                          onPressed: () => context.go('/suppliers'),
                          child: const Text('Cancel'),
                        ),
                        const SizedBox(width: 12),
                        FilledButton(
                          onPressed: _save,
                          child: Text(isNew ? 'Create' : 'Save'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
