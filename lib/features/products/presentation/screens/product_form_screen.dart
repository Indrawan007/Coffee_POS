import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/database/app_database.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_text_field.dart';
import '../../../categories/presentation/providers/category_provider.dart';
import '../../data/datasources/product_datasource.dart';
import '../providers/product_provider.dart';

class ProductFormScreen extends ConsumerStatefulWidget {
  const ProductFormScreen({super.key, this.productId});
  final int? productId;

  @override
  ConsumerState<ProductFormScreen> createState() =>
    _ProductFormScreenState();
}

class _ProductFormScreenState
    extends ConsumerState<ProductFormScreen> {

  final _formKey      = GlobalKey<FormState>();
  final _nameCtrl     = TextEditingController();
  final _descCtrl     = TextEditingController();
  final _priceCtrl    = TextEditingController();

  int?   _selectedCategoryId;
  bool   _isActive     = true;
  bool   _initialized  = false;

  final List<VariantInput> _variants = [];

  bool get isEdit => widget.productId != null;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _descCtrl.dispose();
    _priceCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadProduct() async {
    if (!isEdit || _initialized) return;
    _initialized = true;

    final ds   = ref.read(productDatasourceProvider);
    final item = await ds.getByIdWithDetails(widget.productId!);

    if (item != null) {
      setState(() {
        _nameCtrl.text          = item.product.name;
        _descCtrl.text          = item.product.description ?? '';
        _priceCtrl.text         = item.product.basePrice.toStringAsFixed(0);
        _selectedCategoryId     = item.product.categoryId;
        _isActive               = item.product.isActive;
        _variants.addAll(
          item.variants.map((v) => VariantInput(
            id: v.id,
            name: v.name,
            priceAdjustment: v.priceAdjustment,
          )),
        );
      });
    }
  }

  void _addVariant() {
    setState(() {
      _variants.add(VariantInput(name: '', priceAdjustment: 0));
    });
  }

  void _removeVariant(int index) {
    setState(() => _variants.removeAt(index));
  }

  Future<void> _onSave() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedCategoryId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pilih kategori terlebih dahulu')),
      );
      return;
    }

    await ref.read(productFormNotifierProvider.notifier).save(
      id: widget.productId,
      categoryId: _selectedCategoryId!,
      name: _nameCtrl.text.trim(),
      description: _descCtrl.text.trim().isEmpty
        ? null
        : _descCtrl.text.trim(),
      basePrice: double.tryParse(
        _priceCtrl.text.replaceAll('.', ''),
      ) ?? 0,
      isActive: _isActive,
      variants: _variants
        .where((v) => v.name.trim().isNotEmpty)
        .toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    _loadProduct();

    ref.listen(productFormNotifierProvider, (prev, next) {
      if (next.isSuccess) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              isEdit
                ? 'Produk berhasil diperbarui'
                : 'Produk berhasil ditambahkan',
            ),
          ),
        );
        context.go('/products');
      }
      if (next.errorMessage != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.errorMessage!),
            backgroundColor: AppColors.error,
          ),
        );
      }
    });

    final formState  = ref.watch(productFormNotifierProvider);
    final catStream  = ref.watch(categoriesStreamProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? 'Edit Produk' : 'Tambah Produk'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/products'),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSizes.md),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              // ── BASIC INFO ──────────────────────────
              _SectionTitle(title: 'Informasi Produk'),
              const SizedBox(height: AppSizes.sm),

              AppTextField(
                label: 'Nama Produk',
                hint: 'Contoh: Latte',
                controller: _nameCtrl,
                validator: (v) {
                  if (v == null || v.trim().isEmpty) {
                    return 'Nama produk wajib diisi';
                  }
                  return null;
                },
              ),
              const SizedBox(height: AppSizes.md),

              AppTextField(
                label: 'Deskripsi (opsional)',
                hint: 'Deskripsi singkat produk...',
                controller: _descCtrl,
                maxLines: 2,
              ),
              const SizedBox(height: AppSizes.md),

              // Category dropdown
              catStream.when(
                loading: () => const CircularProgressIndicator(),
                error: (e, _) => Text('Error: $e'),
                data: (cats) {
                  final activeCats = cats
                    .where((c) => c.isActive)
                    .toList();
                  return DropdownButtonFormField<int>(
                    value: _selectedCategoryId,
                    decoration: const InputDecoration(
                      labelText: 'Kategori',
                    ),
                    hint: const Text('Pilih kategori'),
                    items: activeCats.map((c) =>
                      DropdownMenuItem(
                        value: c.id,
                        child: Text(c.name),
                      ),
                    ).toList(),
                    onChanged: (val) => setState(
                      () => _selectedCategoryId = val,
                    ),
                    validator: (v) => v == null
                      ? 'Pilih kategori'
                      : null,
                  );
                },
              ),
              const SizedBox(height: AppSizes.md),

              AppTextField(
                label: 'Harga Dasar (Rp)',
                hint: '25000',
                controller: _priceCtrl,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                ],
                prefixIcon: Icons.attach_money,
                validator: (v) {
                  if (v == null || v.isEmpty) {
                    return 'Harga wajib diisi';
                  }
                  final price = double.tryParse(v);
                  if (price == null || price < 0) {
                    return 'Harga tidak valid';
                  }
                  return null;
                },
              ),
              const SizedBox(height: AppSizes.md),

              // Status
              Row(
                children: [
                  const Text(
                    'Status Produk',
                    style: TextStyle(fontWeight: FontWeight.w500),
                  ),
                  const Spacer(),
                  Switch(
                    value: _isActive,
                    activeColor: AppColors.primary,
                    onChanged: (val) =>
                      setState(() => _isActive = val),
                  ),
                  Text(
                    _isActive ? 'Tersedia' : 'Habis',
                    style: TextStyle(
                      color: _isActive
                        ? AppColors.success
                        : AppColors.textHint,
                    ),
                  ),
                ],
              ),

              // ── VARIANTS ────────────────────────────
              const SizedBox(height: AppSizes.lg),
              Row(
                children: [
                  _SectionTitle(title: 'Varian'),
                  const Spacer(),
                  TextButton.icon(
                    onPressed: _addVariant,
                    icon: const Icon(Icons.add),
                    label: const Text('Tambah Varian'),
                  ),
                ],
              ),

              if (_variants.isEmpty)
                Container(
                  padding: const EdgeInsets.all(AppSizes.md),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceVar,
                    borderRadius: BorderRadius.circular(
                      AppSizes.radiusMd,
                    ),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: const Center(
                    child: Text(
                      'Tidak ada varian. Tap + untuk menambah.',
                      style: TextStyle(color: AppColors.textHint),
                    ),
                  ),
                ),

              ..._variants.asMap().entries.map((entry) {
                final i = entry.key;
                final v = entry.value;
                return _VariantRow(
                  variant: v,
                  onRemove: () => _removeVariant(i),
                  onNameChanged: (val) => v.name = val,
                  onPriceChanged: (val) =>
                    v.priceAdjustment = double.tryParse(val) ?? 0,
                );
              }),

              const SizedBox(height: AppSizes.xl),

              AppButton(
                label: isEdit ? 'Perbarui Produk' : 'Simpan Produk',
                onPressed: _onSave,
                isLoading: formState.isLoading,
                icon: Icons.save_outlined,
              ),

              const SizedBox(height: AppSizes.xl),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title});
  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: AppColors.primary,
      ),
    );
  }
}

