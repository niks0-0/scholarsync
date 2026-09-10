import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/uuid_helper.dart';
import '../../../admin/domain/models/chat_room.dart';
import '../../../admin/domain/models/chat_message.dart';
import '../../../admin/presentation/admin_provider.dart';
import '../../../auth/auth_provider.dart';
import '../../../profile/presentation/profile_provider.dart';

/// Production-Grade Student & Faculty Academic Chat Room with Safe-Lock, Anti-Spam & Reaction Engine.
class ChatRoomScreen extends StatefulWidget {
  const ChatRoomScreen({
    super.key,
    required this.room,
  });

  final ChatRoom room;

  @override
  State<ChatRoomScreen> createState() => _ChatRoomScreenState();
}

class _ChatRoomScreenState extends State<ChatRoomScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  ChatMessage? _replyingTo;
  bool _isSending = false;
  DateTime? _lastSendTime;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminProvider>().loadRoomMessages(widget.room.id);
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent + 80,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    }
  }

  Future<void> _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty || _isSending) return;

    if (widget.room.isLocked) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('This channel is in Safe-Lock read-only mode.'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    // Client-side rate limiting debounce (minimum 500ms between sends)
    final now = DateTime.now();
    if (_lastSendTime != null && now.difference(_lastSendTime!).inMilliseconds < 500) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please slow down before sending another message.'),
          backgroundColor: AppColors.warning,
        ),
      );
      return;
    }

    final profileProvider = context.read<ProfileProvider>();
    final userProfile = profileProvider.profile;
    final authUser = context.read<AuthProvider>().currentUser;
    final currentUserId = userProfile?.id ?? authUser?.uid ?? Supabase.instance.client.auth.currentUser?.id ?? 'anonymous';
    final currentUserName = userProfile?.fullName ?? authUser?.displayName ?? 'Student';

    setState(() {
      _isSending = true;
      _lastSendTime = now;
    });

    final clientMsgId = UuidHelper.generateV4();
    final message = ChatMessage(
      id: '',
      roomId: widget.room.id,
      senderId: currentUserId,
      senderName: currentUserName,
      senderAvatar: userProfile?.avatarUrl ?? authUser?.photoUrl,
      content: text,
      clientMessageId: clientMsgId,
      replyToId: _replyingTo?.id,
      createdAt: DateTime.now(),
    );

    _messageController.clear();
    final replyingBackup = _replyingTo;
    setState(() {
      _replyingTo = null;
    });

    final admin = context.read<AdminProvider>();
    final success = await admin.sendChatMessage(message);

    if (mounted) {
      setState(() {
        _isSending = false;
      });
      if (success) {
        _scrollToBottom();
      } else {
        setState(() {
          _replyingTo = replyingBackup;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(admin.errorMessage ?? 'Failed to send message. Please check connection.'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  void _openReactionPicker(ChatMessage message) {
    final profileProvider = context.read<ProfileProvider>();
    final currentUserId = profileProvider.profile?.id ??
        context.read<AuthProvider>().currentUser?.uid ??
        'anonymous';
    const reactions = ['👍', '❤️', '💡', '🔥', '👏', '🚀'];

    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF141418),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppDimensions.radiusLg)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Add Reaction',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.white),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: reactions.map((emoji) {
                return InkWell(
                  onTap: () async {
                    Navigator.pop(ctx);
                    await context.read<AdminProvider>().toggleMessageReaction(
                          message.id,
                          currentUserId,
                          emoji,
                        );
                    if (mounted) {
                      context.read<AdminProvider>().loadRoomMessages(widget.room.id);
                    }
                  },
                  borderRadius: BorderRadius.circular(30),
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFF202028),
                      shape: BoxShape.circle,
                      border: Border.all(color: const Color(0xFF27272A)),
                    ),
                    child: Text(emoji, style: const TextStyle(fontSize: 22)),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  void _openReportDialog(ChatMessage message) {
    final reasonController = TextEditingController();
    String selectedCategory = 'spam';

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) => AlertDialog(
          backgroundColor: const Color(0xFF141418),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppDimensions.radiusLg)),
          title: const Row(
            children: [
              Icon(Icons.report_problem_rounded, color: AppColors.error),
              SizedBox(width: 8),
              Text('Report Message to Admin', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 16)),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Reporting author: ${message.senderName ?? message.senderId}',
                style: const TextStyle(fontSize: 12, color: Colors.white70),
              ),
              const SizedBox(height: 12),
              const Text('Violation Category', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.white70)),
              const SizedBox(height: 6),
              Wrap(
                spacing: 6,
                children: [
                  ChoiceChip(
                    label: const Text('Spam / Flood'),
                    selected: selectedCategory == 'spam',
                    selectedColor: AppColors.warning.withValues(alpha: 0.25),
                    onSelected: (_) => setModalState(() => selectedCategory = 'spam'),
                  ),
                  ChoiceChip(
                    label: const Text('Harassment'),
                    selected: selectedCategory == 'harassment',
                    selectedColor: AppColors.error.withValues(alpha: 0.25),
                    onSelected: (_) => setModalState(() => selectedCategory = 'harassment'),
                  ),
                  ChoiceChip(
                    label: const Text('Inappropriate'),
                    selected: selectedCategory == 'inappropriate',
                    selectedColor: AppColors.primary.withValues(alpha: 0.25),
                    onSelected: (_) => setModalState(() => selectedCategory = 'inappropriate'),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TextField(
                controller: reasonController,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: 'Detailed Explanation',
                  labelStyle: TextStyle(color: Colors.white70),
                  hintText: 'Describe how this message violates community safety...',
                  hintStyle: TextStyle(color: Colors.white30),
                  border: OutlineInputBorder(),
                ),
                maxLines: 2,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel', style: TextStyle(color: Colors.white70)),
            ),
            FilledButton(
              style: FilledButton.styleFrom(backgroundColor: AppColors.error),
              onPressed: () async {
                Navigator.pop(ctx);
                final profileProvider = context.read<ProfileProvider>();
                final reporterId = profileProvider.profile?.id ??
                    context.read<AuthProvider>().currentUser?.uid ??
                    'student';

                try {
                  await Supabase.instance.client.from('moderation_reports').insert({
                    'reported_user_id': message.senderId,
                    'reporter_id': reporterId,
                    'entity_type': 'message',
                    'entity_id': message.id,
                    'reason': '$selectedCategory: ${reasonController.text.trim()}',
                    'priority': selectedCategory == 'harassment' ? 'high' : 'medium',
                    'status': 'pending',
                  });
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Report submitted to moderation queue.'),
                        backgroundColor: AppColors.success,
                      ),
                    );
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Failed to submit report: $e'), backgroundColor: AppColors.error),
                    );
                  }
                }
              },
              child: const Text('Submit Report', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final admin = context.watch<AdminProvider>();
    final profile = context.watch<ProfileProvider>().profile;
    final authUser = context.watch<AuthProvider>().currentUser;
    final isLocked = widget.room.isLocked;
    final currentUserId = profile?.id ?? authUser?.uid ?? Supabase.instance.client.auth.currentUser?.id;
    final isStudentSuspended = profile?.isSuspended ?? false;

    return Scaffold(
      backgroundColor: const Color(0xFF090A0E),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F1218),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Flexible(
                  child: Text(
                    '# ${widget.room.name}',
                    style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: Colors.white),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (isLocked) ...[
                  const SizedBox(width: 6),
                  const Icon(Icons.lock_rounded, size: 14, color: AppColors.error),
                ],
              ],
            ),
            Text(
              widget.room.subjectName ?? '${widget.room.type.toUpperCase()} Lounge',
              style: TextStyle(fontSize: 11, color: Colors.white.withValues(alpha: 0.6)),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: Colors.white70),
            tooltip: 'Refresh Stream',
            onPressed: () => admin.loadRoomMessages(widget.room.id),
          ),
        ],
      ),
      body: Column(
        children: [
          // Safe-Lock Read-Only Banner
          if (isLocked)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.error.withValues(alpha: 0.15),
                border: const Border(bottom: BorderSide(color: AppColors.error, width: 1)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.lock_outline_rounded, color: AppColors.error, size: 18),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'CHANNEL IS SAFE-LOCKED (READ ONLY)',
                          style: TextStyle(fontWeight: FontWeight.w900, fontSize: 11, color: AppColors.error),
                        ),
                        Text(
                          widget.room.lockReason ?? 'New submissions are temporarily frozen by administration.',
                          style: const TextStyle(fontSize: 11, color: Colors.white70),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

          // Student Suspension / Mute Banner
          if (isStudentSuspended)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              color: AppColors.warning.withValues(alpha: 0.15),
              child: const Row(
                children: [
                  Icon(Icons.volume_off_rounded, color: AppColors.warning, size: 16),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Your messaging privileges are restricted.',
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.warning),
                    ),
                  ),
                ],
              ),
            ),

          // Message Stream
          Expanded(
            child: admin.isLoading && admin.activeRoomMessages.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : admin.activeRoomMessages.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.chat_bubble_outline_rounded, size: 48, color: Colors.white.withValues(alpha: 0.3)),
                            const SizedBox(height: 12),
                            const Text(
                              'Start the Conversation',
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Be respectful and adhere to academic community guidelines.',
                              style: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: 12),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        controller: _scrollController,
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
                        itemCount: admin.activeRoomMessages.length,
                        itemBuilder: (context, index) {
                          final msg = admin.activeRoomMessages[index];
                          final isMe = msg.senderId == currentUserId;
                          final isDeleted = msg.isDeleted;

                          return _buildMessageBubble(msg, isMe: isMe, isDeleted: isDeleted);
                        },
                      ),
          ),

          // Replying To Preview Bar
          if (_replyingTo != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: const BoxDecoration(
                color: Color(0xFF141418),
                border: Border(top: BorderSide(color: Color(0xFF27272A))),
              ),
              child: Row(
                children: [
                  const Icon(Icons.reply_rounded, size: 16, color: AppColors.primary),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Replying to ${_replyingTo!.senderName ?? 'Student'}: "${_replyingTo!.content}"',
                      style: const TextStyle(fontSize: 12, color: Colors.white70),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded, size: 16, color: Colors.white70),
                    onPressed: () => setState(() => _replyingTo = null),
                  ),
                ],
              ),
            ),

          // Message Input Bar
          Container(
            padding: EdgeInsets.only(
              left: 14,
              right: 14,
              top: 10,
              bottom: MediaQuery.of(context).padding.bottom + 10,
            ),
            decoration: const BoxDecoration(
              color: Color(0xFF0F1218),
              border: Border(top: BorderSide(color: Color(0xFF1E2028))),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    enabled: !isLocked && !isStudentSuspended,
                    style: const TextStyle(color: Colors.white, fontSize: 14),
                    decoration: InputDecoration(
                      hintText: isLocked
                          ? 'Channel is in read-only mode'
                          : (isStudentSuspended ? 'Account is restricted' : 'Type a message...'),
                      hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.3)),
                      filled: true,
                      fillColor: const Color(0xFF181A22),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppDimensions.radiusXl),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    maxLines: null,
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton.filled(
                  icon: _isSending
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black),
                        )
                      : const Icon(Icons.send_rounded, size: 18, color: Colors.black),
                  style: IconButton.styleFrom(
                    backgroundColor: (!isLocked && !isStudentSuspended)
                        ? AppColors.primary
                        : Colors.white.withValues(alpha: 0.2),
                  ),
                  onPressed: (!isLocked && !isStudentSuspended) ? _sendMessage : null,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(ChatMessage msg, {required bool isMe, required bool isDeleted}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isMe) ...[
            CircleAvatar(
              radius: 14,
              backgroundColor: AppColors.primary.withValues(alpha: 0.2),
              child: Text(
                msg.senderName?.isNotEmpty ?? false ? msg.senderName![0].toUpperCase() : 'U',
                style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.primary),
              ),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: GestureDetector(
              onLongPress: isDeleted ? null : () => _openReactionPicker(msg),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: isDeleted
                      ? const Color(0xFF141418)
                      : (isMe ? AppColors.primary.withValues(alpha: 0.2) : const Color(0xFF181A22)),
                  borderRadius: BorderRadius.only(
                    topLeft: const Radius.circular(AppDimensions.radiusLg),
                    topRight: const Radius.circular(AppDimensions.radiusLg),
                    bottomLeft: Radius.circular(isMe ? AppDimensions.radiusLg : 2),
                    bottomRight: Radius.circular(isMe ? 2 : AppDimensions.radiusLg),
                  ),
                  border: Border.all(
                    color: isDeleted
                        ? const Color(0xFF27272A)
                        : (isMe ? AppColors.primary.withValues(alpha: 0.4) : const Color(0xFF27272A)),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                  children: [
                    if (!isMe && !isDeleted) ...[
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            msg.senderName ?? 'Student',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 11,
                              color: AppColors.primary,
                            ),
                          ),
                          const SizedBox(width: 6),
                          GestureDetector(
                            onTap: () => _openReportDialog(msg),
                            child: Icon(
                              Icons.flag_outlined,
                              size: 12,
                              color: Colors.white.withValues(alpha: 0.4),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                    ],
                    Text(
                      isDeleted
                          ? '[Message moderated: ${msg.deletionReason ?? 'Policy violation'}]'
                          : msg.content,
                      style: TextStyle(
                        fontSize: 13,
                        fontStyle: isDeleted ? FontStyle.italic : FontStyle.normal,
                        color: isDeleted
                            ? Colors.white.withValues(alpha: 0.4)
                            : Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (!isDeleted) ...[
                          GestureDetector(
                            onTap: () => setState(() => _replyingTo = msg),
                            child: Icon(Icons.reply_rounded, size: 12, color: Colors.white.withValues(alpha: 0.4)),
                          ),
                          const SizedBox(width: 6),
                          GestureDetector(
                            onTap: () => _openReactionPicker(msg),
                            child: Icon(Icons.add_reaction_outlined, size: 12, color: Colors.white.withValues(alpha: 0.4)),
                          ),
                          const SizedBox(width: 6),
                        ],
                        Text(
                          msg.createdAt != null
                              ? '${msg.createdAt!.hour.toString().padLeft(2, '0')}:${msg.createdAt!.minute.toString().padLeft(2, '0')}'
                              : '',
                          style: TextStyle(fontSize: 9, color: Colors.white.withValues(alpha: 0.4)),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
