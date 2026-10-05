import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../auth/auth_provider.dart';
import '../../../profile/presentation/profile_provider.dart';
import '../chat_provider.dart';
import 'chat_room_screen.dart';

/// Student Academic Community & Realtime Chat Hub wired directly to live Supabase backend.
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
      final collegeId = context.read<ProfileProvider>().profile?.collegeId;
      context.read<ChatProvider>().loadRooms(collegeId: collegeId);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _openCreateRoomSheet() {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final nameCtrl = TextEditingController();
    final descCtrl = TextEditingController();
    String selectedCat = 'academic';
    String selectedPolicy = 'public_academic';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: isDark ? AppColors.darkSurface : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setSheetState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 20,
                bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Request New Study Lounge',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close_rounded, size: 20),
                          onPressed: () => Navigator.pop(ctx),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Student rooms require approval from the campus moderation team before becoming visible.',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: nameCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Room Name',
                        hintText: 'e.g., Computer Networks Exam Prep',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: descCtrl,
                      maxLines: 2,
                      decoration: const InputDecoration(
                        labelText: 'Description / Purpose',
                        hintText: 'What topics or projects will be discussed?',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      value: selectedCat,
                      decoration: const InputDecoration(
                        labelText: 'Category',
                        border: OutlineInputBorder(),
                      ),
                      items: const [
                        DropdownMenuItem(value: 'academic', child: Text('Academic & Curriculum')),
                        DropdownMenuItem(value: 'project_study', child: Text('Project & Study Group')),
                        DropdownMenuItem(value: 'interest_skill', child: Text('Skills & Tech Club')),
                        DropdownMenuItem(value: 'events_activities', child: Text('Campus Activities')),
                      ],
                      onChanged: (val) {
                        if (val != null) setSheetState(() => selectedCat = val);
                      },
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      value: selectedPolicy,
                      decoration: const InputDecoration(
                        labelText: 'Joining Policy',
                        border: OutlineInputBorder(),
                      ),
                      items: const [
                        DropdownMenuItem(value: 'public_academic', child: Text('Open to Verified Students')),
                        DropdownMenuItem(value: 'college_verified', child: Text('Same College Only')),
                        DropdownMenuItem(value: 'department_semester', child: Text('Same Branch & Semester')),
                        DropdownMenuItem(value: 'approval_required', child: Text('Approval Required to Join')),
                      ],
                      onChanged: (val) {
                        if (val != null) setSheetState(() => selectedPolicy = val);
                      },
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        style: FilledButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        icon: const Icon(Icons.send_rounded, size: 18),
                        label: const Text('Submit Request for Review', style: TextStyle(fontWeight: FontWeight.w700)),
                        onPressed: () async {
                          final name = nameCtrl.text.trim();
                          if (name.isEmpty) return;

                          final user = context.read<AuthProvider>().currentUser;
                          final profile = context.read<ProfileProvider>().profile;
                          if (user == null) return;

                          Navigator.pop(ctx);
                          final ok = await context.read<ChatProvider>().submitRoomCreation(
                                requesterId: user.uid,
                                name: name,
                                category: selectedCat,
                                description: descCtrl.text.trim(),
                                collegeId: profile?.collegeId,
                                branch: profile?.branch,
                                semester: profile?.semester,
                              );

                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(ok
                                    ? 'Study lounge request submitted! Moderators will review it shortly.'
                                    : 'Failed to submit room request. Please try again.'),
                                backgroundColor: ok ? AppColors.success : AppColors.error,
                              ),
                            );
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final chat = context.watch<ChatProvider>();
    final allRooms = chat.rooms;
    final profile = context.watch<ProfileProvider>().profile;

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
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openCreateRoomSheet,
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.black,
        icon: const Icon(Icons.add_rounded),
        label: const Text('New Lounge', style: TextStyle(fontWeight: FontWeight.w700)),
      ),
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
                    onPressed: () => chat.loadRooms(collegeId: profile?.collegeId),
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
                      label: const Text('Curriculum'),
                      selected: _selectedCategory == 'academic',
                      onSelected: (_) => setState(() => _selectedCategory = 'academic'),
                    ),
                    const SizedBox(width: 8),
                    ChoiceChip(
                      label: const Text('Projects'),
                      selected: _selectedCategory == 'project_study',
                      onSelected: (_) => setState(() => _selectedCategory = 'project_study'),
                    ),
                    const SizedBox(width: 8),
                    ChoiceChip(
                      label: const Text('Skills & Tech'),
                      selected: _selectedCategory == 'interest_skill',
                      onSelected: (_) => setState(() => _selectedCategory = 'interest_skill'),
                    ),
                    const SizedBox(width: 8),
                    ChoiceChip(
                      label: const Text('Announcements'),
                      selected: _selectedCategory == 'official_announcements',
                      onSelected: (_) => setState(() => _selectedCategory = 'official_announcements'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Channel Cards List
              Expanded(
                child: chat.isLoadingRooms && allRooms.isEmpty
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
                                  'Tap "New Lounge" below to request a study group.',
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
