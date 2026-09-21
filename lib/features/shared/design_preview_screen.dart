import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/app_logo.dart';

/// Interactive Design Preview Gallery allowing developers and stakeholders
/// to inspect and interact with the 6 core flagship screen designs in real-time.
class DesignPreviewScreen extends StatefulWidget {
  const DesignPreviewScreen({super.key});

  @override
  State<DesignPreviewScreen> createState() => _DesignPreviewScreenState();
}

class _DesignPreviewScreenState extends State<DesignPreviewScreen>
    with SingleTickerProviderStateMixin {
  int _selectedTabIndex = 2; // Default to User Home

  // Omnidirectional card state
  Offset _cardDragOffset = Offset.zero;
  int _currentPriorityIndex = 0;
  double _simulatedBunkSlider = 4.0;

  final List<Map<String, dynamic>> _priorityCards = [
    {
      'type': 'lecture',
      'title': 'Operating Systems (CS301)',
      'subtitle': 'Room 302 • CSE Building',
      'timer': 'Starts in 8 mins',
      'faculty': 'Prof. Alice Chen',
      'attendance': '86%',
      'statusColor': AppColors.primary,
      'badge': 'Next Up',
    },
    {
      'type': 'alert',
      'title': 'Mathematics-IV Deficit Alert',
      'subtitle': 'Current Attendance: 71.4% (Threshold 75%)',
      'timer': 'Attend next 2 classes',
      'faculty': 'Prof. Alan Turing',
      'attendance': '71.4%',
      'statusColor': AppColors.warning,
      'badge': 'Urgent Deficit',
    },
    {
      'type': 'assignment',
      'title': 'DBMS Lab Report Submission',
      'subtitle': 'Relational Schema & SQL Queries',
      'timer': 'Due Tonight 11:59 PM',
      'faculty': 'Prof. Sarah Jenkins',
      'attendance': 'Assignment',
      'statusColor': AppColors.info,
      'badge': 'Deadline',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : const Color(0xFFF8F9FA),
      body: SafeArea(
        child: Column(
          children: [
            // Top Screen Switcher Header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkSurface : Colors.white,
                border: Border(
                  bottom: BorderSide(
                    color: isDark ? AppColors.darkBorder : AppColors.border,
                  ),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.palette_outlined, size: 20, color: AppColors.primary),
                      const SizedBox(width: 8),
                      Text(
                        'ScholarSync Screen Showcase',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        icon: const Icon(Icons.close_rounded),
                        onPressed: () => Navigator.of(context).maybePop(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _buildTabChip(0, '1. Splash', Icons.flash_on_rounded),
                        _buildTabChip(1, '2. Info / Onboarding', Icons.info_outline_rounded),
                        _buildTabChip(2, '3. User Home (Omni-Deck)', Icons.dashboard_rounded),
                        _buildTabChip(3, '4. Admin Command', Icons.admin_panel_settings_rounded),
                        _buildTabChip(4, '5. Card Expand (Exams)', Icons.open_in_full_rounded),
                        _buildTabChip(5, '6. Operative Bunk Hub', Icons.calculate_rounded),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Active Screen Viewport
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: _buildSelectedScreen(isDark),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabChip(int index, String label, IconData icon) {
    final isSelected = _selectedTabIndex == index;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        avatar: Icon(icon, size: 16, color: isSelected ? Colors.white : AppColors.textSecondary),
        label: Text(label),
        selected: isSelected,
        selectedColor: AppColors.primary,
        labelStyle: TextStyle(
          fontSize: 12,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          color: isSelected ? Colors.white : (Theme.of(context).brightness == Brightness.dark ? Colors.white70 : Colors.black87),
        ),
        onSelected: (selected) {
          if (selected) setState(() => _selectedTabIndex = index);
        },
      ),
    );
  }

  Widget _buildSelectedScreen(bool isDark) {
    switch (_selectedTabIndex) {
      case 0:
        return _buildSplashScreenView(isDark);
      case 1:
        return _buildInfoScreenView(isDark);
      case 2:
        return _buildUserHomeScreenView(isDark);
      case 3:
        return _buildAdminHomeScreenView(isDark);
      case 4:
        return _buildCardExpandView(isDark);
      case 5:
        return _buildOperativeAnalyticsView(isDark);
      default:
        return const SizedBox.shrink();
    }
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // 1. SPLASH SCREEN PREVIEW
  // ─────────────────────────────────────────────────────────────────────────────
  Widget _buildSplashScreenView(bool isDark) {
    return Container(
      key: const ValueKey('splash_screen'),
      color: isDark ? AppColors.darkBackground : Colors.black,
      width: double.infinity,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const AppLogo(height: 75),
          const SizedBox(height: 32),
          const SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(
              strokeWidth: 2.5,
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'FOR STUDENTS, BY STUDENTS',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              letterSpacing: 2.0,
              color: Colors.white.withValues(alpha: 0.6),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Academic OS v2.0 • Realtime Firebase Sync',
            style: TextStyle(
              fontSize: 11,
              color: Colors.white.withValues(alpha: 0.4),
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // 2. INFO & ONBOARDING SCREEN PREVIEW
  // ─────────────────────────────────────────────────────────────────────────────
  Widget _buildInfoScreenView(bool isDark) {
    return Container(
      key: const ValueKey('info_screen'),
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const SizedBox(height: 12),
          const AppLogo(height: 48),
          const SizedBox(height: 8),
          Text(
            'Empowering Campus Life',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
          const SizedBox(height: 20),

          // Glass Feature Cards Carousel
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkSurfaceVariant : Colors.white,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: isDark ? AppColors.darkBorder : AppColors.border,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.primary.withValues(alpha: 0.15),
                    ),
                    child: const Icon(Icons.bolt_rounded, size: 36, color: AppColors.primary),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Real-Time Attendance & Bunk Guard',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Automatically calculates 75% thresholds, safe bunks to take, and classes needed to recover before fines.',
                    style: TextStyle(
                      fontSize: 13,
                      color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                      height: 1.4,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 8,
                    children: [
                      Chip(label: const Text('#SafeBunks'), backgroundColor: AppColors.primary.withValues(alpha: 0.1)),
                      Chip(label: const Text('#NoDeficit'), backgroundColor: AppColors.secondary.withValues(alpha: 0.1)),
                    ],
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 20),
          // Google Auth Button
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.textPrimary,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              icon: const Icon(Icons.account_circle_outlined),
              label: const Text('Continue with College Google ID', style: TextStyle(fontWeight: FontWeight.bold)),
              onPressed: () {},
            ),
          ),
          const SizedBox(height: 8),
          TextButton(
            onPressed: () {},
            child: const Text('Explore as Demo Guest Student'),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // 3. USER HOME SCREEN (OMNIDIRECTIONAL DECK & DYNAMIC CAPSULE)
  // ─────────────────────────────────────────────────────────────────────────────
  Widget _buildUserHomeScreenView(bool isDark) {
    final currentCard = _priorityCards[_currentPriorityIndex % _priorityCards.length];

    return Container(
      key: const ValueKey('user_home_screen'),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          const SizedBox(height: 8),

          // 1. Dynamic Activity Capsule (Top Pill)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E2430) : const Color(0xFFE9ECEF),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.access_time_rounded, size: 14, color: AppColors.primary),
                const SizedBox(width: 6),
                Text(
                  'CS301 Operating Systems Starts in 8m',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
                const SizedBox(width: 6),
                Container(
                  width: 6,
                  height: 6,
                  decoration: const BoxDecoration(shape: BoxShape.circle, color: AppColors.primary),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // 2. Fixed Command Header
          Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Good Morning, Alex!',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                  Text(
                    'CSE • Semester 5 • Roll #22',
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
              const Spacer(),
              IconButton(
                icon: const Badge(label: Text('2'), child: Icon(Icons.notifications_outlined)),
                onPressed: () {},
              ),
              const CircleAvatar(
                radius: 18,
                backgroundColor: AppColors.primary,
                child: Text('A', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // 3. Omnidirectional Hero Priority Deck (Swipeable)
          Expanded(
            child: Center(
              child: Stack(
                alignment: Alignment.center,
                clipBehavior: Clip.none,
                children: [
                  // Directional Action Indicators
                  Positioned(
                    top: 10,
                    child: Opacity(
                      opacity: _cardDragOffset.dy < -20 ? 1.0 : 0.4,
                      child: const Column(
                        children: [
                          Icon(Icons.arrow_upward_rounded, size: 16),
                          Text('Details (Up)', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600)),
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    right: 8,
                    child: Opacity(
                      opacity: _cardDragOffset.dx > 20 ? 1.0 : 0.4,
                      child: const Column(
                        children: [
                          Icon(Icons.arrow_forward_rounded, size: 16, color: AppColors.primary),
                          Text('Check In', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: AppColors.primary)),
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    left: 8,
                    child: Opacity(
                      opacity: _cardDragOffset.dx < -20 ? 1.0 : 0.4,
                      child: const Column(
                        children: [
                          Icon(Icons.arrow_back_rounded, size: 16, color: AppColors.error),
                          Text('Dismiss', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: AppColors.error)),
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 10,
                    child: Opacity(
                      opacity: _cardDragOffset.dy > 20 ? 1.0 : 0.4,
                      child: const Column(
                        children: [
                          Text('Snooze (Down)', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600)),
                          Icon(Icons.arrow_downward_rounded, size: 16),
                        ],
                      ),
                    ),
                  ),

                  // Background Peeking Card 2
                  Transform.translate(
                    offset: const Offset(0, -22),
                    child: Transform.scale(
                      scale: 0.88,
                      child: _buildCardMockup(isDark, _priorityCards[(_currentPriorityIndex + 2) % _priorityCards.length], isPeeking: true),
                    ),
                  ),

                  // Background Peeking Card 1
                  Transform.translate(
                    offset: const Offset(0, -12),
                    child: Transform.scale(
                      scale: 0.94,
                      child: _buildCardMockup(isDark, _priorityCards[(_currentPriorityIndex + 1) % _priorityCards.length], isPeeking: true),
                    ),
                  ),

                  // Interactive Front Hero Card with Drag Physics
                  GestureDetector(
                    onPanUpdate: (details) {
                      setState(() {
                        _cardDragOffset += details.delta;
                      });
                    },
                    onPanEnd: (details) {
                      if (_cardDragOffset.dx > 80) {
                        // Swipe Right: Check in
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('✅ Check-In Confirmed! Marked Present.'), duration: Duration(seconds: 1)),
                        );
                        setState(() {
                          _currentPriorityIndex++;
                          _cardDragOffset = Offset.zero;
                        });
                      } else if (_cardDragOffset.dx < -80) {
                        // Swipe Left: Dismiss
                        setState(() {
                          _currentPriorityIndex++;
                          _cardDragOffset = Offset.zero;
                        });
                      } else {
                        // Spring back
                        setState(() {
                          _cardDragOffset = Offset.zero;
                        });
                      }
                    },
                    child: Transform.translate(
                      offset: _cardDragOffset,
                      child: Transform.rotate(
                        angle: (_cardDragOffset.dx / 400).clamp(-0.15, 0.15),
                        child: _buildCardMockup(isDark, currentCard, isPeeking: false),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 8),

          // 4. Bento Analytics Strip
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.darkSurface : Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.border),
                  ),
                  child: Row(
                    children: [
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          SizedBox(
                            width: 36,
                            height: 36,
                            child: CircularProgressIndicator(
                              value: 0.86,
                              strokeWidth: 4,
                              backgroundColor: AppColors.border,
                              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
                            ),
                          ),
                          Text('86%', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                        ],
                      ),
                      SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Attendance', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                            Text('+4 Safe Bunks', style: TextStyle(fontSize: 10, color: AppColors.primary, fontWeight: FontWeight.w600)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.darkSurface : Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.border),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.assignment_outlined, size: 28, color: AppColors.secondary),
                      SizedBox(width: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Assignments', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                          Text('1 Due Tonight', style: TextStyle(fontSize: 10, color: AppColors.warning, fontWeight: FontWeight.w600)),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // 5. Floating Glass Bottom Dock
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkSurfaceVariant.withValues(alpha: 0.85) : Colors.white.withValues(alpha: 0.9),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.border),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildDockItem(Icons.home_rounded, 'Home', true),
                _buildDockItem(Icons.calendar_month_rounded, 'Timetable', false),
                _buildDockItem(Icons.check_circle_outline_rounded, 'Attendance', false),
                _buildDockItem(Icons.folder_open_rounded, 'Notes', false),
              ],
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _buildDockItem(IconData icon, String label, bool active) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 20, color: active ? AppColors.primary : AppColors.textSecondary),
        Text(
          label,
          style: TextStyle(
            fontSize: 9,
            fontWeight: active ? FontWeight.bold : FontWeight.normal,
            color: active ? AppColors.primary : AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildCardMockup(bool isDark, Map<String, dynamic> data, {required bool isPeeking}) {
    return Container(
      width: 280,
      height: 230,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.border,
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isPeeking ? 0.05 : 0.15),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: (data['statusColor'] as Color).withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  data['badge'] as String,
                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: data['statusColor'] as Color),
                ),
              ),
              const Spacer(),
              Text(data['timer'] as String, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            data['title'] as String,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            data['subtitle'] as String,
            style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
          ),
          const Spacer(),
          Row(
            children: [
              Text(
                data['faculty'] as String,
                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500),
              ),
              const Spacer(),
              Text(
                'Att: ${data['attendance']}',
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: data['statusColor'] as Color),
              ),
            ],
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            height: 38,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              icon: const Icon(Icons.location_on_outlined, size: 16),
              label: const Text('Mark Attended', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
              onPressed: () {
                setState(() {
                  _currentPriorityIndex++;
                });
              },
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // 4. ADMIN HOME SCREEN PREVIEW
  // ─────────────────────────────────────────────────────────────────────────────
  Widget _buildAdminHomeScreenView(bool isDark) {
    return SingleChildScrollView(
      key: const ValueKey('admin_screen'),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(8)),
                child: const Icon(Icons.shield_rounded, size: 20, color: Colors.white),
              ),
              const SizedBox(width: 10),
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Admin Command Center', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  Text('Dean & Faculty Administration', style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),

          // KPI Grid
          GridView.count(
            crossAxisCount: 3,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            children: [
              _buildKpiBox('1,420', 'Students', Icons.people_outline, AppColors.primary, isDark),
              _buildKpiBox('86.2%', 'Avg Att.', Icons.analytics_outlined, AppColors.secondary, isDark),
              _buildKpiBox('12', 'Pending Notes', Icons.folder_open_outlined, AppColors.warning, isDark),
            ],
          ),

          const SizedBox(height: 16),

          // Operational Action Tile 1: Moderation Queue
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkSurface : Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.gavel_outlined, size: 18, color: AppColors.warning),
                    SizedBox(width: 8),
                    Text('Study Notes Review Queue (12 pending)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                  ],
                ),
                const Divider(height: 20),
                _buildQueueItem('CS301 Unit 2 Operating Systems.pdf', 'Uploaded by Alex (Roll #22)'),
                _buildQueueItem('AI Lab Solutions 2026.pdf', 'Uploaded by Priya (Roll #45)'),
              ],
            ),
          ),

          const SizedBox(height: 14),

          // Operational Action Tile 2: Campus Broadcast Terminal
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkSurface : Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.campaign_outlined, size: 18, color: AppColors.primary),
                    SizedBox(width: 8),
                    Text('Instant Campus Push Broadcast', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                  ],
                ),
                const SizedBox(height: 10),
                const TextField(
                  decoration: InputDecoration(
                    hintText: 'Enter urgent notification announcement...',
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  ),
                ),
                const SizedBox(height: 10),
                Align(
                  alignment: Alignment.centerRight,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
                    icon: const Icon(Icons.send_rounded, size: 14),
                    label: const Text('Send Native Push Alert', style: TextStyle(fontSize: 11)),
                    onPressed: () {},
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildKpiBox(String value, String label, IconData icon, Color color, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.border),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 20, color: color),
          const SizedBox(height: 4),
          Text(value, style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: color)),
          Text(label, style: const TextStyle(fontSize: 10, color: AppColors.textSecondary), textAlign: TextAlign.center),
        ],
      ),
    );
  }

  Widget _buildQueueItem(String title, String subtitle) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          const Icon(Icons.picture_as_pdf_outlined, size: 18, color: AppColors.error),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600), maxLines: 1, overflow: TextOverflow.ellipsis),
                Text(subtitle, style: const TextStyle(fontSize: 10, color: AppColors.textSecondary)),
              ],
            ),
          ),
          IconButton(icon: const Icon(Icons.check_circle_outline, size: 18, color: AppColors.primary), onPressed: () {}),
          IconButton(icon: const Icon(Icons.cancel_outlined, size: 18, color: AppColors.error), onPressed: () {}),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // 5. CARD EXPAND VIEW (EXAMS & DETAILED DEEP-DIVE)
  // ─────────────────────────────────────────────────────────────────────────────
  Widget _buildCardExpandView(bool isDark) {
    return Container(
      key: const ValueKey('card_expand_screen'),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.error.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text('MID-SEMESTER EXAMINATION', style: TextStyle(color: AppColors.error, fontSize: 11, fontWeight: FontWeight.bold)),
              ),
              const Spacer(),
              const Text('Oct 24, 2026', style: TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 12),
          const Text('Operating Systems (CS301)', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
          const Text('Theory Written Examination • 3 Hours (100 Marks)', style: TextStyle(color: AppColors.textSecondary)),
          const Divider(height: 24),

          // Venue & Faculty Details
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkSurface : Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.border),
            ),
            child: const Column(
              children: [
                Row(
                  children: [
                    Icon(Icons.location_on_outlined, size: 18, color: AppColors.primary),
                    SizedBox(width: 8),
                    Text('Hall 302, Main Engineering Block', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                  ],
                ),
                SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.person_outline, size: 18, color: AppColors.secondary),
                    SizedBox(width: 8),
                    Text('Lead Invigilator: Prof. Alan Turing', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),
          const Text('Syllabus Units Covered:', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
          const SizedBox(height: 6),
          _buildSyllabusItem('Unit 1: Process Scheduling & Threads', true),
          _buildSyllabusItem('Unit 2: Memory Virtualization & Paging', true),
          _buildSyllabusItem('Unit 3: Concurrency, Locks & Deadlocks', false),

          const Spacer(),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
              icon: const Icon(Icons.download_rounded),
              label: const Text('Download Exam Revision Notes (PDF)'),
              onPressed: () {},
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSyllabusItem(String title, bool done) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          Icon(done ? Icons.check_box_rounded : Icons.check_box_outline_blank_rounded, size: 18, color: done ? AppColors.primary : AppColors.textSecondary),
          const SizedBox(width: 8),
          Text(title, style: TextStyle(fontSize: 12, decoration: done ? TextDecoration.lineThrough : null)),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // 6. OPERATIVE ANALYTICS (BUNK SIMULATOR HUB)
  // ─────────────────────────────────────────────────────────────────────────────
  Widget _buildOperativeAnalyticsView(bool isDark) {
    return SingleChildScrollView(
      key: const ValueKey('bunk_operative_screen'),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Attendance & Bunk Simulator', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const Text('Real-time 75% Safe Bunk Threshold Calculations', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
          const SizedBox(height: 16),

          // Speedometer Metric Card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkSurface : Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.border),
            ),
            child: Column(
              children: [
                const Text('Overall Semester Attendance', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                const SizedBox(height: 12),
                Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: 100,
                      height: 100,
                      child: CircularProgressIndicator(
                        value: 0.824,
                        strokeWidth: 8,
                        backgroundColor: AppColors.border,
                        valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
                      ),
                    ),
                    Column(
                      children: [
                        const Text('82.4%', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900)),
                        Text('SAFE', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.primary)),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                const Text('You can safely skip 5 more lectures without deficit.', style: TextStyle(fontSize: 12, color: AppColors.primary, fontWeight: FontWeight.w600)),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Interactive Bunk Simulation Slider
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkSurface : Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.tune_rounded, size: 18, color: AppColors.primary),
                    const SizedBox(width: 8),
                    const Text('Simulate What If I Miss Classes:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                    const Spacer(),
                    Text('${_simulatedBunkSlider.toInt()} Classes', style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary)),
                  ],
                ),
                Slider(
                  value: _simulatedBunkSlider,
                  min: 0,
                  max: 10,
                  divisions: 10,
                  label: '${_simulatedBunkSlider.toInt()} classes',
                  activeColor: _simulatedBunkSlider > 5 ? AppColors.error : AppColors.primary,
                  onChanged: (val) {
                    setState(() => _simulatedBunkSlider = val);
                  },
                ),
                Text(
                  _simulatedBunkSlider > 5
                      ? '⚠️ Warning: Missing ${_simulatedBunkSlider.toInt()} classes drops your attendance below 75%!'
                      : '✅ Safe: Missing ${_simulatedBunkSlider.toInt()} classes keeps you above 75% threshold.',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: _simulatedBunkSlider > 5 ? AppColors.error : AppColors.primary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
