import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/utils/validators.dart';
import '../../catalog/application/catalog_providers.dart';
import '../../catalog/data/product_repository.dart';

/// Tela de criação/edição de produto (Stories 2.1, 2.2, 2.3).
///
/// Quando [productId] é null, cria um novo produto.
/// Quando é não-null, carrega o produto existente para edição.
class ProductFormScreen extends ConsumerStatefulWidget {
  const ProductFormScreen({super.key, this.productId});

  final String? productId;

  @override
  ConsumerState<ProductFormScreen> createState() =>
      _ProductFormScreenState();
}

class _ProductFormScreenState
    extends ConsumerState<ProductFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _descCtrl = TextEditingController();

  bool _loading = false;
  bool _initialized = false;
  Product? _product;

  bool get _isEdit => widget.productId != null;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  void _initFromProduct(Product p) {
    if (_initialized) return;
    _nameCtrl.text = p.name;
    _descCtrl.text = p.description ?? '';
    _product = p;
    _initialized = true;
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      final repo = ref.read(productRepositoryProvider);
      if (_isEdit) {
        await repo.updateProduct(
          widget.productId!,
          name: _nameCtrl.text.trim(),
          description: _descCtrl.text.trim().isEmpty
              ? null
              : _descCtrl.text.trim(),
        );
        ref.invalidate(productDetailProvider(widget.productId!));
      } else {
        final created = await repo.createProduct(
          _nameCtrl.text.trim(),
          _descCtrl.text.trim().isEmpty
              ? null
              : _descCtrl.text.trim(),
        );
        setState(() {
          _product = created;
          _initialized = true;
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Produto criado! Agora adicione variantes e imagens.'),
            ),
          );
        }
      }
      ref.invalidate(adminProductsProvider);
      if (mounted && _isEdit) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Produto atualizado.')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // When editing, load the product once to pre-populate fields.
    if (_isEdit && !_initialized) {
      final detail =
          ref.watch(productDetailProvider(widget.productId!));
      return detail.when(
        loading: () =>
            const Scaffold(body: Center(child: CircularProgressIndicator())),
        error: (e, _) =>
            Scaffold(body: Center(child: Text('Erro: $e'))),
        data: (p) {
          _initFromProduct(p);
          return _buildForm();
        },
      );
    }
    return _buildForm();
  }

  Widget _buildForm() {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEdit ? 'Editar produto' : 'Novo produto'),
        actions: [
          if (_loading)
            const Padding(
              padding: EdgeInsets.only(right: 16),
              child: Center(
                  child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2))),
            )
          else
            TextButton(
              onPressed: _product == null || _isEdit ? _save : null,
              child: const Text('Salvar'),
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Dados básicos ─────────────────────────────────────
              Text('Informações',
                  style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 12),
              TextFormField(
                controller: _nameCtrl,
                decoration: const InputDecoration(labelText: 'Nome *'),
                textCapitalization: TextCapitalization.sentences,
                validator: (v) => Validators.required(v, field: 'Nome'),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descCtrl,
                decoration:
                    const InputDecoration(labelText: 'Descrição'),
                minLines: 2,
                maxLines: 4,
              ),
              // Save button for new product (needs to create first
              // before adding SKUs/images)
              if (!_isEdit && _product == null) ...[
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: _loading ? null : _save,
                    child: _loading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white))
                        : const Text('Criar produto'),
                  ),
                ),
              ],
              // ── SKUs (só após ter um produto) ─────────────────────
              if (_product != null || _isEdit) ...[
                const SizedBox(height: 32),
                _SkuSection(
                  productId: _product?.id ?? widget.productId!,
                  product: _product,
                ),
                const SizedBox(height: 32),
                // ── Imagens ────────────────────────────────────────
                _ImageSection(
                  productId: _product?.id ?? widget.productId!,
                  product: _product,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Seção de SKUs
// ─────────────────────────────────────────────────────────────────────────────

class _SkuSection extends ConsumerWidget {
  const _SkuSection({required this.productId, this.product});

  final String productId;
  final Product? product;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Use the detail provider so it refreshes when SKUs change.
    final detail = ref.watch(productDetailProvider(productId));
    final skus = detail.whenOrNull(data: (p) => p.skus) ?? product?.skus ?? [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Variantes (SKUs)',
                style: Theme.of(context).textTheme.titleMedium),
            TextButton.icon(
              icon: const Icon(Icons.add, size: 18),
              label: const Text('Adicionar'),
              onPressed: () => _openSkuModal(context, ref),
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (skus.isEmpty)
          const Text('Nenhuma variante ainda.'),
        ...skus.map(
          (sku) => _SkuRow(
            sku: sku,
            onEdit: () => _openSkuModal(context, ref, sku: sku),
            onDelete: () => _deleteSku(context, ref, sku),
          ),
        ),
      ],
    );
  }

  Future<void> _openSkuModal(BuildContext context, WidgetRef ref,
      {Sku? sku}) async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => _SkuModal(
        productId: productId,
        sku: sku,
        onSaved: () => ref.invalidate(productDetailProvider(productId)),
      ),
    );
  }

  Future<void> _deleteSku(
      BuildContext context, WidgetRef ref, Sku sku) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Remover variante'),
        content: Text(
            'Remover "${sku.name}"? Isso não pode ser desfeito.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancelar')),
          FilledButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Remover')),
        ],
      ),
    );
    if (ok != true) return;
    try {
      await ref.read(productRepositoryProvider).deleteSku(sku.id);
      ref.invalidate(productDetailProvider(productId));
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Erro: $e')));
    }
  }
}

