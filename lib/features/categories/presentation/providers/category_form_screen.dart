import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_sizes.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_text_field.dart';
import '../../data/datasources/category_datasource.dart';
import '../providers/category_provider.dart';

class CategoryFormScreen extends ConsumerStatefulWidget {
  const CategoryFormScreen({super.key, this.categoryId});
  final int? categoryId;

  @override
  ConsumerState<CategoryFormScreen> createState() =>
    _CategoryFormScreenState();
}

class _CategoryFormScreenState
    extends ConsumerState<CategoryFormScreen> {

  final _formKey      = GlobalKey<FormState>();
  final _nameCtrl     = TextEditingController();
  final _sortCtrl     = TextEditingController(text: '0');
  bool  _initialized  = false;

  bool get isEdit => widget.categoryId != null;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _sortCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadCategory() async {
    if (!isEdit || _initialized) return;
    _initialized = true;

    final ds  = ref.read(categoryDatasourceProvider);
    final cat = await ds.getById(widget.categoryId!);
    if (cat != null) {
      _nameCtrl.text = cat.name;
      _sortCtrl.text = cat.sortOrder.toString();
    }
  }

  Future<void> _onSave() async {
    if (!_formKey.currentState!.validate()) return;

    await ref.read(categoryFormNotifierProvider.notifier).save(
      id: widget.categoryId,
      name: _nameCtrl.text.trim(),
      sortOrder: int.tryParse(_sortCtrl.text) ?? 0,
    );
  }

  @override
  Widget build(BuildContext context) {
    _loadCategory();

    ref.listen(categoryFormNotifierProvider, (prev, next) {
      if (next.isSuccess) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              isEdit
                ? 'Kategori berhasil diperbarui'
                : 'Kategori berhasil ditambahkan',
            ),
          ),
        );
        context.go('/categories');
      }
      if (next.errorMessage != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.errorMessage!),
            backgroundColor: Colors.red,
          ),
        );
      }
    });

    final state = ref.watch(categoryFormNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? 'Edit Kategori' : 'Tambah Kategori'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/categories'),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSizes.md),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppTextField(
                label: 'Nama Kategori',
                hint: 'Contoh: Coffee, Food...',
                controller: _nameCtrl,
                validator: (v) {
                  if (v == null || v.trim().isEmpty) {
                    return 'Nama kategori wajib diisi';
                  }
                  return null;
                },
              ),
              const SizedBox(height: AppSizes.md),
              AppTextField(
                label: 'Urutan Tampil',
                hint: '0, 1, 2...',
                controller: _sortCtrl,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                ],
              ),
              const SizedBox(height: AppSizes.xl),
              AppButton(
                label: isEdit ? 'Perbarui' : 'Simpan',
                onPressed: _onSave,
                isLoading: state.isLoading,
                icon: Icons.save_outlined,
              ),
            ],
          ),
        ),
      ),
    );
  }
}