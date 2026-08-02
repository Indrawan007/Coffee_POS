import 'package:coffee_pos/core/constant/app_colors.dart';
import 'package:coffee_pos/core/constant/app_sizes.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_text_field.dart';
import '../../../categories/presentation/providers/category_provider.dart';
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

  final _formKey   = GlobalKey<FormState>();
  final _nameCtrl  = TextEditingController();
  final _descCtrl  = TextEditingController();
  final _priceCtrl = TextEditingController();

  int?  _selectedCategoryId;
  bool  _isActive    = true;
  bool  _initialized = false;

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

    final ds = ref.read(productDatasourceProvider);
    final item = await ds.getByIdWithDetails(
      widget.productId!,
    );

    if (item != null && mounted) {
      setState(() {
        _nameCtrl.text  = item.product.name;
        _descCtrl.text  = item.product.description ?? '';
        _priceCtrl.text =
          item.product.basePrice.toStringAsFixed(0);
        _selectedCategoryId = item.product.categoryId;
        _isActive = item.product.isActive;
        _variants.clear();
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
      _variants.add(
        VariantInput(name: '', priceAdjustment: 0),
      );
    });
  }

  void _removeVariant(int index) {
    setState(() => _variants.removeAt(index));
  }

  Future<void> _onSave() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedCategoryId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pilih kategori terlebih dahulu'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    final priceText = _priceCtrl.text.replaceAll('.', '');

    await ref.read(productFormNotifierProvider.notifier)
      .save(
        id: widget.productId,
        categoryId: _selectedCategoryId!,
        name: _nameCtrl.text.trim(),
        description: _descCtrl.text.trim().isEmpty
          ? null
          : _descCtrl.text.trim(),
        basePrice: double.tryParse(priceText) ?? 0,
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
            content: Row(
              children: [
                const Icon(Icons.check_circle,
                  color: Colors.white, size: 18),
                const SizedBox(width: 8),
                Text(
                  isEdit
                    ? 'Produk berhasil diperbarui'
                    : 'Produk berhasil ditambahkan',
                ),
              ],
            ),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
          ),
        );
        Navigator.pop(context);
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

    final formState = ref.watch(productFormNotifierProvider);
    final catStream = ref.watch(categoriesStreamProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          isEdit ? 'Edit Produk' : 'Tambah Produk',
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            // Scrollable content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppSizes.md),
                child: Column(
                  crossAxisAlignment:
                    CrossAxisAlignment.start,
                  children: [
                    // ── INFO PRODUK ────────────
                    _FormSection(
                      icon: Icons.info_outline,
                      title: 'Informasi Produk',
                      children: [
                        AppTextField(
                          label: 'Nama Produk',
                          hint: 'Contoh: Latte',
                          controller: _nameCtrl,
                          prefixIcon: Icons.coffee,
                          validator: (v) {
                            if (v == null ||
                                v.trim().isEmpty) {
                              return 'Nama wajib diisi';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(
                          height: AppSizes.md,
                        ),

                        AppTextField(
                          label: 'Deskripsi (opsional)',
                          hint: 'Deskripsi singkat...',
                          controller: _descCtrl,
                          prefixIcon: Icons.notes,
                          maxLines: 2,
                        ),
                        const SizedBox(
                          height: AppSizes.md,
                        ),

                        catStream.when(
                          loading: () =>
                            const LinearProgressIndicator(),
                          error: (e, _) =>
                            Text('Error: $e'),
                          data: (cats) {
                            final active = cats
                              .where((c) => c.isActive)
                              .toList();
                            return DropdownButtonFormField<
                              int
                            >(
                              value: _selectedCategoryId,
                              decoration:
                                const InputDecoration(
                                  labelText: 'Kategori',
                                  prefixIcon: Icon(
                                    Icons
                                      .category_outlined,
                                  ),
                                ),
                              hint: const Text(
                                'Pilih kategori',
                              ),
                              items: active
                                .map((c) =>
                                  DropdownMenuItem(
                                    value: c.id,
                                    child: Text(c.name),
                                  ))
                                .toList(),
                              onChanged: (val) =>
                                setState(() =>
                                  _selectedCategoryId =
                                    val),
                              validator: (v) => v == null
                                ? 'Pilih kategori'
                                : null,
                            );
                          },
                        ),
                        const SizedBox(
                          height: AppSizes.md,
                        ),

                        AppTextField(
                          label: 'Harga Dasar (Rp)',
                          hint: '25000',
                          controller: _priceCtrl,
                          keyboardType:
                            TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter
                              .digitsOnly,
                          ],
                          prefixIcon: Icons.attach_money,
                          validator: (v) {
                            if (v == null || v.isEmpty) {
                              return 'Harga wajib diisi';
                            }
                            return null;
                          },
                        ),
                      ],
                    ),

                    const SizedBox(height: AppSizes.md),

                    // ── STATUS ─────────────────
                    _FormSection(
                      icon: Icons.toggle_on_outlined,
                      title: 'Status',
                      children: [
                        _StatusToggle(
                          isActive: _isActive,
                          onChanged: (val) => setState(
                            () => _isActive = val,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: AppSizes.md),

                    // ── VARIAN ─────────────────
                    _FormSection(
                      icon: Icons.straighten,
                      title: 'Varian',
                      trailing: TextButton.icon(
                        onPressed: _addVariant,
                        icon: const Icon(
                          Icons.add,
                          size: 18,
                        ),
                        label: const Text('Tambah'),
                        style: TextButton.styleFrom(
                          padding:
                            const EdgeInsets.symmetric(
                              horizontal: AppSizes.sm,
                            ),
                          minimumSize: Size.zero,
                          tapTargetSize:
                            MaterialTapTargetSize
                              .shrinkWrap,
                        ),
                      ),
                      children: [
                        if (_variants.isEmpty)
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(
                              AppSizes.lg,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.surfaceVar,
                              borderRadius:
                                BorderRadius.circular(
                                  AppSizes.radiusMd,
                                ),
                              border: Border.all(
                                color: AppColors.border,
                                style: BorderStyle.solid,
                              ),
                            ),
                            child: const Column(
                              children: [
                                Icon(
                                  Icons.straighten,
                                  color:
                                    AppColors.textHint,
                                  size: 32,
                                ),
                                SizedBox(
                                  height: AppSizes.sm,
                                ),
                                Text(
                                  'Belum ada varian',
                                  style: TextStyle(
                                    color:
                                      AppColors.textHint,
                                    fontSize: 13,
                                  ),
                                ),
                                Text(
                                  'Tap + Tambah untuk '
                                  'menambahkan',
                                  style: TextStyle(
                                    color:
                                      AppColors.textHint,
                                    fontSize: 11,
                                  ),
                                ),
                              ],
                            ),
                          )
                        else
                          ..._variants
                            .asMap()
                            .entries
                            .map((entry) {
                              final i = entry.key;
                              final v = entry.value;
                              return _VariantCard(
                                index: i,
                                variant: v,
                                onRemove: () =>
                                  _removeVariant(i),
                                onNameChanged: (val) =>
                                  v.name = val,
                                onPriceChanged: (val) =>
                                  v.priceAdjustment =
                                    double.tryParse(
                                      val,
                                    ) ??
                                    0,
                              );
                            }),
                      ],
                    ),

                    const SizedBox(height: AppSizes.xl),
                  ],
                ),
              ),
            ),

            // ── SAVE BUTTON (Sticky bottom) ───
            Container(
              padding: const EdgeInsets.all(AppSizes.md),
              decoration: BoxDecoration(
                color: AppColors.surface,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 8,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: SafeArea(
                child: AppButton(
                  label: isEdit
                    ? 'Perbarui Produk'
                    : 'Simpan Produk',
                  onPressed: _onSave,
                  isLoading: formState.isLoading,
                  icon: Icons.save,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════
// FORM SECTION
// ═══════════════════════════════════════════════════
class _FormSection extends StatelessWidget {
  const _FormSection({
    required this.icon,
    required this.title,
    required this.children,
    this.trailing,
  });

  final IconData icon;
  final String title;
  final List<Widget> children;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(
          AppSizes.radiusLg,
        ),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSizes.md,
              AppSizes.md,
              AppSizes.sm,
              AppSizes.sm,
            ),
            child: Row(
              children: [
                Icon(icon,
                  color: AppColors.primary, size: 20),
                const SizedBox(width: AppSizes.sm),
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                const Spacer(),
                if (trailing != null) trailing!,
              ],
            ),
          ),
          const Divider(height: 1),

          // Content
          Padding(
            padding: const EdgeInsets.all(AppSizes.md),
            child: Column(children: children),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════
// STATUS TOGGLE
// ═══════════════════════════════════════════════════
class _StatusToggle extends StatelessWidget {
  const _StatusToggle({
    required this.isActive,
    required this.onChanged,
  });

  final bool isActive;
  final void Function(bool) onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Tersedia
        Expanded(
          child: GestureDetector(
            onTap: () => onChanged(true),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.all(AppSizes.md),
              decoration: BoxDecoration(
                color: isActive
                  ? AppColors.success.withOpacity(0.1)
                  : AppColors.surfaceVar,
                borderRadius: BorderRadius.circular(
                  AppSizes.radiusMd,
                ),
                border: Border.all(
                  color: isActive
                    ? AppColors.success
                    : AppColors.border,
                  width: isActive ? 2 : 1,
                ),
              ),
              child: Row(
                mainAxisAlignment:
                  MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.check_circle,
                    size: 20,
                    color: isActive
                      ? AppColors.success
                      : AppColors.textHint,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Tersedia',
                    style: TextStyle(
                      fontWeight: isActive
                        ? FontWeight.bold
                        : FontWeight.normal,
                      color: isActive
                        ? AppColors.success
                        : AppColors.textHint,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),

        const SizedBox(width: AppSizes.sm),

        // Habis
        Expanded(
          child: GestureDetector(
            onTap: () => onChanged(false),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.all(AppSizes.md),
              decoration: BoxDecoration(
                color: !isActive
                  ? AppColors.error.withOpacity(0.1)
                  : AppColors.surfaceVar,
                borderRadius: BorderRadius.circular(
                  AppSizes.radiusMd,
                ),
                border: Border.all(
                  color: !isActive
                    ? AppColors.error
                    : AppColors.border,
                  width: !isActive ? 2 : 1,
                ),
              ),
              child: Row(
                mainAxisAlignment:
                  MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.cancel,
                    size: 20,
                    color: !isActive
                      ? AppColors.error
                      : AppColors.textHint,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Habis',
                    style: TextStyle(
                      fontWeight: !isActive
                        ? FontWeight.bold
                        : FontWeight.normal,
                      color: !isActive
                        ? AppColors.error
                        : AppColors.textHint,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════
// VARIANT CARD
// ═══════════════════════════════════════════════════
class _VariantCard extends StatelessWidget {
  const _VariantCard({
    required this.index,
    required this.variant,
    required this.onRemove,
    required this.onNameChanged,
    required this.onPriceChanged,
  });

  final int index;
  final VariantInput variant;
  final VoidCallback onRemove;
  final void Function(String) onNameChanged;
  final void Function(String) onPriceChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSizes.sm),
      padding: const EdgeInsets.all(AppSizes.md),
      decoration: BoxDecoration(
        color: AppColors.surfaceVar,
        borderRadius: BorderRadius.circular(
          AppSizes.radiusMd,
        ),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          // Header
          Row(
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: AppColors.primary
                    .withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    '${index + 1}',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: AppSizes.sm),
              const Text(
                'Varian',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(
                  Icons.close,
                  color: AppColors.error,
                  size: 18,
                ),
                onPressed: onRemove,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                tooltip: 'Hapus varian',
              ),
            ],
          ),
          const SizedBox(height: AppSizes.sm),

          // Fields
          Row(
            children: [
              Expanded(
                flex: 3,
                child: TextFormField(
                  initialValue: variant.name,
                  decoration: const InputDecoration(
                    labelText: 'Nama',
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
                    labelText: '+Harga',
                    hintText: '3000',
                    isDense: true,
                    prefixText: 'Rp ',
                  ),
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter
                      .digitsOnly,
                  ],
                  onChanged: onPriceChanged,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
