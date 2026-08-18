import 'package:flutter/material.dart';

void main() => runApp(const NagdarApp());

/// Nagdar — piece-rate wage slip. Totals a worker's pay across rate-categories,
/// net of rejects. Mirrors the Go engine; the printable slip is the point.
class NagdarApp extends StatelessWidget {
  const NagdarApp({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
        title: 'Nagdar',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(colorSchemeSeed: const Color(0xFF3E6E8E), useMaterial3: true),
        home: const HomePage(),
      );
}

class Line {
  String category;
  int qty, rejects;
  double rate;
  Line(this.category, this.qty, this.rejects, this.rate);
  int get paid => qty - rejects;
  double get amount => paid * rate;
}

/// netWage totals (qty − rejects) × rate across lines.
double netWage(List<Line> lines) => lines.fold(0.0, (s, l) => s + l.amount);

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _worker = TextEditingController(text: 'Radha');
  final _lines = <Line>[Line('stitch', 120, 5, 3), Line('button', 200, 0, 0.5)];

  @override
  Widget build(BuildContext context) {
    final wage = netWage(_lines);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nagdar · wage slip'),
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
      ),
      body: ListView(padding: const EdgeInsets.all(16), children: [
        TextField(controller: _worker, decoration: const InputDecoration(labelText: 'Worker', border: OutlineInputBorder())),
        const SizedBox(height: 12),
        const Text('Rate lines', style: TextStyle(fontWeight: FontWeight.w600)),
        for (var i = 0; i < _lines.length; i++) _lineRow(i),
        TextButton.icon(onPressed: () => setState(() => _lines.add(Line('', 0, 0, 0))),
            icon: const Icon(Icons.add), label: const Text('Add rate line')),
        const SizedBox(height: 12),
        Card(
          color: Theme.of(context).colorScheme.primaryContainer,
          child: Padding(padding: const EdgeInsets.all(16),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('${_worker.text} — wage slip', style: const TextStyle(fontWeight: FontWeight.bold)),
              const Divider(),
              for (final l in _lines)
                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  Text('${l.category}: ${l.paid} × ₹${l.rate}'),
                  Text('₹${l.amount.toStringAsFixed(2)}'),
                ]),
              const Divider(),
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                const Text('Net wage', style: TextStyle(fontWeight: FontWeight.bold)),
                Text('₹${wage.toStringAsFixed(2)}', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              ]),
            ])),
        ),
      ]),
    );
  }

  Widget _lineRow(int i) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(children: [
          Expanded(flex: 3, child: TextField(
            decoration: const InputDecoration(labelText: 'Category', border: OutlineInputBorder()),
            controller: TextEditingController(text: _lines[i].category),
            onChanged: (v) => _lines[i].category = v,
          )),
          const SizedBox(width: 6),
          Expanded(flex: 2, child: _int('Qty', _lines[i].qty, (v) => setState(() => _lines[i].qty = v))),
          const SizedBox(width: 6),
          Expanded(flex: 2, child: _int('Rej', _lines[i].rejects, (v) => setState(() => _lines[i].rejects = v))),
          const SizedBox(width: 6),
          Expanded(flex: 2, child: TextField(
            decoration: const InputDecoration(labelText: '₹', border: OutlineInputBorder()),
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            controller: TextEditingController(text: _lines[i].rate.toString()),
            onChanged: (v) => setState(() => _lines[i].rate = double.tryParse(v) ?? 0),
          )),
        ]),
      );

  Widget _int(String label, int val, void Function(int) onCh) => TextField(
        decoration: InputDecoration(labelText: label, border: const OutlineInputBorder()),
        keyboardType: TextInputType.number,
        controller: TextEditingController(text: val.toString()),
        onChanged: (v) => onCh(int.tryParse(v) ?? 0),
      );
}
