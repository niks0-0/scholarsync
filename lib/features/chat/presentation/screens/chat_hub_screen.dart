import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../admin/presentation/admin_provider.dart';
import 'chat_room_screen.dart';

/// Student Academic Community & Realtime Chat Hub with Clean Modern Minimalist Design.
class ChatHubScreen extends StatefulWidget {
  const ChatHubScreen({super.key});

  @override
  State<ChatHubScreen> createState() => _ChatHubScreenState();
}

class _ChatHubScreenState extends State<ChatHubScreen> {
  String? _selectedCategory;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminProvider>().loadChatRooms();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final admin = context.watch<AdminProvider>();
    final allRooms = admin.chatRooms;

    final filteredRooms = allRooms.where((r) {
      if (_selectedCategory != null && r.type != _selectedCategory) return false;
      if (_searchQuery.isNotEmpty) {
        final q = _searchQuery.toLowerCase();
        final nameMatch = r.name.toLowerCase().contains(q);
        final subMatch = r.subjectName?.toLowerCase().contains(q) ?? false;
        return nameMatch || subMatch;
      }
      return true;
    }).toList();

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.spacingLg,
            vertical: AppDimensions.spacingMd,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Campus Chat Lounges',
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.5,
                        ),
                      ),
                      Text(
                        'Real-time academic discussions & study groups',
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                  IconButton.filledTonal(
                    icon: const Icon(Icons.refresh_rounded),
                    onPressed: () => admin.loadChatRooms(),
                    tooltip: 'Refresh Channels',
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // Search Box
              TextField(
                controller: _searchController,
                style: TextStyle(
                  color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                  fontSize: 13,
                ),
                decoration: InputDecoration(
                  hintText: 'Search academic channels...',
                  hintStyle: TextStyle(
                    color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                  ),
                  prefixIcon: Icon(
                    Icons.search_rounded,
                    color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                    size: 20,
                  ),
                  filled: true,
                  fillColor: isDark ? AppColors.darkSurfaceVariant : AppColors.surfaceVariant,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
                    borderSide: BorderSide(
                      color: isDark ? AppColors.darkBorder : AppColors.border,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
                    borderSide: BorderSide(
                      color: isDark ? AppColors.darkBorder : AppColors.border,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
                    borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
                  ),
                ),
                onChanged: (val) => setState(() => _searchQuery = val.trim()),
              ),
              const SizedBox(height: 12),

              // Category Selector Chips
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    ChoiceChip(
                      label: const Text('All Channels'),
                      selected: _selectedCategory == null,
                      onSelected: (_) => setState(() => _selectedCategory = null),
                    ),
                    const SizedBox(width: 8),
                    ChoiceChip(
                      label: const Text('Subjects'),
                      selected: _selectedCategory == 'subject',
                      onSelected: (_) => setState(() => _selectedCategory = 'subject'),
                    ),
                    const SizedBox(width: 8),
                    ChoiceChip(
                      label: const Text('Batch Lounges'),
                      selected: _selectedCategory == 'batch',
                      onSelected: (_) => setState(() => _selectedCategory = 'batch'),
                    ),
                    const SizedBox(width: 8),
                    ChoiceChip(
                      label: const Text('Clubs'),
                      selected: _selectedCategory == 'club',
                      onSelected: (_) => setState(() => _selectedCategory = 'club'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Channel Cards List
              Expanded(
                child: admin.isLoading && allRooms.isEmpty
                    ? const Center(child: CircularProgressIndicator())
                    : filteredRooms.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.forum_outlined,
                                  size: 48,
                                  color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  'No Channels Found',
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Try clearing your search or category filter.',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          )
                        : ListView.separated(
                            itemCount: filteredRooms.length,
                            separatorBuilder: (context, index) => const SizedBox(height: 10),
                            itemBuilder: (context, index) {
                              final room = filteredRooms[index];
                              final isSubject = room.type == 'subject';
                              final isLocked = room.isLocked;

                              return InkWell(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => ChatRoomScreen(room: room),
                                    ),
                                  );
                                },
                                borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
                                child: Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: isDark ? AppColors.darkSurface : Colors.white,
                                    borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
                                    border: Border.all(
                                      color: isLocked
                                          ? AppColors.error.withValues(alpha: 0.4)
                                          : (isDark ? AppColors.darkBorder : AppColors.border),
                                    ),
                                    boxShadow: isDark
                                        ? null
                                        : [
                                            BoxShadow(
                                              color: Colors.black.withValues(alpha: 0.03),
                                              blurRadius: 8,
                                              offset: const Offset(0, 2),
                                            ),
                                          ],
                                  ),
                                  child: Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(10),
                                        decoration: BoxDecoration(
                                          color: (isSubject
                                                  ? AppColors.primary
                                                  : AppColors.secondary)
                                              .withValues(alpha: 0.12),
                                          borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
                                        ),
                                        child: Icon(
                                          isSubject ? Icons.tag_rounded : Icons.forum_rounded,
                                          size: 22,
                                          color: isSubject ? AppColors.primary : AppColors.secondary,
                                        ),
                                      ),
                                      const SizedBox(width: 14),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                Flexible(
                                                  child: Text(
                                                    room.name,
                                                    style: theme.textTheme.titleSmall?.copyWith(
                                                      fontWeight: FontWeight.w700,
                                                    ),
                                                    maxLines: 1,
                                                    overflow: TextOverflow.ellipsis,
                                                  ),
                                                ),
                                                if (isLocked) ...[
                                                  const SizedBox(width: 6),
                                                  Container(
                                                    padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                                                    decoration: BoxDecoration(
                                                      color: AppColors.error.withValues(alpha: 0.15),
                                                      borderRadius: BorderRadius.circular(4),
                                                      border: Border.all(color: AppColors.error.withValues(alpha: 0.5)),
                                                    ),
                                                    child: const Text(
                                                      'READ ONLY',
                                                      style: TextStyle(
                                                        fontSize: 8,
                                                        fontWeight: FontWeight.bold,
                                                        color: AppColors.error,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ],
                                            ),
                                            const SizedBox(height: 4),
                                            Row(
                                              children: [
                                                Container(
                                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                                  decoration: BoxDecoration(
                                                    color: isDark
                                                        ? AppColors.darkSurfaceVariant
                                                        : AppColors.surfaceVariant,
                                                    borderRadius: BorderRadius.circular(4),
                                                  ),
                                                  child: Text(
                                                    room.type.toUpperCase(),
                                                    style: theme.textTheme.labelSmall?.copyWith(
                                                      fontSize: 9,
                                                      fontWeight: FontWeight.w700,
                                                      color: isDark
                                                          ? AppColors.darkTextSecondary
                                                          : AppColors.textSecondary,
                                                    ),
                                                  ),
                                                ),
                                                if (room.subjectName != null) ...[
                                                  const SizedBox(width: 6),
                                                  Expanded(
                                                    child: Text(
                                                      room.subjectName!,
                                                      style: theme.textTheme.bodySmall?.copyWith(
                                                        color: isDark
                                                            ? AppColors.darkTextSecondary
                                                            : AppColors.textSecondary,
                                                        fontSize: 11,
                                                      ),
                                                      maxLines: 1,
                                                      overflow: TextOverflow.ellipsis,
                                                    ),
                                                  ),
                                                ],
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                      Icon(
                                        Icons.chevron_right_rounded,
                                        color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
