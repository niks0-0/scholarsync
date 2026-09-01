import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/models/chat_room.dart';
import '../admin_provider.dart';

/// Complete Realtime Chat Management Studio for ScholarSync App Owner.
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
    String selectedType = 'subject';
    String? selectedSubjectId;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) => AlertDialog(
          title: const Text('Create New Academic Chat Channel'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Channel Name',
                    hintText: 'e.g. Design & Analysis of Algorithms',
                  ),
                ),
                const SizedBox(height: 16),
                const Text('Channel Category', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: [
                    ChoiceChip(
                      label: const Text('Subject Channel'),
                      selected: selectedType == 'subject',
                      selectedColor: AppColors.primary.withValues(alpha: 0.2),
                      onSelected: (_) => setModalState(() => selectedType = 'subject'),
                    ),
                    ChoiceChip(
                      label: const Text('Batch Lounge'),
                      selected: selectedType == 'batch',
                      selectedColor: AppColors.secondary.withValues(alpha: 0.2),
                      onSelected: (_) => setModalState(() => selectedType = 'batch'),
                    ),
                    ChoiceChip(
                      label: const Text('Club Channel'),
                      selected: selectedType == 'club',
                      selectedColor: AppColors.warning.withValues(alpha: 0.2),
                      onSelected: (_) => setModalState(() => selectedType = 'club'),
                    ),
                    ChoiceChip(
                      label: const Text('Notice Broadcast'),
                      selected: selectedType == 'broadcast',
                      selectedColor: AppColors.accent.withValues(alpha: 0.2),
                      onSelected: (_) => setModalState(() => selectedType = 'broadcast'),
                    ),
                  ],
                ),
                if (selectedType == 'subject') ...[
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    initialValue: selectedSubjectId,
                    decoration: const InputDecoration(
                      labelText: 'Linked Subject',
                      border: OutlineInputBorder(),
                    ),
                    items: admin.subjects.map((s) {
                      return DropdownMenuItem(
                        value: s.id,
                        child: Text('${s.subjectCode} - ${s.subjectName}', overflow: TextOverflow.ellipsis),
                      );
                    }).toList(),
                    onChanged: (val) => setModalState(() => selectedSubjectId = val),
                  ),
                ],
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            FilledButton(
              style: FilledButton.styleFrom(backgroundColor: AppColors.primary),
              onPressed: () async {
                if (nameController.text.trim().isEmpty) return;
                Navigator.pop(ctx);
                final room = ChatRoom(
                  id: '',
                  name: nameController.text.trim(),
                  type: selectedType,
                  subjectId: selectedSubjectId,
                );
                final success = await admin.createChatRoom(room);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(success ? 'Chat room created.' : 'Failed to create room.'),
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
                          '# ${room.name}',
                          style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: Colors.white),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          'Live Message Stream & Moderation Inspector',
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
                          return Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: const Color(0xFF141418),
                              borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
                              border: Border.all(color: const Color(0xFF27272A)),
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
                                      Text(
                                        msg.senderName ?? msg.senderId,
                                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.white),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        msg.content,
                                        style: TextStyle(fontSize: 13, color: Colors.white.withValues(alpha: 0.9)),
                                      ),
                                    ],
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete_outline_rounded, size: 18, color: AppColors.error),
                                  tooltip: 'Delete Message',
                                  onPressed: () async {
                                    final success = await admin.deleteChatMessage(msg.id);
                                    if (context.mounted) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text(success ? 'Message deleted.' : 'Failed to delete.'),
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
                        '${rooms.length} active channels across subjects, batches, and clubs',
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

                            return Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: const Color(0xFF0F1218),
                                borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
                                border: Border.all(color: const Color(0xFF27272A)),
                              ),
                              child: Row(
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
                                        Text(
                                          room.name,
                                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.white),
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
                                                style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Color(0xFF94A3B8)),
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
                                  IconButton(
                                    icon: const Icon(Icons.remove_red_eye_outlined, size: 20, color: AppColors.primary),
                                    tooltip: 'Inspect Messages',
                                    onPressed: () => _inspectRoomMessages(context, room),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete_outline_rounded, size: 20, color: AppColors.error),
                                    tooltip: 'Delete Room',
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