class _VariantRow extends StatelessWidget {
  const _VariantRow({
    required this.variant,
    required this.onRemove,
    required this.onNameChanged,
    required this.onPriceChanged,
  });

  final VariantInput variant;
  final VoidCallback onRemove;
  final void Function(String) onNameChanged;
  final void Function(String) onPriceChanged;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppSizes.sm),
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.sm),
        child: Row(
          children: [
            Expanded(
              flex: 3,
              child: TextFormField(
                initialValue: variant.name,
                decoration: const InputDecoration(
                  labelText: 'Nama Varian',
                  hintText: 'Small, Medium...',
                  isDense: true,
                ),
                onChanged: onNameChanged,
              ),
            ),
            const SizedBox(width: AppSizes.sm),
            Expanded(
              flex: 2,
              child: TextFormField(
                initialValue: variant.priceAdjustment
                  .toStringAsFixed(0),
                decoration: const InputDecoration(
                  labelText: '+/- Harga',
                  hintText: '3000',
                  isDense: true,
                  prefixText: 'Rp ',
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                ],
                onChanged: onPriceChanged,
              ),
            ),
            IconButton(
              icon: const Icon(
                Icons.delete_outline,
                color: AppColors.error,
              ),
              onPressed: onRemove,
            ),
          ],
        ),
      ),
    );
  }
}