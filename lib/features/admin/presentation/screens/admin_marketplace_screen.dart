import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/theme/app_colors.dart';
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

  @override
  Widget build(BuildContext context) {
    final admin = context.watch<AdminProvider>();
    final listings = _selectedStatusFilter == null
        ? admin.marketplaceListings
        : admin.marketplaceListings.where((l) => l.status == _selectedStatusFilter).toList();

    return Scaffold(
      backgroundColor: Colors.transparent,
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
                                'All student textbook, drafter, and gadget listings will appear here.',
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
                                        if (item.sellerName != null) ...[
                                          const SizedBox(height: 2),
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
                                  if (isActive)
                                    IconButton(
                                      icon: const Icon(Icons.flag_outlined, size: 20, color: AppColors.warning),
                                      tooltip: 'Flag Listing',
                                      onPressed: () => admin.updateMarketplaceListingStatus(item.id, 'flagged'),
                                    ),
                                  IconButton(
                                    icon: const Icon(Icons.delete_outline_rounded, size: 20, color: AppColors.error),
                                    tooltip: 'Delete Listing',
                                    onPressed: () async {
                                      final success = await admin.deleteMarketplaceListing(item.id);
                                      if (context.mounted) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(
                                            content: Text(success ? 'Listing removed.' : 'Failed to delete.'),
                                            backgroundColor: success ? AppColors.success : AppColors.error,
                                          ),
                                        );
                                      }
                                    },
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