class _SkuRow extends StatelessWidget {
  const _SkuRow({
    required this.sku,
    required this.onEdit,
    required this.onDelete,
  });
  final Sku sku;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 6),
      child: ListTile(
        dense: true,
        title: Text(sku.name),
        subtitle: Text(
          'R\$ ${sku.price.toStringAsFixed(2)} · '
          'mín. ${sku.minQuantity}',
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
                icon: const Icon(Icons.edit_outlined, size: 20),
                onPressed: onEdit),
            IconButton(
                icon: const Icon(Icons.delete_outline,
                    size: 20, color: Colors.red),
                onPressed: onDelete),
          ],
        ),
      ),
    );
  }
}

class _SkuModal extends ConsumerStatefulWidget {
  const _SkuModal({
    required this.productId,
    required this.onSaved,
    this.sku,
  });

  final String productId;
  final Sku? sku;
  final VoidCallback onSaved;

  @override
  ConsumerState<_SkuModal> createState() => _SkuModalState();
}

class _SkuModalState extends ConsumerState<_SkuModal> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _priceCtrl = TextEditingController();
  final _minCtrl = TextEditingController();
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    if (widget.sku != null) {
      _nameCtrl.text = widget.sku!.name;
      _priceCtrl.text = widget.sku!.price.toStringAsFixed(2);
      _minCtrl.text = widget.sku!.minQuantity.toString();
    } else {
      _minCtrl.text = '1';
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _priceCtrl.dispose();
    _minCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      await ref.read(productRepositoryProvider).upsertSku(
            id: widget.sku?.id,
            productId: widget.productId,
            name: _nameCtrl.text.trim(),
            price: double.parse(_priceCtrl.text.replaceAll(',', '.')),
            minQuantity: int.parse(_minCtrl.text),
          );
      widget.onSaved();
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Erro: $e')));
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.sku == null ? 'Nova variante' : 'Editar variante',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _nameCtrl,
              decoration:
                  const InputDecoration(labelText: 'Nome da variante *'),
              textCapitalization: TextCapitalization.sentences,
              validator: (v) =>
                  Validators.required(v, field: 'Nome'),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _priceCtrl,
              decoration:
                  const InputDecoration(labelText: 'Preço (R\$) *'),
              keyboardType: const TextInputType.numberWithOptions(
                  decimal: true),
              validator: (v) {
                if (v == null || v.trim().isEmpty) {
                  return 'Informe o preço';
                }
                final n =
                    double.tryParse(v.trim().replaceAll(',', '.'));
                if (n == null || n < 0) return 'Preço inválido';
                return null;
              },
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _minCtrl,
              decoration: const InputDecoration(
                  labelText: 'Quantidade mínima *'),
              keyboardType: TextInputType.number,
              validator: (v) {
                final n = int.tryParse(v ?? '');
                if (n == null || n < 1) {
                  return 'Mínimo deve ser pelo menos 1';
                }
                return null;
              },
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _loading ? null : _save,
                child: _loading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white))
                    : Text(widget.sku == null ? 'Adicionar' : 'Salvar'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Seção de imagens
// ─────────────────────────────────────────────────────────────────────────────

class _ImageSection extends ConsumerStatefulWidget {
  const _ImageSection({required this.productId, this.product});

  final String productId;
  final Product? product;

  @override
  ConsumerState<_ImageSection> createState() => _ImageSectionState();
}

class _ImageSectionState extends ConsumerState<_ImageSection> {
  final _picker = ImagePicker();
  bool _uploading = false;

  Future<void> _pickAndUpload(BuildContext context) async {
    final xfile = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );
    if (xfile == null) return;

    setState(() => _uploading = true);
    try {
      final bytes = await xfile.readAsBytes();
      final detail = ref.read(productDetailProvider(widget.productId));
      final currentCount =
          detail.whenOrNull(data: (p) => p.images.length) ??
              widget.product?.images.length ??
              0;

      await ref.read(productRepositoryProvider).uploadImage(
            productId: widget.productId,
            filename: xfile.name,
            bytes: Uint8List.fromList(bytes),
            mimeType: xfile.mimeType ?? 'image/jpeg',
            position: currentCount,
          );
      ref.invalidate(productDetailProvider(widget.productId));
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Erro no upload: $e')));
    } finally {
      if (mounted) setState(() => _uploading = false);
    }
  }

  Future<void> _deleteImage(
      BuildContext context, ProductImage img) async {
    try {
      await ref
          .read(productRepositoryProvider)
          .deleteImage(img.id, img.storageUrl);
      ref.invalidate(productDetailProvider(widget.productId));
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Erro: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final detail =
        ref.watch(productDetailProvider(widget.productId));
    final images =
        detail.whenOrNull(data: (p) => p.images) ??
            widget.product?.images ??
            [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Imagens',
                style: Theme.of(context).textTheme.titleMedium),
            TextButton.icon(
              icon: _uploading
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2))
                  : const Icon(Icons.add_photo_alternate_outlined,
                      size: 18),
              label:
                  Text(_uploading ? 'Enviando…' : 'Adicionar foto'),
              onPressed: _uploading
                  ? null
                  : () => _pickAndUpload(context),
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (images.isEmpty)
          const Text('Nenhuma imagem adicionada.')
        else
          SizedBox(
            height: 120,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: images.length,
              separatorBuilder: (_, _) =>
                  const SizedBox(width: 8),
              itemBuilder: (ctx, i) => _ImageThumb(
                image: images[i],
                onDelete: () =>
                    _deleteImage(context, images[i]),
              ),
            ),
          ),
      ],
    );
  }
}

class _ImageThumb extends StatelessWidget {
  const _ImageThumb({required this.image, required this.onDelete});
  final ProductImage image;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.network(
            image.storageUrl,
            width: 100,
            height: 120,
            fit: BoxFit.cover,
            loadingBuilder: (_, child, progress) => progress == null
                ? child
                : Container(
                    width: 100,
                    height: 120,
                    color: AppColors.champagneLight,
                    child:
                        const Center(child: CircularProgressIndicator()),
                  ),
          ),
        ),
        Positioned(
          top: 2,
          right: 2,
          child: InkWell(
            onTap: onDelete,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.all(4),
              child:
                  const Icon(Icons.close, size: 16, color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }
}
