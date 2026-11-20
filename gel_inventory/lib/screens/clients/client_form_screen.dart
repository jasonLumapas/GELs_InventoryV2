import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';
import '../../models/client.dart';
import '../../repositories/client_repository.dart';
import '../../widgets/common/app_scaffold.dart';

class ClientFormScreen extends ConsumerStatefulWidget {
  final String? clientId;
  const ClientFormScreen({super.key, this.clientId});

  @override
  ConsumerState<ClientFormScreen> createState() => _ClientFormScreenState();
}

class _ClientFormScreenState extends ConsumerState<ClientFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _contactCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  bool _loading = false;
  bool _isBlacklisted = false;
  Client? _existing;

  bool get isNew => widget.clientId == null || widget.clientId == 'new';

  @override
  void initState() {
    super.initState();
    if (!isNew) _loadExisting();
  }

  Future<void> _loadExisting() async {
    setState(() => _loading = true);
    final all = await ref.read(clientRepositoryProvider).getAll();
    _existing = all.where((c) => c.id == widget.clientId).firstOrNull;
    if (_existing != null) {
      _nameCtrl.text = _existing!.name;
      _contactCtrl.text = _existing!.contact ?? '';
      _addressCtrl.text = _existing!.address ?? '';
      _isBlacklisted = _existing!.isBlacklisted;
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
    final client = Client(
      id: _existing?.id ?? const Uuid().v4(),
      name: _nameCtrl.text.trim(),
      contact:
          _contactCtrl.text.trim().isEmpty ? null : _contactCtrl.text.trim(),
      address:
          _addressCtrl.text.trim().isEmpty ? null : _addressCtrl.text.trim(),
      isBlacklisted: _isBlacklisted,
      createdAt: _existing?.createdAt ?? DateTime.now(),
    );
    await ref.read(clientRepositoryProvider).upsert(client);
    ref.invalidate(clientsListProvider);
    if (mounted) context.go('/clients');
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: isNew ? 'New Client' : 'Edit Client',
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
                      decoration:
                          const InputDecoration(labelText: 'Store / Client Name *'),
                      validator: (v) =>
                          v == null || v.trim().isEmpty ? 'Required' : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _contactCtrl,
                      decoration: const InputDecoration(
                          labelText: 'Contact Number (optional)'),
                      keyboardType: TextInputType.phone,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _addressCtrl,
                      decoration:
                          const InputDecoration(labelText: 'Address (optional)'),
                      maxLines: 3,
                    ),
                    const SizedBox(height: 8),
                    SwitchListTile(
                      value: _isBlacklisted,
                      onChanged: (v) => setState(() => _isBlacklisted = v),
                      title: const Text('Blacklisted'),
                      subtitle: const Text(
                          'Client name will appear in red on new invoices'),
                      activeThumbColor: Colors.red,
                      activeTrackColor: Colors.red.shade200,
                      contentPadding: EdgeInsets.zero,
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        OutlinedButton(
                          onPressed: () => context.go('/clients'),
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
