import 'package:flutter/material.dart';

class SessionCard extends StatelessWidget {
  final Map<String, dynamic> session;
  final Function onDelete;
  final Function onTap;
  final List<Color> sessionColors;

  const SessionCard({
    super.key,
    required this.session,
    required this.onDelete,
    required this.onTap,
    required this.sessionColors,
  });

  @override
  Widget build(BuildContext context) {
    final colorIndex = session['color'] as int? ?? 0;
    final total = (session['total'] as num?)?.toDouble() ?? 0.0;
    final dinerCount = (session['diner_count'] as int?) ?? 0;

    return GestureDetector(
      onTap: () => onTap(),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: sessionColors[colorIndex],
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              session['date'],
              style: const TextStyle(color: Colors.black54, fontSize: 12),
            ),
            const SizedBox(height: 8),
            Text(
              'Total: \$${total.toStringAsFixed(2)}',
              style: const TextStyle(color: Colors.black87, fontSize: 18),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 8),
            Expanded(
              child: Text(
                '$dinerCount diners',
                style: const TextStyle(color: Colors.black54, height: 1.5),
                maxLines: 2,
                overflow: TextOverflow.fade,
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  icon: const Icon(
                    Icons.delete_outline,
                    color: Colors.black54,
                    size: 20,
                  ),
                  onPressed: () => onDelete(),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}