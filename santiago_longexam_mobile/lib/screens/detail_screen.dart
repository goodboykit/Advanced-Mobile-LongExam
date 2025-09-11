import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../models/item_model.dart';
import '../services/item_service.dart';
import '../widgets/custom_input.dart';

class DetailScreen extends StatefulWidget {
  const DetailScreen({super.key, required this.item});
  final Item item;

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  late GlobalKey<FormState> _formKey;
  late TextEditingController _nameCtrl;
  late TextEditingController _descCtrl;
  late TextEditingController _photoCtrl;
  late TextEditingController _qtyTotalCtrl;
  late TextEditingController _qtyAvailCtrl;
  late bool _isActive;

  bool _isSaving = false;
  final _svc = ItemService();
  late Item _item;

  @override
  void initState() {
    super.initState();
    _formKey = GlobalKey<FormState>();
    _item = widget.item;
    _nameCtrl = TextEditingController(text: _item.name);
    _descCtrl = TextEditingController(text: _item.description.join('\n'));
    _photoCtrl = TextEditingController(text: _item.photoUrl);
    _qtyTotalCtrl = TextEditingController(text: _item.qtyTotal.toString());
    _qtyAvailCtrl = TextEditingController(text: _item.qtyAvailable.toString());
    _isActive = (_item.isActive.toString().toLowerCase() == "true");
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _descCtrl.dispose();
    _photoCtrl.dispose();
    _qtyTotalCtrl.dispose();
    _qtyAvailCtrl.dispose();
    super.dispose();
  }

  List<String> _parseDesc(String raw) => raw
      .split(RegExp(r'[\n,]'))
      .map((s) => s.trim())
      .where((s) => s.isNotEmpty)
      .toList();

  int _toInt(TextEditingController c, {int fallback = 0}) {
    final v = int.tryParse(c.text.trim());
    return v == null || v < 0 ? fallback : v;
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final total = _toInt(_qtyTotalCtrl, fallback: 0);
    final avail = _toInt(_qtyAvailCtrl, fallback: 0);
    if (avail > total) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Qty Available cannot exceed Qty Total')),
      );
      return;
    }

    final payload = {
      'name': _nameCtrl.text.trim(),
      'description': _parseDesc(_descCtrl.text),
      'photoUrl': _photoCtrl.text.trim(),
      'qtyTotal': total,
      'qtyAvailable': avail,
      'isActive': _isActive,
    };

    setState(() => _isSaving = true);
    try {
      final res = await _svc.updateItem(_item.uid, payload);
      final updated = (res['item'] ?? res);
      final updatedItem = Item.fromJson(updated);

      setState(() => _item = updatedItem);

      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Item updated.')));
      Navigator.of(context).pop(updatedItem);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Failed to update: \$e')));
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<void> _confirmDelete() async {
    final yes = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete Item'),
        content: const Text('This action cannot be undone. Continue?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (yes != true) return;

    setState(() => _isSaving = true);
    try {
      await _svc.deleteItem(_item.uid, {});
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Item deleted.')));
      Navigator.of(context).pop({'deleted': true, 'id': _item.uid});
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Failed to delete: \$e')));
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Widget _imagePreview() {
    final url = _photoCtrl.text.trim();
    if (url.isEmpty) {
      return Container(
        height: 160.h,
        decoration: BoxDecoration(
          color: Colors.grey.shade200,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade300),
        ),
        alignment: Alignment.center,
        child: const Icon(Icons.inventory_2_outlined, size: 48),
      );
    }
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Image(
        image: NetworkImage(url),
        height: 160.h,
        width: double.infinity,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => Container(
          height: 160.h,
          decoration: BoxDecoration(
            color: Colors.grey.shade200,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade300),
          ),
          alignment: Alignment.center,
          child: const Icon(Icons.broken_image_outlined, size: 48),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_item.name.isEmpty ? 'Item' : _item.name),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _imagePreview(),
                SizedBox(height: 12.h),
                URLInput(
                  label: 'Photo URL',
                  hint: 'Enter image URL (optional)',
                  controller: _photoCtrl,
                  isRequired: false,
                  onChanged: (_) => setState(() {}), // refresh preview
                ),
                SizedBox(height: 12.h),
                TextFormField(
                  controller: _nameCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Name',
                    border: OutlineInputBorder(),
                  ),
                  validator: (v) =>
                      (v == null || v.trim().isEmpty) ? 'Required' : null,
                ),
                SizedBox(height: 12.h),
                TextFormField(
                  controller: _descCtrl,
                  minLines: 3,
                  maxLines: 6,
                  decoration: const InputDecoration(
                    labelText: 'Description (one per line or comma-separated)',
                    border: OutlineInputBorder(),
                    alignLabelWithHint: true,
                  ),
                  validator: (v) => _parseDesc(v ?? '').isEmpty
                      ? 'Add at least one line'
                      : null,
                ),
                SizedBox(height: 12.h),
                Row(
                  children: [
                    Expanded(
                      child: NumberInput(
                        label: 'Qty Total',
                        hint: 'Enter total quantity',
                        controller: _qtyTotalCtrl,
                        min: 0,
                        max: 999999,
                      ),
                    ),
                    SizedBox(width: 10.w),
                    Expanded(
                      child: NumberInput(
                        label: 'Qty Available',
                        hint: 'Enter available quantity',
                        controller: _qtyAvailCtrl,
                        min: 0,
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) {
                            return 'Available quantity is required';
                          }
                          final a = int.tryParse(v.trim());
                          final t = int.tryParse(_qtyTotalCtrl.text.trim());
                          if (a == null || a < 0) return 'Must be a valid number';
                          if (t != null && a > t) return 'Cannot exceed total quantity';
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8.h),
                SwitchListTile.adaptive(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Active'),
                  value: _isActive,
                  onChanged: (v) => setState(() => _isActive = v),
                ),
                SizedBox(height: 16.h),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _isSaving ? null : _save,
                    icon: _isSaving
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.save),
                    label: Text(_isSaving ? 'Saving...' : 'Save Changes'),
                  ),
                ),
                SizedBox(height: 8.h),
                // Only show delete button for inactive items
                if (!_item.isActive)
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: _isSaving ? null : _confirmDelete,
                      icon: const Icon(Icons.delete_outline),
                      label: const Text('Delete Item'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}