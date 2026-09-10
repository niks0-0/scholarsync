import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../admin/presentation/admin_provider.dart';
import 'chat_room_screen.dart';

/// Student Academic Community & Realtime Chat Hub.
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
      backgroundColor: Colors.transparent,
      body: Padding(
        padding: const EdgeInsets.all(16),
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
                    const Text(
                      'Campus Chat Lounges',
                      style: TextStyle(fontWeight: FontWeight.w900, fontSize: 22, color: Colors.white),
                    ),
                    Text(
                      'Realtime discussions for subjects, batches, and clubs',
                      style: TextStyle(fontSize: 12, color: Colors.white.withValues(alpha: 0.6)),
                    ),
                  ],
                ),
                IconButton.filledTonal(
                  icon: const Icon(Icons.refresh_rounded),
                  onPressed: () => admin.loadChatRooms(),
                ),
              ],
            ),
            const SizedBox(height: 14),

            // Search Box
            TextField(
              controller: _searchController,
              style: const TextStyle(color: Colors.white, fontSize: 13),
              decoration: InputDecoration(
                hintText: 'Search academic channels...',
                hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.4)),
                prefixIcon: const Icon(Icons.search_rounded, color: Colors.white70, size: 20),
                filled: true,
                fillColor: const Color(0xFF141418),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
                  borderSide: const BorderSide(color: Color(0xFF27272A)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
                  borderSide: const BorderSide(color: Color(0xFF27272A)),
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
                    selectedColor: AppColors.primary.withValues(alpha: 0.25),
                    onSelected: (_) => setState(() => _selectedCategory = null),
                  ),
                  const SizedBox(width: 8),
                  ChoiceChip(
                    label: const Text('Subjects'),
                    selected: _selectedCategory == 'subject',
                    selectedColor: const Color(0xFF0284C7).withValues(alpha: 0.25),
                    onSelected: (_) => setState(() => _selectedCategory = 'subject'),
                  ),
                  const SizedBox(width: 8),
                  ChoiceChip(
                    label: const Text('Batch Lounges'),
                    selected: _selectedCategory == 'batch',
                    selectedColor: const Color(0xFF4F46E5).withValues(alpha: 0.25),
                    onSelected: (_) => setState(() => _selectedCategory = 'batch'),
                  ),
                  const SizedBox(width: 8),
                  ChoiceChip(
                    label: const Text('Clubs'),
                    selected: _selectedCategory == 'club',
                    selectedColor: const Color(0xFFD97706).withValues(alpha: 0.25),
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
                              Icon(Icons.forum_outlined, size: 52, color: Colors.white.withValues(alpha: 0.3)),
                              const SizedBox(height: 12),
                              const Text(
                                'No Channels Found',
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Try clearing your search or category filter.',
                                style: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: 12),
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
                                  color: const Color(0xFF0F1218),
                                  borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
                                  border: Border.all(
                                    color: isLocked ? AppColors.error.withValues(alpha: 0.4) : const Color(0xFF27272A),
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(10),
                                      decoration: BoxDecoration(
                                        color: (isSubject ? const Color(0xFF0284C7) : AppColors.secondary)
                                            .withValues(alpha: 0.15),
                                        borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
                                      ),
                                      child: Icon(
                                        isSubject ? Icons.tag_rounded : Icons.forum_rounded,
                                        size: 22,
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
                                                const SizedBox(width: 6),
                                                Container(
                                                  padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                                                  decoration: BoxDecoration(
                                                    color: AppColors.error.withValues(alpha: 0.2),
                                                    borderRadius: BorderRadius.circular(4),
                                                    border: Border.all(color: AppColors.error.withValues(alpha: 0.5)),
                                                  ),
                                                  child: const Text(
                                                    'READ ONLY',
                                                    style: TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: AppColors.error),
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
                                    const Icon(Icons.chevron_right_rounded, color: Colors.white38),
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
    );
  }
}
