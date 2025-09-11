import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../models/item_model.dart';
import '../services/item_service.dart';
import '../widgets/custom_text.dart';
import '../widgets/custom_input.dart';
import 'detail_screen.dart';

class ItemScreen extends StatefulWidget {
  const ItemScreen({super.key});

  @override
  State<ItemScreen> createState() => _ItemScreenState();
}

class _ItemScreenState extends State<ItemScreen> {
  final _svc = ItemService();
  final List<Item> _items = [];
  late Future<void> _loadFuture;

  @override
  void initState() {
    super.initState();
    _loadFuture = _loadItems();
  }

  Future<void> _loadItems() async {
    try {
      final res = await _svc.getAllItem();
      final list =
          (res['items'] ?? res) as dynamic; // supports {items:[...]} OR [...]
      final List data = list is List ? list : (list['data'] ?? []);
      _items
        ..clear()
        ..addAll(data.map<Item>((e) => Item.fromJson(e)));
      
      // If no items from server, add some dummy items for testing
      if (_items.isEmpty) {
        _addDummyItems();
      }
    } catch (e) {
      debugPrint('Error loading items: $e');
      // Add dummy items if server fails
      _addDummyItems();
    }
  }

  void _addDummyItems() {
    final dummyItems = [
      {'uid': '1', 'name': 'Test Item 1', 'description': ['First test item'], 'photoUrl': '', 'qtyTotal': 10, 'qtyAvailable': 8, 'isActive': true},
      {'uid': '2', 'name': 'Test Item 2', 'description': ['Second test item'], 'photoUrl': '', 'qtyTotal': 5, 'qtyAvailable': 3, 'isActive': true},
      {'uid': '3', 'name': 'Test Item 3', 'description': ['Third test item'], 'photoUrl': '', 'qtyTotal': 15, 'qtyAvailable': 12, 'isActive': true},
      {'uid': '4', 'name': 'Test Item 4', 'description': ['Fourth test item'], 'photoUrl': '', 'qtyTotal': 20, 'qtyAvailable': 18, 'isActive': true},
      {'uid': '5', 'name': 'Test Item 5', 'description': ['Fifth test item'], 'photoUrl': '', 'qtyTotal': 7, 'qtyAvailable': 5, 'isActive': true},
      {'uid': '6', 'name': 'Test Item 6', 'description': ['Sixth test item'], 'photoUrl': '', 'qtyTotal': 12, 'qtyAvailable': 10, 'isActive': true},
      {'uid': '7', 'name': 'Test Item 7', 'description': ['Seventh test item'], 'photoUrl': '', 'qtyTotal': 25, 'qtyAvailable': 20, 'isActive': true},
      {'uid': '8', 'name': 'Test Item 8', 'description': ['Eighth test item'], 'photoUrl': '', 'qtyTotal': 30, 'qtyAvailable': 25, 'isActive': true},
    ];
    
    _items.addAll(dummyItems.map<Item>((e) => Item.fromJson(e)));
  }

  // ---- Add Item Dialog ----
  Future<void> _openAddItemDialog() async {
    final nameCtrl = TextEditingController();
    final descCtrl = TextEditingController();
    final photoCtrl = TextEditingController();
    final qtyTotalCtrl = TextEditingController();
    final qtyAvailCtrl = TextEditingController();
    final formKey = GlobalKey<FormState>();
    bool isSaving = false;
    bool isActive = true;

    List<String> _parseDesc(String raw) => raw
        .split(RegExp(r'[\n,]'))
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList();

    String? _req(String? v) =>
        (v == null || v.trim().isEmpty) ? 'Required' : null;

    await showDialog<void>(
      context: context,
      barrierDismissible: !isSaving,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setLocal) {
            Future<void> _save() async {
              if (isSaving) return;
              if (!formKey.currentState!.validate()) return;
              setLocal(() => isSaving = true);

              try {
                final payload = {
                  'name': nameCtrl.text.trim(),
                  'description': _parseDesc(descCtrl.text),
                  'photoUrl': photoCtrl.text.trim(),
                  'qtyTotal': int.parse(qtyTotalCtrl.text.trim()),
                  'qtyAvailable': int.parse(qtyAvailCtrl.text.trim()),
                  'isActive': isActive,
                };

                final res = await _svc.createItem(payload);
                final created = (res['item'] ?? res);
                final newItem = Item.fromJson(created);

                setState(() => _items.insert(0, newItem));

                if (ctx.mounted) Navigator.of(ctx).pop();
                if (mounted) {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(const SnackBar(content: Text('Item added.')));
                }
              } catch (e) {
                setLocal(() => isSaving = false);
                if (mounted) {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text('Failed to add: $e')));
                }
              }
            }

