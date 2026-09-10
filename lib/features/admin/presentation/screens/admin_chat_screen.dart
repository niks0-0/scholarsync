import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/models/chat_room.dart';
import '../../domain/models/chat_member.dart';
import '../admin_provider.dart';

/// Complete Realtime Chat Management Studio for ScholarSync App Owner.
/// Supports Safe-Lock emergency lockdown, active roster inspection, and contextual message moderation.
class AdminChatScreen extends StatefulWidget {
  const AdminChatScreen({super.key});

  @override
  State<AdminChatScreen> createState() => _AdminChatScreenState();
}

class _AdminChatScreenState extends State<AdminChatScreen> {
  String? _selectedTypeFilter;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminProvider>().loadChatRooms();
    });
  }

  void _openCreateRoomDialog(BuildContext context) {
    final admin = context.read<AdminProvider>();
    final nameController = TextEditingController();
    final branchController = TextEditingController();
    int? selectedSemester;
    String selectedType = 'subject';
    String? selectedSubjectId;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) => AlertDialog(
          backgroundColor: const Color(0xFF141418),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppDimensions.radiusLg)),
          title: const Text('Create New Academic Chat Channel', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: nameController,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    labelText: 'Channel Name',
                    labelStyle: TextStyle(color: Colors.white70),
                    hintText: 'e.g. Design & Analysis of Algorithms',
                    hintStyle: TextStyle(color: Colors.white30),
                  ),
                ),
                const SizedBox(height: 16),
                const Text('Channel Category', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.white70)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: [
                    ChoiceChip(
                      label: const Text('Subject Channel'),
                      selected: selectedType == 'subject',
                      selectedColor: AppColors.primary.withValues(alpha: 0.25),
                      onSelected: (_) => setModalState(() => selectedType = 'subject'),
                    ),
                    ChoiceChip(
                      label: const Text('Batch Lounge'),
                      selected: selectedType == 'batch',
                      selectedColor: AppColors.secondary.withValues(alpha: 0.25),
                      onSelected: (_) => setModalState(() => selectedType = 'batch'),
                    ),
                    ChoiceChip(
                      label: const Text('Club Channel'),
                      selected: selectedType == 'club',
                      selectedColor: AppColors.warning.withValues(alpha: 0.25),
                      onSelected: (_) => setModalState(() => selectedType = 'club'),
                    ),
                    ChoiceChip(
                      label: const Text('Broadcast'),
                      selected: selectedType == 'broadcast',
                      selectedColor: AppColors.accent.withValues(alpha: 0.25),
                      onSelected: (_) => setModalState(() => selectedType = 'broadcast'),
                    ),
                  ],
                ),
                if (selectedType == 'subject') ...[
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    initialValue: selectedSubjectId,
                    dropdownColor: const Color(0xFF1A1A22),
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                      labelText: 'Linked Subject',
                      labelStyle: TextStyle(color: Colors.white70),
                      border: OutlineInputBorder(),
                    ),
                    items: admin.subjects.map((s) {
                      return DropdownMenuItem(
                        value: s.id,
                        child: Text('${s.subjectCode} - ${s.subjectName}', overflow: TextOverflow.ellipsis),
                      );
                    }).toList(),
                    onChanged: (val) {
                      setModalState(() {
                        selectedSubjectId = val;
                        final sub = admin.subjects.firstWhere((s) => s.id == val);
                        nameController.text = sub.subjectName;
                        branchController.text = sub.branch;
                        selectedSemester = sub.semester;
                      });
                    },
                  ),
                ],
                const SizedBox(height: 12),
                TextField(
                  controller: branchController,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    labelText: 'Target Branch (Optional)',
                    labelStyle: TextStyle(color: Colors.white70),
                    hintText: 'e.g. Computer Science',
                    hintStyle: TextStyle(color: Colors.white30),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel', style: TextStyle(color: Colors.white70)),
            ),
            FilledButton(
              style: FilledButton.styleFrom(backgroundColor: AppColors.primary),
              onPressed: () async {
                final name = nameController.text.trim();
                if (name.isEmpty) return;

                // Check duplicate
                final isDuplicate = admin.chatRooms.any(
                  (r) => r.name.toLowerCase() == name.toLowerCase() && r.type == selectedType,
                );
                if (isDuplicate) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('A channel with this exact name and category already exists.'),
                      backgroundColor: AppColors.error,
                    ),
                  );
                  return;
                }

                Navigator.pop(ctx);
                final room = ChatRoom(
                  id: '',
                  name: name,
                  type: selectedType,
                  subjectId: selectedSubjectId,
                  branch: branchController.text.trim().isNotEmpty ? branchController.text.trim() : null,
                  semester: selectedSemester,
                );
                final success = await admin.createChatRoom(room);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(success ? 'Chat room created successfully.' : 'Failed to create room.'),
                      backgroundColor: success ? AppColors.success : AppColors.error,
                    ),
                  );
                }
              },
              child: const Text('Create Channel', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black)),
            ),
          ],
        ),
      ),
    );
  }

  void _openSafeLockDialog(BuildContext context, ChatRoom room) {
    final admin = context.read<AdminProvider>();
    final isLocked = room.isLocked;
    final reasonController = TextEditingController(text: isLocked ? '' : 'Emergency moderation review in progress');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF141418),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppDimensions.radiusLg)),
        title: Row(
          children: [
            Icon(
              isLocked ? Icons.lock_open_rounded : Icons.lock_rounded,
              color: isLocked ? AppColors.success : AppColors.error,
            ),
            const SizedBox(width: 8),
            Text(
              isLocked ? 'Unlock Channel' : 'Safe-Lock Channel',
              style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              isLocked
                  ? 'Are you sure you want to unlock "${room.name}"? Students will regain message sending permissions immediately.'
                  : 'Safe-Locking "${room.name}" will freeze new message submissions immediately while preserving full read-only history for students.',
              style: TextStyle(fontSize: 13, color: Colors.white.withValues(alpha: 0.8)),
            ),
            if (!isLocked) ...[
              const SizedBox(height: 16),
              TextField(
                controller: reasonController,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: 'Lock Reason (Visible to Students)',
                  labelStyle: TextStyle(color: Colors.white70),
                  hintText: 'e.g. Channel under review for spam',
                  hintStyle: TextStyle(color: Colors.white30),
                  border: OutlineInputBorder(),
                ),
                maxLines: 2,
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel', style: TextStyle(color: Colors.white70)),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: isLocked ? AppColors.success : AppColors.error,
            ),
            onPressed: () async {
              Navigator.pop(ctx);
              final success = await admin.toggleRoomLock(
                room.id,
                !isLocked,
                reason: isLocked ? null : reasonController.text.trim(),
              );
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      success
                          ? (isLocked ? 'Room unlocked.' : 'Room placed into Safe-Lock read-only mode.')
                          : 'Failed to update lock status.',
                    ),
                    backgroundColor: success ? AppColors.success : AppColors.error,
                  ),
                );
              }
            },
            child: Text(
              isLocked ? 'Unlock Channel' : 'Confirm Safe-Lock',
              style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  void _inspectRoomMembers(BuildContext context, ChatRoom room) {
    final admin = context.read<AdminProvider>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF0C0C0E),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppDimensions.radiusXl)),
      ),
      builder: (ctx) => FutureBuilder<List<ChatMember>>(
        future: admin.fetchRoomMembers(room.id),
        builder: (context, snapshot) {
          final members = snapshot.data ?? [];

          return Container(
            height: MediaQuery.of(context).size.height * 0.75,
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
                          Text(
                            'Active Roster: #${room.name}',
                            style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 17, color: Colors.white),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            '${members.length} enrolled members in room partition',
                            style: TextStyle(fontSize: 12, color: Colors.white.withValues(alpha: 0.6)),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded, color: Colors.white),
                      onPressed: () => Navigator.pop(ctx),
                    ),
                  ],
                ),
                const Divider(color: Color(0xFF27272A)),
                Expanded(
                  child: snapshot.connectionState == ConnectionState.waiting
                      ? const Center(child: CircularProgressIndicator())
                      : members.isEmpty
                          ? Center(
                              child: Text(
                                'No members registered in this room.',
                                style: TextStyle(color: Colors.white.withValues(alpha: 0.5)),
                              ),
                            )
                          : ListView.separated(
                              itemCount: members.length,
                              separatorBuilder: (context, index) => const SizedBox(height: 8),
                              itemBuilder: (context, index) {
                                final m = members[index];
                                return Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF141418),
                                    borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
                                    border: Border.all(color: const Color(0xFF27272A)),
                                  ),
                                  child: Row(
                                    children: [
                                       CircleAvatar(
                                        radius: 16,
                                        backgroundColor: AppColors.primary.withValues(alpha: 0.2),
                                        child: Text(
                                          (m.userName?.isNotEmpty ?? false) ? m.userName![0].toUpperCase() : 'U',
                                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.primary),
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              m.userName ?? 'Member',
                                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.white),
                                            ),
                                            Text(
                                              'Role: ${m.role.toUpperCase()} • ID: ${m.userId.substring(0, m.userId.length > 8 ? 8 : m.userId.length)}...',
                                              style: TextStyle(fontSize: 11, color: Colors.white.withValues(alpha: 0.5)),
                                            ),
                                          ],
                                        ),
                                      ),
                                      PopupMenuButton<String>(
                                        icon: const Icon(Icons.more_vert_rounded, color: Colors.white70),
                                        color: const Color(0xFF1E2028),
                                        onSelected: (val) async {
                                          if (val == 'mute_24h') {
                                            await admin.moderateUser(
                                              userId: m.userId,
                                              action: 'mute',
                                              durationMinutes: 1440,
                                              reason: 'Room administrative mute by admin',
                                              roomId: room.id,
                                            );
                                          } else if (val == 'mute_7d') {
                                            await admin.moderateUser(
                                              userId: m.userId,
                                              action: 'mute',
                                              durationMinutes: 10080,
                                              reason: 'Room administrative 7-day mute by admin',
                                              roomId: room.id,
                                            );
                                          } else if (val == 'ban') {
                                            await admin.moderateUser(
                                              userId: m.userId,
                                              action: 'ban',
                                              reason: 'Banned from chat room by admin',
                                              roomId: room.id,
                                            );
                                          }
                                          if (context.mounted) {
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              const SnackBar(
                                                content: Text('User moderation action applied.'),
                                                backgroundColor: AppColors.success,
                                              ),
                                            );
                                          }
                                        },
                                        itemBuilder: (context) => [
                                          const PopupMenuItem(
                                            value: 'mute_24h',
                                            child: Text('Mute User (24h)', style: TextStyle(color: AppColors.warning)),
                                          ),
                                          const PopupMenuItem(
                                            value: 'mute_7d',
                                            child: Text('Mute User (7 Days)', style: TextStyle(color: Color(0xFFF97316))),
                                          ),
                                          const PopupMenuItem(
                                            value: 'ban',
                                            child: Text('Ban User from Room', style: TextStyle(color: AppColors.error)),
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
          );
        },
      ),
    );
  }

  void _inspectRoomMessages(BuildContext context, ChatRoom room) {
    context.read<AdminProvider>().loadRoomMessages(room.id);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF0C0C0E),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppDimensions.radiusXl)),
      ),
      builder: (ctx) => Consumer<AdminProvider>(
        builder: (context, admin, _) => Container(
          height: MediaQuery.of(context).size.height * 0.8,
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
                        Text(
                          '# ${room.name}',
                          style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: Colors.white),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          'Live Message Stream & Realtime Moderation',
                          style: TextStyle(fontSize: 12, color: Colors.white.withValues(alpha: 0.6)),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded, color: Colors.white),
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ],
              ),
              if (room.isLocked) ...[
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.error.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: AppColors.error.withValues(alpha: 0.5)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.lock_rounded, size: 14, color: AppColors.error),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          'SAFE-LOCKED: ${room.lockReason ?? 'Read-only mode enabled by Administrator.'}',
                          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              const Divider(color: Color(0xFF27272A), height: 20),
              Expanded(
                child: admin.activeRoomMessages.isEmpty
                    ? Center(
                        child: Text(
                          'No messages posted in this channel yet.',
                          style: TextStyle(color: Colors.white.withValues(alpha: 0.5)),
                        ),
                      )
                    : ListView.separated(
                        itemCount: admin.activeRoomMessages.length,
                        separatorBuilder: (context, index) => const SizedBox(height: 8),
                        itemBuilder: (context, index) {
                          final msg = admin.activeRoomMessages[index];
                          final isDeleted = msg.isDeleted;

                          return Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: isDeleted
                                  ? const Color(0xFF141418).withValues(alpha: 0.5)
                                  : const Color(0xFF141418),
                              borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
                              border: Border.all(
                                color: isDeleted ? const Color(0xFF1E2028) : const Color(0xFF27272A),
                              ),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                CircleAvatar(
                                  radius: 14,
                                  backgroundColor: AppColors.primary.withValues(alpha: 0.2),
                                  child: Text(
                                    msg.senderName?.isNotEmpty ?? false ? msg.senderName![0].toUpperCase() : 'U',
                                    style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.primary),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Text(
                                            msg.senderName ?? msg.senderId,
                                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.white),
                                          ),
                                          if (isDeleted) ...[
                                            const SizedBox(width: 6),
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                                              decoration: BoxDecoration(
                                                color: AppColors.error.withValues(alpha: 0.2),
                                                borderRadius: BorderRadius.circular(4),
                                              ),
                                              child: const Text(
                                                'SOFT-DELETED',
                                                style: TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: AppColors.error),
                                              ),
                                            ),
                                          ],
                                        ],
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        isDeleted
                                            ? '[Message removed by Moderator: ${msg.deletionReason ?? 'Policy violation'}]'
                                            : msg.content,
                                        style: TextStyle(
                                          fontSize: 13,
                                          fontStyle: isDeleted ? FontStyle.italic : FontStyle.normal,
                                          color: isDeleted
                                              ? Colors.white.withValues(alpha: 0.4)
                                              : Colors.white.withValues(alpha: 0.9),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                if (!isDeleted)
                                  IconButton(
                                    icon: const Icon(Icons.delete_sweep_outlined, size: 18, color: AppColors.error),
                                    tooltip: 'Moderate / Soft Delete Message',
                                    onPressed: () async {
                                      final success = await admin.moderateChatMessage(
                                        messageId: msg.id,
                                        action: 'soft_delete',
                                        reason: 'Admin deleted from live inspector stream',
                                      );
                                      if (context.mounted) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(
                                            content: Text(success ? 'Message soft-deleted and logged.' : 'Failed to delete.'),
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
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final admin = context.watch<AdminProvider>();
    final rooms = _selectedTypeFilter == null
        ? admin.chatRooms
        : admin.chatRooms.where((r) => r.type == _selectedTypeFilter).toList();

    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openCreateRoomDialog(context),
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add_comment_rounded, color: Colors.black),
        label: const Text('New Channel', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Bar
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Chat Management Studio',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: Colors.white),
                      ),
                      Text(
                        '${rooms.length} active channels with Safe-Lock control & roster inspector',
                        style: TextStyle(fontSize: 12, color: Colors.white.withValues(alpha: 0.6)),
                      ),
                    ],
                  ),
                ),
                IconButton.filledTonal(
                  icon: const Icon(Icons.refresh_rounded),
                  tooltip: 'Refresh Channels',
                  onPressed: () => admin.loadChatRooms(),
                ),
              ],
            ),
            const SizedBox(height: 14),

            // Channel Filter Chips
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  ChoiceChip(
                    label: const Text('All Channels'),
                    selected: _selectedTypeFilter == null,
                    selectedColor: AppColors.primary.withValues(alpha: 0.25),
                    onSelected: (_) => setState(() => _selectedTypeFilter = null),
                  ),
                  const SizedBox(width: 8),
                  ChoiceChip(
                    label: const Text('Subject Channels'),
                    selected: _selectedTypeFilter == 'subject',
                    selectedColor: const Color(0xFF0284C7).withValues(alpha: 0.25),
                    onSelected: (_) => setState(() => _selectedTypeFilter = 'subject'),
                  ),
                  const SizedBox(width: 8),
                  ChoiceChip(
                    label: const Text('Batch Lounges'),
                    selected: _selectedTypeFilter == 'batch',
                    selectedColor: const Color(0xFF4F46E5).withValues(alpha: 0.25),
                    onSelected: (_) => setState(() => _selectedTypeFilter = 'batch'),
                  ),
                  const SizedBox(width: 8),
                  ChoiceChip(
                    label: const Text('Club Channels'),
                    selected: _selectedTypeFilter == 'club',
                    selectedColor: const Color(0xFFD97706).withValues(alpha: 0.25),
                    onSelected: (_) => setState(() => _selectedTypeFilter = 'club'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Room List
            Expanded(
              child: admin.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : rooms.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.forum_outlined, size: 56, color: Colors.white.withValues(alpha: 0.4)),
                              const SizedBox(height: 12),
                              const Text(
                                'No Chat Channels Found',
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Create your first subject channel to enable student discussions.',
                                style: TextStyle(color: Colors.white.withValues(alpha: 0.6), fontSize: 12),
                              ),
                            ],
                          ),
                        )
                      : ListView.separated(
                          itemCount: rooms.length,
                          separatorBuilder: (context, index) => const SizedBox(height: 10),
                          itemBuilder: (context, index) {
                            final room = rooms[index];
                            final isSubject = room.type == 'subject';
                            final isLocked = room.isLocked;

                            return Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: const Color(0xFF0F1218),
                                borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
                                border: Border.all(
                                  color: isLocked
                                      ? AppColors.error.withValues(alpha: 0.5)
                                      : const Color(0xFF27272A),
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(10),
                                        decoration: BoxDecoration(
                                          color: (isSubject ? const Color(0xFF0284C7) : AppColors.secondary)
                                              .withValues(alpha: 0.15),
                                          borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
                                          border: Border.all(
                                            color: (isSubject ? const Color(0xFF0284C7) : AppColors.secondary)
                                                .withValues(alpha: 0.3),
                                          ),
                                        ),
                                        child: Icon(
                                          isSubject ? Icons.tag_rounded : Icons.forum_rounded,
                                          size: 20,
                                          color: isSubject ? const Color(0xFF38BDF8) : AppColors.secondary,
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
                                                    style: const TextStyle(
                                                      fontWeight: FontWeight.bold,
                                                      fontSize: 15,
                                                      color: Colors.white,
                                                    ),
                                                    maxLines: 1,
                                                    overflow: TextOverflow.ellipsis,
                                                  ),
                                                ),
                                                if (isLocked) ...[
                                                  const SizedBox(width: 8),
                                                  Container(
                                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                                    decoration: BoxDecoration(
                                                      color: AppColors.error.withValues(alpha: 0.2),
                                                      borderRadius: BorderRadius.circular(4),
                                                      border: Border.all(color: AppColors.error.withValues(alpha: 0.6)),
                                                    ),
                                                    child: const Row(
                                                      mainAxisSize: MainAxisSize.min,
                                                      children: [
                                                        Icon(Icons.lock_rounded, size: 10, color: AppColors.error),
                                                        SizedBox(width: 3),
                                                        Text(
                                                          'SAFE-LOCKED',
                                                          style: TextStyle(
                                                            fontSize: 9,
                                                            fontWeight: FontWeight.w900,
                                                            color: AppColors.error,
                                                          ),
                                                        ),
                                                      ],
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
                                                    color: Colors.white.withValues(alpha: 0.06),
                                                    borderRadius: BorderRadius.circular(4),
                                                  ),
                                                  child: Text(
                                                    room.type.toUpperCase(),
                                                    style: const TextStyle(
                                                      fontSize: 9,
                                                      fontWeight: FontWeight.bold,
                                                      color: Color(0xFF94A3B8),
                                                    ),
                                                  ),
                                                ),
                                                if (room.subjectName != null) ...[
                                                  const SizedBox(width: 6),
                                                  Expanded(
                                                    child: Text(
                                                      room.subjectName!,
                                                      style: TextStyle(fontSize: 11, color: Colors.white.withValues(alpha: 0.6)),
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
                                    ],
                                  ),
                                  if (isLocked && room.lockReason != null) ...[
                                    const SizedBox(height: 8),
                                    Text(
                                      'Reason: ${room.lockReason}',
                                      style: TextStyle(fontSize: 11, fontStyle: FontStyle.italic, color: Colors.white.withValues(alpha: 0.5)),
                                    ),
                                  ],
                                  const SizedBox(height: 12),
                                  const Divider(color: Color(0xFF1E2028), height: 1),
                                  const SizedBox(height: 8),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      TextButton.icon(
                                        icon: Icon(
                                          isLocked ? Icons.lock_open_rounded : Icons.lock_outline_rounded,
                                          size: 16,
                                          color: isLocked ? AppColors.success : AppColors.warning,
                                        ),
                                        label: Text(
                                          isLocked ? 'Unlock' : 'Safe-Lock',
                                          style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                            color: isLocked ? AppColors.success : AppColors.warning,
                                          ),
                                        ),
                                        onPressed: () => _openSafeLockDialog(context, room),
                                      ),
                                      TextButton.icon(
                                        icon: const Icon(Icons.people_outline_rounded, size: 16, color: Color(0xFF38BDF8)),
                                        label: const Text('Roster', style: TextStyle(fontSize: 12, color: Color(0xFF38BDF8))),
                                        onPressed: () => _inspectRoomMembers(context, room),
                                      ),
                                      TextButton.icon(
                                        icon: const Icon(Icons.remove_red_eye_outlined, size: 16, color: AppColors.primary),
                                        label: const Text('Inspect', style: TextStyle(fontSize: 12, color: AppColors.primary)),
                                        onPressed: () => _inspectRoomMessages(context, room),
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.delete_outline_rounded, size: 18, color: AppColors.error),
                                        tooltip: 'Delete Channel',
                                        onPressed: () async {
                                          final success = await admin.deleteChatRoom(room.id);
                                          if (context.mounted) {
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              SnackBar(
                                                content: Text(success ? 'Room deleted.' : 'Failed to delete room.'),
                                                backgroundColor: success ? AppColors.success : AppColors.error,
                                              ),
                                            );
                                          }
                                        },
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
