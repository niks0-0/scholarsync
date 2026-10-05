import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../auth/auth_provider.dart';
import 'package:scholarsync/features/resources/presentation/resources_provider.dart';

/// Complete Student Academic Resources & Study Notes Hub.
/// Allows browsing subject materials, viewing bookmarked notes, and downloading documents.
class ResourcesHubScreen extends StatefulWidget {
  const ResourcesHubScreen({super.key});

  @override
  State<ResourcesHubScreen> createState() => _ResourcesHubScreenState();
}

class _ResourcesHubScreenState extends State<ResourcesHubScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = context.read<AuthProvider>().currentUser;
      if (user != null) {
        context.read<ResourcesProvider>().loadResources(user.uid);
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _openDocument(String url, {String? attachmentId}) async {
    if (url.isEmpty) return;
    final uri = Uri.tryParse(url);
    if (uri != null) {
      final user = context.read<AuthProvider>().currentUser;
      if (user != null && attachmentId != null) {
        context.read<ResourcesProvider>().recordDownload(
              userId: user.uid,
              attachmentId: attachmentId,
            );
      }
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Cannot open document URL.'),
              backgroundColor: AppColors.error,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final resources = context.watch<ResourcesProvider>();
    final user = context.watch<AuthProvider>().currentUser;

    final filteredNotes = resources.notes.where((n) {
      if (_searchQuery.isEmpty) return true;
      final q = _searchQuery.toLowerCase();
      return n.title.toLowerCase().contains(q) ||
          (n.subjectName?.toLowerCase().contains(q) ?? false) ||
          n.subjectId.toLowerCase().contains(q);
    }).toList();

    final savedList = resources.savedResources;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.background,
      appBar: AppBar(
        title: Text(
          'Academic Resources',
          style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.primary,
          labelColor: AppColors.primary,
          unselectedLabelColor: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
          tabs: [
            Tab(
              icon: const Icon(Icons.menu_book_rounded, size: 20),
              text: 'All Notes (${filteredNotes.length})',
            ),
            Tab(
              icon: const Icon(Icons.bookmark_rounded, size: 20),
              text: 'Saved / Bookmarks (${savedList.length})',
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () {
              if (user != null) {
                resources.loadResources(user.uid);
              }
            },
            tooltip: 'Refresh Materials',
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(AppDimensions.spacingMd),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search by title, subject code, or topic...',
                prefixIcon: const Icon(Icons.search_rounded),
                filled: true,
                fillColor: isDark ? AppColors.darkSurfaceVariant : AppColors.surfaceVariant,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: (val) => setState(() => _searchQuery = val.trim()),
            ),
          ),

          // Tab Views
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // Tab 1: All Shared Notes
                resources.isLoading && resources.notes.isEmpty
                    ? const Center(child: CircularProgressIndicator())
                    : filteredNotes.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.folder_open_rounded,
                                  size: 48,
                                  color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  'No Notes Found',
                                  style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Files shared in campus chatrooms will appear here.',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          )
                        : ListView.separated(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppDimensions.spacingMd,
                              vertical: AppDimensions.spacingSm,
                            ),
                            itemCount: filteredNotes.length,
                            separatorBuilder: (_, __) => const SizedBox(height: 10),
                            itemBuilder: (ctx, i) {
                              final note = filteredNotes[i];
                              return Card(
                                color: isDark ? AppColors.darkSurface : Colors.white,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
                                  side: BorderSide(
                                    color: isDark ? AppColors.darkBorder : AppColors.border,
                                  ),
                                ),
                                child: ListTile(
                                  leading: Container(
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      color: AppColors.primary.withValues(alpha: 0.12),
                                      borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
                                    ),
                                    child: const Icon(Icons.picture_as_pdf_rounded, color: AppColors.primary, size: 24),
                                  ),
                                  title: Text(
                                    note.title,
                                    style: const TextStyle(fontWeight: FontWeight.w700),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  subtitle: Text(
                                    '${note.subjectName ?? note.subjectId} • ${(note.fileSizeBytes / 1024).toStringAsFixed(1)} KB',
                                    style: TextStyle(
                                      color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                                      fontSize: 12,
                                    ),
                                  ),
                                  trailing: IconButton(
                                    icon: const Icon(Icons.download_rounded, color: AppColors.primary),
                                    onPressed: () => _openDocument(note.fileUrl, attachmentId: note.id),
                                    tooltip: 'Download / View',
                                  ),
                                ),
                              );
                            },
                          ),

                // Tab 2: Saved / Bookmarks
                savedList.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.bookmark_border_rounded,
                              size: 48,
                              color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'No Saved Resources',
                              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Tap the "Add to Resources" (+) button on files in chat to save them here.',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppDimensions.spacingMd,
                          vertical: AppDimensions.spacingSm,
                        ),
                        itemCount: savedList.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 10),
                        itemBuilder: (ctx, i) {
                          final item = savedList[i];
                          final att = item['chatroom_attachments'] as Map<String, dynamic>?;
                          final fileName = att?['file_name']?.toString() ?? 'Study Resource';
                          final path = att?['storage_path']?.toString() ?? '';

                          return Card(
                            color: isDark ? AppColors.darkSurface : Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
                              side: BorderSide(
                                color: isDark ? AppColors.darkBorder : AppColors.border,
                              ),
                            ),
                            child: ListTile(
                              leading: Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: AppColors.secondary.withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
                                ),
                                child: const Icon(Icons.bookmark_added_rounded, color: AppColors.secondary, size: 24),
                              ),
                              title: Text(
                                fileName,
                                style: const TextStyle(fontWeight: FontWeight.w700),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              subtitle: const Text('Saved from Chatroom'),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.open_in_new_rounded),
                                    onPressed: () => _openDocument(path, attachmentId: item['attachment_id']?.toString()),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.bookmark_remove_rounded, color: AppColors.error),
                                    onPressed: () async {
                                      if (user != null) {
                                        await resources.removeBookmark(
                                          userId: user.uid,
                                          bookmarkId: item['id'].toString(),
                                        );
                                      }
                                    },
                                    tooltip: 'Remove bookmark',
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
