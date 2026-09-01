import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/theme/app_colors.dart';

class SmartFab extends StatefulWidget {
  const SmartFab({
    super.key,
    required this.scrollController,
  });

  final ScrollController scrollController;

  @override
  State<SmartFab> createState() => _SmartFabState();
}

class _SmartFabState extends State<SmartFab> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _expandAnimation;
  bool _isExpanded = false;
  bool _isVisible = true;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _expandAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutBack,
    );

    widget.scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (!widget.scrollController.hasClients) return;
    if (widget.scrollController.position.userScrollDirection == ScrollDirection.reverse) {
      if (_isVisible) {
        setState(() {
          _isVisible = false;
          _isExpanded = false;
          _animationController.reverse();
        });
      }
    } else if (widget.scrollController.position.userScrollDirection == ScrollDirection.forward) {
      if (!_isVisible) {
        setState(() => _isVisible = true);
      }
    }
  }

  @override
  void dispose() {
    widget.scrollController.removeListener(_onScroll);
    _animationController.dispose();
    super.dispose();
  }

  void _toggleExpand() {
    setState(() {
      _isExpanded = !_isExpanded;
      if (_isExpanded) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_isVisible) return const SizedBox.shrink();

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        if (_isExpanded) ...[
          ScaleTransition(
            scale: _expandAnimation,
            alignment: Alignment.bottomRight,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                _buildOptionRow(
                  context,
                  label: 'New Assignment',
                  icon: Icons.assignment_add,
                  route: '/activities',
                ),
                const SizedBox(height: AppDimensions.spacingSm),
                _buildOptionRow(
                  context,
                  label: 'New Reminder',
                  icon: Icons.add_alarm_rounded,
                  route: '/calendar',
                ),
                const SizedBox(height: AppDimensions.spacingSm),
                _buildOptionRow(
                  context,
                  label: 'New Note',
                  icon: Icons.note_add_outlined,
                  route: '/activities',
                ),
                const SizedBox(height: AppDimensions.spacingSm),
                _buildOptionRow(
                  context,
                  label: 'New Event',
                  icon: Icons.event_available_rounded,
                  route: '/calendar',
                ),
                const SizedBox(height: AppDimensions.spacingMd),
              ],
            ),
          ),
        ],

        FloatingActionButton(
          onPressed: _toggleExpand,
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 6,
          tooltip: _isExpanded ? 'Close Menu' : 'Quick Actions',
          child: AnimatedRotation(
            turns: _isExpanded ? 0.125 : 0,
            duration: const Duration(milliseconds: 200),
            child: const Icon(Icons.add_rounded, size: 28),
          ),
        ),
      ],
    );
  }

  Widget _buildOptionRow(
    BuildContext context, {
    required String label,
    required IconData icon,
    required String route,
  }) {
    final colorScheme = Theme.of(context).colorScheme;

    return Semantics(
      label: label,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Material(
            elevation: 3,
            borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
            color: colorScheme.surfaceContainerHighest,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              child: Text(
                label,
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurface,
                    ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          FloatingActionButton.small(
            onPressed: () {
              _toggleExpand();
              context.push(route);
            },
            backgroundColor: colorScheme.surfaceContainerHighest,
            foregroundColor: AppColors.primary,
            elevation: 3,
            child: Icon(icon, size: 20),
          ),
        ],
      ),
    );
  }
}
