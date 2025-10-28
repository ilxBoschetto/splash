import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class TopUsersCard extends StatelessWidget {
  final List<Map<String, dynamic>> users;

  const TopUsersCard({super.key, required this.users});

  IconData _getIcon(int position) {
    switch (position) {
      case 0:
        return Icons.emoji_events;
      case 1:
        return Icons.military_tech;
      case 2:
        return Icons.star;
      default:
        return Icons.person;
    }
  }

  Color _getColor(BuildContext context, int position) {
    switch (position) {
      case 0:
        return Colors.amber;
      case 1:
        return Colors.grey;
      case 2:
        return Colors.brown;
      default:
        return Theme.of(context).colorScheme.primary;
    }
  }

  Widget _buildSkeletonRow(BuildContext context) {
    final darkBackground = Theme.of(context).colorScheme.surfaceVariant;
    final highlight = Colors.grey.shade700;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          // Icon skeleton
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              gradient: LinearGradient(
                colors: [darkBackground, highlight, darkBackground],
                stops: [0.1, 0.5, 0.9],
                begin: Alignment(-1, -1),
                end: Alignment(1, 1),
              ),
            ),
          ),
          const SizedBox(width: 12),

          // Name skeleton
          Expanded(
            child: Container(
              height: 16,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                gradient: LinearGradient(
                  colors: [darkBackground, highlight, darkBackground],
                  stops: [0.1, 0.5, 0.9],
                  begin: Alignment(-1, -1),
                  end: Alignment(1, 1),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),

          // Score skeleton
          Container(
            width: 40,
            height: 16,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              gradient: LinearGradient(
                colors: [darkBackground, highlight, darkBackground],
                stops: [0.1, 0.5, 0.9],
                begin: Alignment(-1, -1),
                end: Alignment(1, 1),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = users.isEmpty;

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 3,
      color: Theme.of(context).colorScheme.surface,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "top_users".tr(),
              style: TextStyle(
                fontSize: 13,
                color: Theme.of(context).hintColor,
                fontWeight: FontWeight.w400,
              ),
            ),
            const SizedBox(height: 12),

            ...List.generate(3, (index) {
              if (isLoading) {
                return _buildSkeletonRow(context);
              } else if (index < users.length) {
                final user = users[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: _getColor(
                          context,
                          index,
                        ).withOpacity(0.15),
                        child: Icon(
                          _getIcon(index),
                          color: _getColor(context, index),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          user["username"] ?? 'unknown'.tr(),
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                      ),
                      Text(
                        "${user["score"]} ${'general.drinking_fountains'.tr()}",
                        style: TextStyle(
                          fontSize: 14,
                          color: Theme.of(context).hintColor,
                        ),
                      ),
                    ],
                  ),
                );
              } else {
                return SizedBox.shrink();
              }
            }),
          ],
        ),
      ),
    );
  }
}