            return AlertDialog(
              title: Row(
                children: [
                  IconButton(
                    onPressed: isSaving ? null : () => Navigator.of(ctx).pop(),
                    icon: const Icon(Icons.close),
                    tooltip: 'Close',
                  ),
                  const Expanded(
                    child: Text('Add New Item'),
                  ),
                ],
              ),
              content: SizedBox(
                width: MediaQuery.of(ctx).size.width * 0.9,
                height: MediaQuery.of(ctx).size.height * 0.6,
                child: Form(
                  key: formKey,
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TextFormField(
                        controller: nameCtrl,
                        decoration: const InputDecoration(
                          labelText: 'Name',
                          border: OutlineInputBorder(),
                        ),
                        validator: _req,
                      ),
                      SizedBox(height: 10.h),
                      TextFormField(
                        controller: descCtrl,
                        minLines: 2,
                        maxLines: 5,
                        decoration: const InputDecoration(
                          labelText: 'Description (one per line or comma-sep)',
                          border: OutlineInputBorder(),
                          alignLabelWithHint: true,
                        ),
                        validator: (v) => _parseDesc(v ?? '').isEmpty
                            ? 'Add at least one line'
                            : null,
                      ),
                      SizedBox(height: 10.h),
                      URLInput(
                        label: 'Photo URL',
                        hint: 'Enter image URL (optional)',
                        controller: photoCtrl,
                        isRequired: false,
                      ),
                      SizedBox(height: 10.h),
                      Row(
                        children: [
                          Expanded(
                            child: NumberInput(
                              label: 'Qty Total',
                              hint: 'Enter total quantity',
                              controller: qtyTotalCtrl,
                              min: 0,
                              max: 999999,
                            ),
                          ),
                          SizedBox(width: 10.w),
                          Expanded(
                            child: NumberInput(
                              label: 'Qty Available',
                              hint: 'Enter available quantity',
                              controller: qtyAvailCtrl,
                              min: 0,
                              validator: (v) {
                                if (v == null || v.trim().isEmpty) {
                                  return 'Available quantity is required';
                                }
                                final a = int.tryParse(v.trim());
                                final t = int.tryParse(qtyTotalCtrl.text.trim());
                                if (a == null || a < 0) return 'Must be a valid number';
                                if (t != null && a > t) return 'Cannot exceed total quantity';
                                return null;
                              },
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 6.h),
                      SwitchListTile.adaptive(
                        contentPadding: EdgeInsets.zero,
                        title: const Text('Active'),
                        value: isActive,
                        onChanged: (val) => setLocal(() => isActive = val),
                      ),
                      ],
                    ),
                  ),
                ),
              ),
              actions: [
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: isSaving ? null : () => Navigator.of(ctx).pop(),
                        child: const Text('Cancel'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: isSaving ? null : _save,
                        icon: isSaving
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Icon(Icons.save),
                        label: Text(isSaving ? 'Saving...' : 'Save'),
                      ),
                    ),
                  ],
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _leadingThumb(Item item) {
    final url = item.photoUrl.trim();
    const double imageSize = 56.0; // Fixed size instead of responsive
    
    if (url.isEmpty) {
      return Container(
        width: imageSize,
        height: imageSize,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: const Icon(Icons.inventory_2_outlined),
      );
    }
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Image(
        image: NetworkImage(url),
        width: imageSize,
        height: imageSize,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => Container(
          width: imageSize,
          height: imageSize,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: const Icon(Icons.broken_image_outlined),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: _openAddItemDialog,
        child: const Icon(Icons.add),
      ),
      body: SafeArea(
        child: FutureBuilder<void>(
          future: _loadFuture,
          builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return Center(
              child: Padding(
                padding: EdgeInsets.only(top: 40.h),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator.adaptive(strokeWidth: 3.sp),
                    SizedBox(height: 10.h),
                    const CustomText(text: 'Loading items...'),
                  ],
                ),
              ),
            );
          }

          if (snap.hasError) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: CustomText(text: 'Failed to load items'),
              ),
            );
          }

          if (_items.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: CustomText(text: 'No items to display...'),
              ),
            );
          }

          return ListView.builder(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: EdgeInsets.only(
              top: 10.h,
              bottom: 100.h, // Extra bottom padding for FAB
              left: 20.w,
              right: 20.w,
            ),
            itemCount: _items.length,
            itemBuilder: (context, index) {
              final item = _items[index];
              final subtitle = item.description.isNotEmpty
                  ? item.description.first
                  : '';
              return Card(
                child: InkWell(
                  onTap: () async {
                    //TODO: navigate to detail if needed
                    debugPrint('Open item ${item.uid}');
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => DetailScreen(item: item),
                      ),
                    );

                    // If deleted:
                    if (result is Map && result['deleted'] == true) {
                      final id = result['id'] as String;
                      setState(() {
                        _items.removeWhere((e) => e.uid == id);
                      });
                    }

                    // If updated:
                    if (result is Item) {
                      setState(() {
                        final i = _items.indexWhere((e) => e.uid == result.uid);
                        if (i != -1) _items[i] = result;
                      });
                    }
                  },
                  child: ListTile(
                    leading: _leadingThumb(item),
                    title: CustomText(
                      text: item.name.isEmpty ? 'Untitled' : item.name,
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    subtitle: CustomText(
                      text: subtitle, 
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    trailing: GestureDetector(
                      onTap: () => debugPrint('More ${item.uid}'),
                      child: const Icon(Icons.keyboard_arrow_right),
                    ),
                  ),
                ),
              );
            },
          );
        },
        ),
      ),
    );
  }
}