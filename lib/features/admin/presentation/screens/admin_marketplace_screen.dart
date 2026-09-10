import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/models/marketplace_listing.dart';
import '../admin_provider.dart';

/// Student Marketplace Oversight & Listing Moderation Studio.
class AdminMarketplaceScreen extends StatefulWidget {
  const AdminMarketplaceScreen({super.key});

  @override
  State<AdminMarketplaceScreen> createState() => _AdminMarketplaceScreenState();
}

class _AdminMarketplaceScreenState extends State<AdminMarketplaceScreen> {
  String? _selectedStatusFilter;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminProvider>().loadMarketplaceListings();
    });
  }

  void _openCreateListingDialog(BuildContext context) {
    final titleController = TextEditingController();
    final descController = TextEditingController();
    final priceController = TextEditingController();
    String selectedCategory = 'books';

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) => AlertDialog(
          title: const Text('Add Marketplace Listing'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(
                    labelText: 'Item Title *',
                    hintText: 'e.g. Drafter & Mini-Drafting Kit',
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: priceController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Price (₹) *',
                    hintText: 'e.g. 450',
                    prefixText: '₹ ',
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: descController,
                  maxLines: 2,
                  decoration: const InputDecoration(
                    labelText: 'Description',
                    hintText: 'e.g. Barely used 1st year engineering drafter with case.',
                  ),
                ),
                const SizedBox(height: 16),
                const Text('Category', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    'books',
                    'electronics',
                    'notes_bundle',
                    'drafter_tools',
                    'uniform',
                  ].map((cat) {
                    final isSelected = selectedCategory == cat;
                    return ChoiceChip(
                      label: Text(cat.replaceAll('_', ' ').toUpperCase()),
                      selected: isSelected,
                      selectedColor: const Color(0xFF10B981).withValues(alpha: 0.25),
                      onSelected: (_) => setModalState(() => selectedCategory = cat),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            FilledButton.icon(
              icon: const Icon(Icons.check_rounded, size: 18),
              label: const Text('Publish Listing'),
              onPressed: () async {
                final title = titleController.text.trim();
                final price = double.tryParse(priceController.text.trim()) ?? 0.0;
                if (title.isEmpty || price <= 0) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Please provide a valid title and price.'),
                      backgroundColor: AppColors.error,
                    ),
                  );
                  return;
                }

                Navigator.pop(ctx);
                final admin = context.read<AdminProvider>();
                final success = await admin.createMarketplaceListing(
                  MarketplaceListing(
                    id: '',
                    sellerId: 'SQJRGQZkujOAIfFEetfaqPqtHbL2',
                    sellerName: 'App Owner Admin',
                    title: title,
                    description: descController.text.trim(),
                    price: price,
                    category: selectedCategory,
                    status: 'active',
                  ),
                );

                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(success ? 'Listing published to database!' : 'Failed to create listing.'),
                      backgroundColor: success ? AppColors.success : AppColors.error,
                    ),
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final admin = context.watch<AdminProvider>();
    final listings = _selectedStatusFilter == null
        ? admin.marketplaceListings
        : admin.marketplaceListings.where((l) => l.status == _selectedStatusFilter).toList();

    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: const Color(0xFF10B981),
        foregroundColor: Colors.black,
        icon: const Icon(Icons.add_shopping_cart_rounded),
        label: const Text('Add Listing', style: TextStyle(fontWeight: FontWeight.bold)),
        onPressed: () => _openCreateListingDialog(context),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Campus Marketplace Oversight',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: Colors.white),
                      ),
                      Text(
                        '${listings.length} student buy/sell listings under administrative supervision',
                        style: TextStyle(fontSize: 12, color: Colors.white.withValues(alpha: 0.6)),
                      ),
                    ],
                  ),
                ),
                IconButton.filledTonal(
                  icon: const Icon(Icons.refresh_rounded),
                  tooltip: 'Refresh Listings',
                  onPressed: () => admin.loadMarketplaceListings(),
                ),
              ],
            ),
            const SizedBox(height: 14),

            // Status Filters
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  ChoiceChip(
                    label: const Text('All Listings'),
                    selected: _selectedStatusFilter == null,
                    selectedColor: AppColors.primary.withValues(alpha: 0.25),
                    onSelected: (_) => setState(() => _selectedStatusFilter = null),
                  ),
                  const SizedBox(width: 8),
                  ChoiceChip(
                    label: const Text('Active'),
                    selected: _selectedStatusFilter == 'active',
                    selectedColor: AppColors.success.withValues(alpha: 0.25),
                    onSelected: (_) => setState(() => _selectedStatusFilter = 'active'),
                  ),
                  const SizedBox(width: 8),
                  ChoiceChip(
                    label: const Text('Flagged'),
                    selected: _selectedStatusFilter == 'flagged',
                    selectedColor: AppColors.error.withValues(alpha: 0.25),
                    onSelected: (_) => setState(() => _selectedStatusFilter = 'flagged'),
                  ),
                  const SizedBox(width: 8),
                  ChoiceChip(
                    label: const Text('Sold'),
                    selected: _selectedStatusFilter == 'sold',
                    selectedColor: AppColors.secondary.withValues(alpha: 0.25),
                    onSelected: (_) => setState(() => _selectedStatusFilter = 'sold'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Listings List
            Expanded(
              child: admin.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : listings.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.storefront_outlined, size: 56, color: Colors.white.withValues(alpha: 0.4)),
                              const SizedBox(height: 12),
                              const Text(
                                'No Marketplace Listings Found',
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Tap "+ Add Listing" below to publish the first buy/sell item.',
                                style: TextStyle(color: Colors.white.withValues(alpha: 0.6), fontSize: 12),
                              ),
                            ],
                          ),
                        )
                      : ListView.separated(
                          itemCount: listings.length,
                          separatorBuilder: (context, index) => const SizedBox(height: 10),
                          itemBuilder: (context, index) {
                            final item = listings[index];
                            final isActive = item.status == 'active';
                            final isFlagged = item.status == 'flagged';
                            final isSold = item.status == 'sold';

                            return Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: const Color(0xFF0F1218),
                                borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
                                border: Border.all(
                                  color: isFlagged ? AppColors.error.withValues(alpha: 0.5) : const Color(0xFF27272A),
                                ),
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF10B981).withValues(alpha: 0.15),
                                      borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
                                      border: Border.all(color: const Color(0xFF10B981).withValues(alpha: 0.3)),
                                    ),
                                    child: const Icon(Icons.shopping_bag_rounded, size: 22, color: Color(0xFF34D399)),
                                  ),
                                  const SizedBox(width: 14),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          item.title,
                                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.white),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          '₹${item.price.toStringAsFixed(0)} • Category: ${item.category.toUpperCase()}',
                                          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: Color(0xFF34D399)),
                                        ),
                                        if (item.description != null && item.description!.isNotEmpty) ...[
                                          const SizedBox(height: 4),
                                          Text(
                                            item.description!,
                                            style: TextStyle(fontSize: 12, color: Colors.white.withValues(alpha: 0.7)),
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ],
                                        if (item.sellerName != null) ...[
                                          const SizedBox(height: 4),
                                          Text(
                                            'Seller: ${item.sellerName}',
                                            style: TextStyle(fontSize: 11, color: Colors.white.withValues(alpha: 0.6)),
                                          ),
                                        ],
                                        const SizedBox(height: 6),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: (isActive ? AppColors.success : isFlagged ? AppColors.error : Colors.grey)
                                                .withValues(alpha: 0.15),
                                            borderRadius: BorderRadius.circular(4),
                                          ),
                                          child: Text(
                                            item.status.toUpperCase(),
                                            style: TextStyle(
                                              fontSize: 9,
                                              fontWeight: FontWeight.bold,
                                              color: isActive ? AppColors.success : isFlagged ? AppColors.error : Colors.grey,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  PopupMenuButton<String>(
                                    icon: const Icon(Icons.more_vert_rounded, color: Colors.white70),
                                    onSelected: (val) async {
                                      if (val == 'delete') {
                                        final success = await admin.deleteMarketplaceListing(item.id);
                                        if (context.mounted) {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(
                                              content: Text(success ? 'Listing removed.' : 'Failed to delete.'),
                                              backgroundColor: success ? AppColors.success : AppColors.error,
                                            ),
                                          );
                                        }
                                      } else {
                                        await admin.updateMarketplaceListingStatus(item.id, val);
                                      }
                                    },
                                    itemBuilder: (ctx) => [
                                      if (!isActive)
                                        const PopupMenuItem(
                                          value: 'active',
                                          child: Row(
                                            children: [
                                              Icon(Icons.check_circle_outline, color: AppColors.success, size: 18),
                                              SizedBox(width: 8),
                                              Text('Approve / Make Active'),
                                            ],
                                          ),
                                        ),
                                      if (!isFlagged)
                                        const PopupMenuItem(
                                          value: 'flagged',
                                          child: Row(
                                            children: [
                                              Icon(Icons.flag_outlined, color: AppColors.warning, size: 18),
                                              SizedBox(width: 8),
                                              Text('Flag for Review'),
                                            ],
                                          ),
                                        ),
                                      if (!isSold)
                                        const PopupMenuItem(
                                          value: 'sold',
                                          child: Row(
                                            children: [
                                              Icon(Icons.sell_outlined, color: AppColors.secondary, size: 18),
                                              SizedBox(width: 8),
                                              Text('Mark as Sold'),
                                            ],
                                          ),
                                        ),
                                      const PopupMenuDivider(),
                                      const PopupMenuItem(
                                        value: 'delete',
                                        child: Row(
                                          children: [
                                            Icon(Icons.delete_outline, color: AppColors.error, size: 18),
                                            SizedBox(width: 8),
                                            Text('Delete Listing', style: TextStyle(color: AppColors.error)),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }
}
