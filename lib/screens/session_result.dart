import 'package:flutter/material.dart';

class SessionResult extends StatelessWidget {
  final Map<String, dynamic> session;

  const SessionResult({super.key, required this.session});

  Map<String, double> _calculateContributions() {
    final diners = session['diners'] as List<dynamic>;
    final dishes = session['dishes'] as List<dynamic>;
    final tax = (session['tax'] as num).toDouble();
    final tip = (session['tip'] as num).toDouble();

    final contributions = <String, double>{};
    double totalDishCost = 0.0;

    // Initialize contributions for each diner
    for (var diner in diners) {
      contributions[diner['name'] as String] = 0.0;
    }

    // Calculate dish costs per diner
    for (var i = 0; i < dishes.length; i++) {
      final dish = dishes[i];
      final dishCost = (dish['quantity'] as int) * (dish['price'] as double);
      final assignedDiners = (session['assignments'] as List<List<bool>>)[i]
          .asMap()
          .entries
          .where((entry) => entry.value)
          .map((entry) => diners[entry.key]['name'] as String)
          .toList();
      final splitCost = dishCost / assignedDiners.length;

      for (var dinerName in assignedDiners) {
        contributions[dinerName] = contributions[dinerName]! + splitCost;
      }
      totalDishCost += dishCost;
    }

    // Distribute tax and tip proportionally
    final totalWithTax = totalDishCost * (1 + tax / 100);
    final totalWithTip = totalWithTax + tip;

    for (var diner in diners) {
      final dinerName = diner['name'] as String;
      final proportion = contributions[dinerName]! / totalDishCost;
      contributions[dinerName] = contributions[dinerName]! +
          (proportion * (totalWithTax - totalDishCost)) + // Tax share
          (proportion * tip); // Tip share
    }

    return contributions;
  }

  @override
  Widget build(BuildContext context) {
    final contributions = _calculateContributions();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Bill Summary - ${session['date']}',
          style: const TextStyle(color: Colors.white),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Total: \$${session['total'].toStringAsFixed(2)} (Tax: ${session['tax']}%, Tip: \$${session['tip'].toStringAsFixed(2)})',
              style: const TextStyle(fontSize: 18, color: Colors.white),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView(
                children: contributions.entries.map((entry) {
                  return Card(
                    color: Colors.grey[800],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ListTile(
                      title: Text(
                        entry.key,
                        style: const TextStyle(color: Colors.white, fontSize: 18),
                      ),
                      trailing: Text(
                        '\$${entry.value.toStringAsFixed(2)}',
                        style: const TextStyle(color: Colors.white, fontSize: 18),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}