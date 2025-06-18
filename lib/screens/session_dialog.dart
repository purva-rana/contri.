import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class SessionDialog extends StatefulWidget {
  final Map<String, dynamic>? session;
  final Function(Map<String, dynamic>) onSessionSaved;
  final List<Color> sessionColors;

  const SessionDialog({
    super.key,
    this.session,
    required this.onSessionSaved,
    required this.sessionColors,
  });

  @override
  State<SessionDialog> createState() => _SessionDialogState();
}

class _SessionDialogState extends State<SessionDialog> {
  final _formKey = GlobalKey<FormState>();
  int _dinerCount = 2;
  List<TextEditingController> _dinerControllers = [];
  List<Map<String, dynamic>> _dishes = [];
  List<List<bool>> _assignments = [];
  double _tax = 5.0;
  double _tip = 0.0;
  int _selectedColorIndex = 0;
  final _taxController = TextEditingController(text: '5.0');

  @override
  void initState() {
    super.initState();
    if (widget.session != null) {
      _dinerCount = widget.session!['diner_count'] ?? 2;
      _dinerControllers = (widget.session!['diners'] as List<dynamic>)
          .map((d) => TextEditingController(text: d['name'] as String))
          .toList();
      _dishes = List<Map<String, dynamic>>.from(widget.session!['dishes'] as List);
      _assignments = (widget.session!['assignments'] as List<List<bool>>)
          .map((list) => List<bool>.from(list))
          .toList();
      _tax = (widget.session!['tax'] as num).toDouble();
      _tip = (widget.session!['tip'] as num).toDouble();
      _selectedColorIndex = widget.session!['color'] as int? ?? 0;
      _taxController.text = _tax.toString();
    } else {
      _dinerControllers = List.generate(
        _dinerCount,
            (_) => TextEditingController(),
      );
      _dishes = [];
      _assignments = [];
    }
  }

  @override
  void dispose() {
    for (var controller in _dinerControllers) {
      controller.dispose();
    }
    _taxController.dispose();
    super.dispose();
  }

  void _addDish() {
    setState(() {
      _dishes.add({
        'name': '',
        'quantity': 1,
        'price': 0.0,
      });
      _assignments.add(List.filled(_dinerCount, false));
    });
  }

  void _updateDinerCount(int count) {
    setState(() {
      if (count > _dinerCount) {
        _dinerControllers.addAll(
          List.generate(count - _dinerCount, (_) => TextEditingController()),
        );
        for (var assignment in _assignments) {
          assignment.addAll(List.filled(count - _dinerCount, false));
        }
      } else if (count < _dinerCount) {
        _dinerControllers.removeRange(count, _dinerCount);
        for (var assignment in _assignments) {
          assignment.removeRange(count, _dinerCount);
        }
      }
      _dinerCount = count;
    });
  }

