import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CalculatorView extends StatefulWidget {
  const CalculatorView({super.key});
  @override
  State<CalculatorView> createState() => _CalculatorViewState();
}

class _CalculatorViewState extends State<CalculatorView> {
  String _display = '0';
  String _operator = '';
  double? _first;
  bool _shouldReset = false;

  void _onDigit(String d) {
    setState(() {
      if (_shouldReset || _display == '0') {
        _display = d;
        _shouldReset = false;
      } else {
        _display = '$_display$d';
      }
    });
  }

  void _onDecimal() {
    setState(() {
      if (_shouldReset) {
        _display = '0.';
        _shouldReset = false;
        return;
      }
      if (!_display.contains('.')) _display += '.';
    });
  }

  void _clearAll() {
    setState(() {
      _display = '0';
      _operator = '';
      _first = null;
      _shouldReset = false;
    });
  }

  void _delete() {
    setState(() {
      if (_shouldReset) {
        _display = '0';
        _shouldReset = false;
        return;
      }
      if (_display.length <= 1) {
        _display = '0';
      } else {
        _display = _display.substring(0, _display.length - 1);
      }
    });
  }

   void _toggleSign() {
     setState(() {
       if (_display.startsWith('-')) {
         _display = _display.substring(1);
       } else if (_display != '0') {
         _display = '-$_display';
       }
     });
   }

  double _parseDisplay() => double.tryParse(_display) ?? 0.0;

  void _setOperator(String op) {
    setState(() {
      final curr = _parseDisplay();
      if (_first == null) {
        _first = curr;
      } else if (_operator.isNotEmpty && !_shouldReset) {
        _first = _compute(_first!, _operator, curr);
        _display = _format(_first!);
      }
      _operator = op;
      _shouldReset = true;
    });
  }

  double _compute(double a, String op, double b) {
    switch (op) {
      case '+':
        return a + b;
      case '-':
        return a - b;
      case '×':
      case '*':
        return a * b;
      case '÷':
      case '/':
        if (b == 0) return 0;
        return a / b;
      default:
        return b;
    }
  }

  String _format(double v) {
    if (v % 1 == 0) return v.toInt().toString();
    return v.toString();
  }

  void _equals() {
    setState(() {
      if (_operator.isEmpty || _first == null) return;
      final curr = _parseDisplay();
      final res = _compute(_first!, _operator, curr);
      _display = _format(res);
      _first = null;
      _operator = '';
      _shouldReset = true;
    });
  }

  Widget _button(String label, {Color? color, VoidCallback? onTap}) {
    return Padding(
      padding: const EdgeInsets.all(6.0),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: color ?? Theme.of(context).cardColor,
          padding: const EdgeInsets.all(18),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 0,
        ),
        onPressed: onTap,
        child: Text(label, style: GoogleFonts.outfit(fontSize: 20, color: Theme.of(context).textTheme.bodyLarge?.color)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Calculator')),
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: theme.cardColor, borderRadius: BorderRadius.circular(12)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(_operator.isEmpty ? '' : _operator, style: GoogleFonts.outfit(color: theme.textTheme.bodyMedium?.color)),
                    const SizedBox(height: 8),
                    Text(_display, style: GoogleFonts.outfit(fontSize: 36, fontWeight: FontWeight.bold, color: theme.textTheme.bodyLarge?.color)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            // Buttons
            Column(
              children: [
                Row(children: [
                  Expanded(child: _button('C', color: Colors.grey.shade700, onTap: _clearAll)),
                  Expanded(child: _button('DEL', color: Colors.grey.shade700, onTap: _delete)),
                  Expanded(child: _button('%', color: Colors.grey.shade700, onTap: () { setState(() => _display = (_parseDisplay() / 100).toString()); })),
                  Expanded(child: _button('÷', color: theme.colorScheme.secondary, onTap: () => _setOperator('/'))),
                ]),
                Row(children: [
                  Expanded(child: _button('7', onTap: () => _onDigit('7'))),
                  Expanded(child: _button('8', onTap: () => _onDigit('8'))),
                  Expanded(child: _button('9', onTap: () => _onDigit('9'))),
                  Expanded(child: _button('×', color: theme.colorScheme.secondary, onTap: () => _setOperator('*'))),
                ]),
                Row(children: [
                  Expanded(child: _button('4', onTap: () => _onDigit('4'))),
                  Expanded(child: _button('5', onTap: () => _onDigit('5'))),
                  Expanded(child: _button('6', onTap: () => _onDigit('6'))),
                  Expanded(child: _button('-', color: theme.colorScheme.secondary, onTap: () => _setOperator('-'))),
                ]),
                Row(children: [
                  Expanded(child: _button('1', onTap: () => _onDigit('1'))),
                  Expanded(child: _button('2', onTap: () => _onDigit('2'))),
                  Expanded(child: _button('3', onTap: () => _onDigit('3'))),
                  Expanded(child: _button('+', color: theme.colorScheme.secondary, onTap: () => _setOperator('+'))),
                ]),
                Row(children: [
                  Expanded(child: _button('+/-', onTap: _toggleSign)),
                  Expanded(child: _button('0', onTap: () => _onDigit('0'))),
                  Expanded(child: _button('.', onTap: _onDecimal)),
                  Expanded(child: _button('=', color: theme.colorScheme.primary, onTap: _equals)),
                ]),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

