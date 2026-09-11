import 'package:flutter/material.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/theme/app_colors.dart';

/// One-tap Persona Selector Modal for effortless testing as Admin or Students.
class QuickPersonaSheet extends StatelessWidget {
  const QuickPersonaSheet({
    super.key,
    required this.onSelectCredentials,
  });

  final void Function(String email, String password, String label) onSelectCredentials;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).padding.bottom + 20,
      ),
      decoration: const BoxDecoration(
        color: Color(0xFF0C0C0E),
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppDimensions.radiusXl)),
        border: Border(top: BorderSide(color: Color(0xFF27272A))),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.flash_on_rounded, color: AppColors.primary, size: 18),
                  ),
                  const SizedBox(width: 10),
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Demo Persona Switcher',
                        style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: Colors.white),
                      ),
                      Text(
                        '1-tap fast login for evaluation and review',
                        style: TextStyle(fontSize: 11, color: Colors.white60),
                      ),
                    ],
                  ),
                ],
              ),
              IconButton(
                icon: const Icon(Icons.close_rounded, color: Colors.white60),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const Divider(color: Color(0xFF27272A), height: 24),

          // Persona 1: App Owner Master Admin
          _buildPersonaTile(
            context,
            icon: Icons.shield_rounded,
            iconColor: AppColors.primary,
            title: 'Master App Owner (Full Access)',
            email: 'admin@scholarsync.com',
            password: 'Admin@123456',
            roleBadge: 'SUPER ADMIN',
            badgeColor: AppColors.primary,
            subtitle: 'Access to Master Console, Curriculum, Safe-Lock, and Audit Trails',
          ),
          const SizedBox(height: 10),

          // Persona 2: CSE Student (Nilay)
          _buildPersonaTile(
            context,
            icon: Icons.school_rounded,
            iconColor: const Color(0xFF38BDF8),
            title: 'Computer Science Student (Nilay)',
            email: 'nilay@scholarsync.com',
            password: 'Password@123',
            roleBadge: 'CSE SEM 4',
            badgeColor: const Color(0xFF0284C7),
            subtitle: 'Enrolled in DAA, DBMS, OS & Campus Chat Lounges',
          ),
          const SizedBox(height: 10),

          // Persona 3: IT Student (Alex)
          _buildPersonaTile(
            context,
            icon: Icons.code_rounded,
            iconColor: AppColors.secondary,
            title: 'Information Technology Student (Alex)',
            email: 'alex@scholarsync.com',
            password: 'Password@123',
            roleBadge: 'IT SEM 2',
            badgeColor: AppColors.secondary,
            subtitle: 'Enrolled in Data Structures, Web Dev & Technical Club',
          ),
        ],
      ),
    );
  }

  Widget _buildPersonaTile(
    BuildContext context, {
    required IconData icon,
    required Color iconColor,
    required String title,
    required String email,
    required String password,
    required String roleBadge,
    required Color badgeColor,
    required String subtitle,
  }) {
    return InkWell(
      onTap: () {
        Navigator.pop(context);
        onSelectCredentials(email, password, title);
      },
      borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: const Color(0xFF141418),
          borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
          border: Border.all(color: const Color(0xFF27272A)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: iconColor.withValues(alpha: 0.3)),
              ),
              child: Icon(icon, color: iconColor, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          title,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.white),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: badgeColor.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          roleBadge,
                          style: TextStyle(fontSize: 9, fontWeight: FontWeight.w900, color: badgeColor),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    email,
                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.primary),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(fontSize: 10, color: Colors.white.withValues(alpha: 0.5)),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: Colors.white38),
          ],
        ),
      ),
    );
  }
}