  @override
  Widget build(BuildContext context) {
    final currentDate = DateFormat('E d MMM').format(DateTime.now());

    return AlertDialog(
      backgroundColor: widget.sessionColors[_selectedColorIndex],
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Text(
        widget.session == null ? 'New Bill' : 'Edit Bill',
        style: const TextStyle(color: Colors.black87),
      ),
      content: SingleChildScrollView(
          child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                Text(
                currentDate,
                style: const TextStyle(fontSize: 14, color: Colors.black54),
              ),
              const SizedBox(height: 16),
              TextFormField(
                initialValue: _dinerCount.toString(),
                decoration: InputDecoration(
                  labelText: 'Number of Diners',
                  filled: true,
                  fillColor: Colors.white.withOpacity(0.5),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || int.tryParse(value) == null || int.parse(value) < 1) {
                    return 'Enter at least 1 diner';
                  }
                  return null;
                },
                onChanged: (value) {
                  final count = int.tryParse(value) ?? _dinerCount;
                  _updateDinerCount(count);
                },
              ),
              const SizedBox(height: 16),
              ...List.generate(
              _dinerCount,
              (index) => Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: TextFormField(
        controller: _dinerControllers[index],
        decoration: InputDecoration(
          labelText: 'Diner ${index + 1} Name',
          filled: true,
          fillColor: Colors.white.withOpacity(0.5),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
        ),
        validator: (value) {
          if (value == null || value.trim().isEmpty) {
            return 'Enter a name';
          }
          return null;
        },
      ),
    ),
    ),
    const SizedBox(height: 16),
    Text(
    'Dishes',
    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87),
    ),
    const SizedBox(height: 8),
    ...List.generate(
    _dishes.length,
    (dishIndex) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
    TextFormField(
    initialValue: _dishes[dishIndex]['name'] as String,
    decoration: InputDecoration(
    labelText: 'Dish Name',
    filled: true,
    fillColor: Colors.white.withOpacity(0.5),
    border: OutlineInputBorder(
    borderRadius: BorderRadius.circular(12),
    borderSide: BorderSide.none,
    ),
    ),
    onChanged: (value) {
    _dishes[dishIndex]['name'] = value;
    },
    validator: (value) {
    if (value == null || value.trim().isEmpty) {
    return 'Enter a dish name';
    }
    return null;
    },
    ),
    const SizedBox(height: 8),
    Row(
    children: [
    Expanded(
    child: TextFormField(
    initialValue: _dishes[dishIndex]['quantity'].toString(),
    decoration: InputDecoration(
    labelText: 'Quantity',
    filled: true,
    fillColor: Colors.white.withOpacity(0.5),
    border: OutlineInputBorder(
    borderRadius: BorderRadius.circular(12),
    borderSide: BorderSide.none,
    ),
    ),
    keyboardType: TextInputType.number,
    onChanged: (value) {
    _dishes[dishIndex]['quantity'] = int.tryParse(value) ?? 1;
    },
    validator: (value) {
    if (value == null || int.tryParse(value) == null || int.parse(value) < 1) {
    return 'Enter a valid quantity';
    }
    return null;
    },
    ),
    ),
    const SizedBox(width: 8),
    Expanded(
    child: TextFormField(
    initialValue: _dishes[dishIndex]['price'].toString(),
    decoration: InputDecoration(
    labelText: 'Price (\$)',
    filled: true,
    fillColor: Colors.white.withOpacity(0.5),
    border: OutlineInputBorder(
    borderRadius: BorderRadius.circular(12),
    borderSide: BorderSide.none,
    ),
    ),
    keyboardType: TextInputType.numberWithOptions(decimal: true),
    onChanged: (value) {
    _dishes[dishIndex]['price'] = double.tryParse(value) ?? 0.0;
    },
    validator: (value) {
    if (value == null || double.tryParse(value) == null || double.parse(value) <= 0) {
    return 'Enter a valid price';
    }
    return null;
    },
    ),
    ),
    ],
    ),
    const SizedBox(height: 8),
    Text(
    'Assign to Diners',
    style: const TextStyle(fontSize: 14, color: Colors.black54),
    ),
    Wrap(
    spacing: 8,
    children: List.generate(
    _dinerCount,
    (dinerIndex) => ChoiceChip(
    label: Text(
    _dinerControllers[dinerIndex].text.isEmpty
    ? 'Diner ${dinerIndex + 1}'
        : _dinerControllers[dinerIndex].text,
    ),
    selected: _assignments[dishIndex][dinerIndex],
    onSelected: (selected) {
    setState(() {
    _assignments[dishIndex][dinerIndex] = selected;
    });
    },
    selectedColor: Colors.black87.withOpacity(0.2),
    labelStyle: TextStyle(
    color: _assignments[dishIndex][dinerIndex] ? Colors.black87 : Colors.black54,
    ),
    ),
    ),
    ),
    const SizedBox(height: 16),
    ],
    ),
    ),
    TextButton(
    onPressed: _addDish,
    child: const Text('Add Dish', style: TextStyle(color: Colors.black87)),
    ),
    const SizedBox(height: 16),
    DropdownButtonFormField<double>(
    value: _tax,
    items: [
    const DropdownMenuItem(value: 5.0, child: Text('5% Tax')),
    const DropdownMenuItem(value: 10.0, child: Text('10% Tax')),
    const DropdownMenuItem(value: 0.0, child: Text('Custom Tax')),
    ],
    onChanged: (value) {
    setState(() {
    _tax = value ?? 5.0;
    if (_tax != 0.0) {
    _taxController.text = _tax.toString();
    } else {
    _taxController.text = '';
    }
    });
    },
    decoration: InputDecoration(
    labelText: 'Tax',
    filled: true,
    fillColor: Colors.white.withOpacity(0.5),
    border: OutlineInputBorder(
    borderRadius: BorderRadius.circular(12),
    borderSide: BorderSide.none,
    ),
    ),
    ),
    if (_tax == 0.0) ...[
    const SizedBox(height: 8),
    TextFormField(
    controller: _taxController,
    decoration: InputDecoration(
    labelText: 'Custom Tax (%)',
    filled: true,
    fillColor: Colors.white.withOpacity(0.5),
    border: OutlineInputBorder(
    borderRadius: BorderRadius.circular(12),
    borderSide: BorderSide.none,
    ),
    ),
    keyboardType: TextInputType.numberWithOptions(decimal: true),
    validator: (value) {
    if (value == null || double.tryParse(value) == null || double.parse(value) < 0) {
    return 'Enter a valid tax percentage';
    }
    return null;
    },
    ),
    ],
    const SizedBox(height: 16),
    TextFormField(
    initialValue: _tip.toString(),
    decoration: InputDecoration(
    labelText: 'Tip (\$)',
    filled: true,
    fillColor: Colors.white.withOpacity(0.5),
    border: OutlineInputBorder(
    borderRadius: BorderRadius.circular(12),
    borderSide: BorderSide.none,
    ),
    ),
    keyboardType: TextInputType.numberWithOptions(decimal: true),
    onChanged: (value) {
    _tip = double.tryParse(value) ?? 0.0;
    },
    validator: (value) {
    if (value == null || double.tryParse(value) == null || double.parse(value) < 0) {
    return 'Enter a valid tip amount';
    }
    return null;
    },
    ),
    const SizedBox(height: 16),
    Text(
    'Card Color',
    style: const TextStyle(fontSize: 14, color: Colors.black54),
    ),
    Wrap(
    spacing: 8,
    children: List.generate(
    widget.sessionColors.length,
    (index) => GestureDetector(
    onTap: () {
    setState(() {
    _selectedColorIndex = index;
    });
    },
    child: CircleAvatar(
    radius: 16,
    backgroundColor: widget.sessionColors[index],
    child: _selectedColorIndex == index
    ? const Icon(
    Icons.check,
    color: Colors.black54,
    size: 16,
    )
        : null,
    ),
    ),
    ),
    ),
    ],
    ),
    ),
    ),
    actions: [
    TextButton(
    onPressed: () {
    Navigator.pop(context);
    },
    child: const Text('Cancel', style: TextStyle(color: Colors.black54)),
    ),
    ElevatedButton(
    style: ElevatedButton.styleFrom(
    backgroundColor: Colors.black87,
    shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(12),
    ),
    ),
    onPressed: () {
    if (_formKey.currentState!.validate()) {
    // Validate that each dish is assigned to at least one diner
    for (var i = 0; i < _assignments.length; i++) {
    if (!_assignments[i].contains(true)) {
    ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(content: Text('Each dish must be assigned to at least one diner')),
    );
    return;
    }
    }
    final diners = List.generate(
    _dinerCount,
    (index) => {
    'name': _dinerControllers[index].text,
    'dishes': _assignments
        .asMap()
        .entries
        .where((entry) => entry.value[index])
        .map((entry) => entry.key)
        .toList(),
    },
    );
    final sessionData = {
    'id': widget.session?['id'],
    'date': currentDate,
    'tax': _tax == 0.0 ? double.parse(_taxController.text) : _tax,
    'tip': _tip,
    'diners': diners,
    'dishes': _dishes,
    'color': _selectedColorIndex,
    'diner_count': _dinerCount,
    'total': _dishes.fold<double>(
    0.0,
    (sum, dish) => sum + (dish['quantity'] * dish['price']),
    ) *
    (1 + (_tax == 0.0 ? double.parse(_taxController.text) : _tax) / 100) +
    _tip,
    'assignments': _assignments,
    };
    widget.onSessionSaved(sessionData);
    Navigator.pop(context);
    }
    },
    child: const Text('Save', style: TextStyle(color: Colors.white)),
    ),
    ],
    );
  }
}