import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/models/community_post.dart';
import '../admin_provider.dart';

/// Community Forum & Q&A Discussion Governance Studio.
class AdminCommunityScreen extends StatefulWidget {
  const AdminCommunityScreen({super.key});

  @override
  State<AdminCommunityScreen> createState() => _AdminCommunityScreenState();
}

class _AdminCommunityScreenState extends State<AdminCommunityScreen> {
  String? _selectedCategoryFilter;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminProvider>().loadCommunityPosts();
    });
  }

  void _openCreatePostDialog(BuildContext context) {
    final titleController = TextEditingController();
    final contentController = TextEditingController();
    String selectedCategory = 'general';
    bool isPinned = false;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) => AlertDialog(
          title: const Text('Start Community Discussion'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(
                    labelText: 'Discussion Title *',
                    hintText: 'e.g. Tips for MCA Semester 1 DBMS Practical Exam',
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: contentController,
                  maxLines: 4,
                  decoration: const InputDecoration(
                    labelText: 'Content / Question *',
                    hintText: 'Provide details, instructions, or queries for fellow scholars...',
                  ),
                ),
                const SizedBox(height: 16),
                const Text('Category', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    'general',
                    'doubt',
                    'notes_share',
                    'career',
                    'project',
                  ].map((cat) {
                    final isSelected = selectedCategory == cat;
                    return ChoiceChip(
                      label: Text(cat.replaceAll('_', ' ').toUpperCase()),
                      selected: isSelected,
                      selectedColor: const Color(0xFF38BDF8).withValues(alpha: 0.25),
                      onSelected: (_) => setModalState(() => selectedCategory = cat),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 12),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Pin to top of feed', style: TextStyle(fontSize: 14)),
                  subtitle: const Text('Pinned discussions remain at the top for all students', style: TextStyle(fontSize: 11)),
                  value: isPinned,
                  onChanged: (v) => setModalState(() => isPinned = v),
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
              icon: const Icon(Icons.send_rounded, size: 18),
              label: const Text('Post Discussion'),
              onPressed: () async {
                final title = titleController.text.trim();
                final content = contentController.text.trim();
                if (title.isEmpty || content.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Title and content cannot be empty.'),
                      backgroundColor: AppColors.error,
                    ),
                  );
                  return;
                }

                Navigator.pop(ctx);
                final admin = context.read<AdminProvider>();
                final success = await admin.createCommunityPost(
                  CommunityPost(
                    id: '',
                    authorId: 'SQJRGQZkujOAIfFEetfaqPqtHbL2',
                    authorName: 'App Owner Admin',
                    title: title,
                    content: content,
                    category: selectedCategory,
                    isPinned: isPinned,
                    status: 'active',
                  ),
                );

                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(success ? 'Discussion posted to database!' : 'Failed to publish post.'),
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
    final posts = _selectedCategoryFilter == null
        ? admin.communityPosts
        : admin.communityPosts.where((p) => p.category == _selectedCategoryFilter).toList();

    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: const Color(0xFF38BDF8),
        foregroundColor: Colors.black,
        icon: const Icon(Icons.add_comment_rounded),
        label: const Text('New Post', style: TextStyle(fontWeight: FontWeight.bold)),
        onPressed: () => _openCreatePostDialog(context),
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
                        'Community Forum & Q&A Hub',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: Colors.white),
                      ),
                      Text(
                        '${posts.length} student discussions, doubts, and polls across campus',
                        style: TextStyle(fontSize: 12, color: Colors.white.withValues(alpha: 0.6)),
                      ),
                    ],
                  ),
                ),
                IconButton.filledTonal(
                  icon: const Icon(Icons.refresh_rounded),
                  tooltip: 'Refresh Posts',
                  onPressed: () => admin.loadCommunityPosts(),
                ),
              ],
            ),
            const SizedBox(height: 14),

            // Category Filters
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  ChoiceChip(
                    label: const Text('All Posts'),
                    selected: _selectedCategoryFilter == null,
                    selectedColor: AppColors.primary.withValues(alpha: 0.25),
                    onSelected: (_) => setState(() => _selectedCategoryFilter = null),
                  ),
                  const SizedBox(width: 8),
                  ChoiceChip(
                    label: const Text('Doubts & Q&A'),
                    selected: _selectedCategoryFilter == 'doubt',
                    selectedColor: AppColors.error.withValues(alpha: 0.25),
                    onSelected: (_) => setState(() => _selectedCategoryFilter = 'doubt'),
                  ),
                  const SizedBox(width: 8),
                  ChoiceChip(
                    label: const Text('Notes Share'),
                    selected: _selectedCategoryFilter == 'notes_share',
                    selectedColor: AppColors.secondary.withValues(alpha: 0.25),
                    onSelected: (_) => setState(() => _selectedCategoryFilter = 'notes_share'),
                  ),
                  const SizedBox(width: 8),
                  ChoiceChip(
                    label: const Text('Career & Placements'),
                    selected: _selectedCategoryFilter == 'career',
                    selectedColor: AppColors.success.withValues(alpha: 0.25),
                    onSelected: (_) => setState(() => _selectedCategoryFilter = 'career'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Posts List
            Expanded(
              child: admin.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : posts.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.dynamic_feed_outlined, size: 56, color: Colors.white.withValues(alpha: 0.4)),
                              const SizedBox(height: 12),
                              const Text(
                                'No Community Posts Found',
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Tap "+ New Post" below to start an official campus discussion or guidance thread.',
                                style: TextStyle(color: Colors.white.withValues(alpha: 0.6), fontSize: 12),
                              ),
                            ],
                          ),
                        )
                      : ListView.separated(
                          itemCount: posts.length,
                          separatorBuilder: (context, index) => const SizedBox(height: 10),
                          itemBuilder: (context, index) {
                            final post = posts[index];

                            return Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: const Color(0xFF0F1218),
                                borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
                                border: Border.all(
                                  color: post.isPinned
                                      ? AppColors.primary.withValues(alpha: 0.5)
                                      : const Color(0xFF27272A),
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      if (post.isPinned) ...[
                                        const Icon(Icons.push_pin_rounded, size: 14, color: AppColors.primary),
                                        const SizedBox(width: 4),
                                        const Text(
                                          'PINNED',
                                          style: TextStyle(fontSize: 9, fontWeight: FontWeight.w900, color: AppColors.primary),
                                        ),
                                        const SizedBox(width: 8),
                                      ],
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: Colors.white.withValues(alpha: 0.06),
                                          borderRadius: BorderRadius.circular(4),
                                        ),
                                        child: Text(
                                          post.category.toUpperCase(),
                                          style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Color(0xFF94A3B8)),
                                        ),
                                      ),
                                      const Spacer(),
                                      IconButton(
                                        icon: Icon(
                                          post.isPinned ? Icons.push_pin_rounded : Icons.push_pin_outlined,
                                          size: 18,
                                          color: post.isPinned ? AppColors.primary : Colors.white54,
                                        ),
                                        tooltip: post.isPinned ? 'Unpin Post' : 'Pin Post',
                                        onPressed: () => admin.togglePinCommunityPost(post.id, !post.isPinned),
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.delete_outline_rounded, size: 18, color: AppColors.error),
                                        tooltip: 'Delete Post',
                                        onPressed: () async {
                                          final success = await admin.deleteCommunityPost(post.id);
                                          if (context.mounted) {
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              SnackBar(
                                                content: Text(success ? 'Post deleted.' : 'Failed to delete.'),
                                                backgroundColor: success ? AppColors.success : AppColors.error,
                                              ),
                                            );
                                          }
                                        },
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    post.title,
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.white),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    post.content,
                                    style: TextStyle(fontSize: 12, color: Colors.white.withValues(alpha: 0.7)),
                                    maxLines: 3,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 10),
                                  Row(
                                    children: [
                                      Text(
                                        'Author: ${post.authorName ?? post.authorId}',
                                        style: TextStyle(fontSize: 11, color: Colors.white.withValues(alpha: 0.5)),
                                      ),
                                      const Spacer(),
                                      Text(
                                        '▲ ${post.upvotesCount} upvotes • 💬 ${post.commentsCount} comments',
                                        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF38BDF8)),
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
