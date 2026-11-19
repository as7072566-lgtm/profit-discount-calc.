import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(const ProfitCalcApp());
}

class ProfitCalcApp extends StatelessWidget {
  const ProfitCalcApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'حاسبة الأرباح والخصومات',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: const Color(0xFF0F766E),
        brightness: Brightness.light,
      ),
      home: const Directionality(
        textDirection: TextDirection.rtl,
        child: MainHomePage(),
      ),
    );
  }
}

class MainHomePage extends StatefulWidget {
  const MainHomePage({super.key});

  @override
  State<MainHomePage> createState() => _MainHomePageState();
}

class _MainHomePageState extends State<MainHomePage> {
  int _selectedIndex = 0;

  final List<Widget> _pages = const [
    ProfitMarginTab(),
    DiscountTab(),
    UnitCostTab(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'حاسبة الأرباح والخصومات',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
      ),
      body: _pages[_selectedIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) {
          setState(() => _selectedIndex = index);
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.trending_up),
            label: 'الربح والهامش',
          ),
          NavigationDestination(
            icon: Icon(Icons.local_offer),
            label: 'الخصومات',
          ),
          NavigationDestination(
            icon: Icon(Icons.inventory_2),
            label: 'تكلفة القطعة',
          ),
        ],
      ),
    );
  }
}

// ==========================================
// 1. تبويب حاسبة الربح وهامش الربح
// ==========================================
class ProfitMarginTab extends StatefulWidget {
  const ProfitMarginTab({super.key});

  @override
  State<ProfitMarginTab> createState() => _ProfitMarginTabState();
}

class _ProfitMarginTabState extends State<ProfitMarginTab> {
  final _costCtrl = TextEditingController();
  final _sellCtrl = TextEditingController();
  final _qtyCtrl = TextEditingController(text: '1');

  double _unitProfit = 0;
  double _totalProfit = 0;
  double _marginPercent = 0;
  double _markupPercent = 0;

  void _calculate() {
    final cost = double.tryParse(_costCtrl.text) ?? 0;
    final sell = double.tryParse(_sellCtrl.text) ?? 0;
    final qty = double.tryParse(_qtyCtrl.text) ?? 1;

    setState(() {
      _unitProfit = sell - cost;
      _totalProfit = _unitProfit * qty;
      _marginPercent = sell > 0 ? (_unitProfit / sell) * 100 : 0;
      _markupPercent = cost > 0 ? (_unitProfit / cost) * 100 : 0;
    });
  }

  void _reset() {
    _costCtrl.clear();
    _sellCtrl.clear();
    _qtyCtrl.text = '1';
    _calculate();
  }

  void _copyResult() {
    final text = '''
ملخص حساب الربح:
- صافي ربح القطعة: ${_unitProfit.toStringAsFixed(2)}
- إجمالي الربح: ${_totalProfit.toStringAsFixed(2)}
- هامش الربح (Margin): ${_marginPercent.toStringAsFixed(1)}%
- نسبة الزيادة (Markup): ${_markupPercent.toStringAsFixed(1)}%
''';
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('تم نسخ النتيجة بنجاح')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildInputField(_costCtrl, 'سعر التكلفة (الشراء)', Icons.shopping_cart),
        const SizedBox(height: 12),
        _buildInputField(_sellCtrl, 'سعر البيع', Icons.sell),
        const SizedBox(height: 12),
        _buildInputField(_qtyCtrl, 'الكمية (عدد القطع)', Icons.numbers),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: FilledButton.icon(
                onPressed: _calculate,
                icon: const Icon(Icons.calculate),
                label: const Text('احسب الربح'),
              ),
            ),
            const SizedBox(width: 8),
            OutlinedButton.icon(
              onPressed: _reset,
              icon: const Icon(Icons.refresh),
              label: const Text('مسح'),
            ),
          ],
        ),
        const SizedBox(height: 20),
        Card(
          elevation: 2,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _resultRow('صافي ربح القطعة', _unitProfit.toStringAsFixed(2),
                    isHighlight: true),
                const Divider(),
                _resultRow('إجمالي الربح للكمية', _totalProfit.toStringAsFixed(2)),
                const Divider(),
                _resultRow('هامش الربح (Margin)', '${_marginPercent.toStringAsFixed(1)}%'),
                const Divider(),
                _resultRow('نسبة الربح للتكلفة (Markup)', '${_markupPercent.toStringAsFixed(1)}%'),
                const SizedBox(height: 12),
                TextButton.icon(
                  onPressed: _copyResult,
                  icon: const Icon(Icons.copy),
                  label: const Text('نسخ النتيجة'),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ==========================================
// 2. تبويب حاسبة الخصومات
// ==========================================
class DiscountTab extends StatefulWidget {
  const DiscountTab({super.key});

  @override
  State<DiscountTab> createState() => _DiscountTabState();
}

class _DiscountTabState extends State<DiscountTab> {
  final _priceCtrl = TextEditingController();
  final _discountCtrl = TextEditingController();

  double _finalPrice = 0;
  double _savedAmount = 0;

  void _calculate() {
    final price = double.tryParse(_priceCtrl.text) ?? 0;
    final discount = double.tryParse(_discountCtrl.text) ?? 0;

    setState(() {
      _savedAmount = price * (discount / 100);
      _finalPrice = price - _savedAmount;
    });
  }

  void _reset() {
    _priceCtrl.clear();
    _discountCtrl.clear();
    _calculate();
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildInputField(_priceCtrl, 'السعر الأصلي قبل الخصم', Icons.attach_money),
        const SizedBox(height: 12),
        _buildInputField(_discountCtrl, 'نسبة الخصم (%)', Icons.percent),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: FilledButton.icon(
                onPressed: _calculate,
                icon: const Icon(Icons.calculate),
                label: const Text('احسب السعر بعد الخصم'),
              ),
            ),
            const SizedBox(width: 8),
            OutlinedButton.icon(
              onPressed: _reset,
              icon: const Icon(Icons.refresh),
              label: const Text('مسح'),
            ),
          ],
        ),
        const SizedBox(height: 20),
        Card(
          elevation: 2,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _resultRow('السعر النهائي بعد الخصم', _finalPrice.toStringAsFixed(2),
                    isHighlight: true),
                const Divider(),
                _resultRow('قيمة التوفير (الخصم)', _savedAmount.toStringAsFixed(2)),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ==========================================
// 3. تبويب حاسبة تكلفة القطعة والشحن
// ==========================================
class UnitCostTab extends StatefulWidget {
  const UnitCostTab({super.key});

  @override
  State<UnitCostTab> createState() => _UnitCostTabState();
}

class _UnitCostTabState extends State<UnitCostTab> {
  final _invoiceCtrl = TextEditingController();
  final _shippingCtrl = TextEditingController(text: '0');
  final _extraCtrl = TextEditingController(text: '0');
  final _qtyCtrl = TextEditingController(text: '1');

  double _totalCost = 0;
  double _costPerUnit = 0;

  void _calculate() {
    final invoice = double.tryParse(_invoiceCtrl.text) ?? 0;
    final shipping = double.tryParse(_shippingCtrl.text) ?? 0;
    final extra = double.tryParse(_extraCtrl.text) ?? 0;
    final qty = double.tryParse(_qtyCtrl.text) ?? 1;

    setState(() {
      _totalCost = invoice + shipping + extra;
      _costPerUnit = qty > 0 ? _totalCost / qty : 0;
    });
  }

  void _reset() {
    _invoiceCtrl.clear();
    _shippingCtrl.text = '0';
    _extraCtrl.text = '0';
    _qtyCtrl.text = '1';
    _calculate();
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildInputField(_invoiceCtrl, 'إجمالي فاتورة البضاعة', Icons.receipt_long),
        const SizedBox(height: 12),
        _buildInputField(_shippingCtrl, 'تكلفة الشحن والتوصيل', Icons.local_shipping),
        const SizedBox(height: 12),
        _buildInputField(_extraCtrl, 'مصاريف إضافية (تغليف/إعلان)', Icons.add_card),
        const SizedBox(height: 12),
        _buildInputField(_qtyCtrl, 'إجمالي عدد القطع', Icons.inventory),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: FilledButton.icon(
                onPressed: _calculate,
                icon: const Icon(Icons.calculate),
                label: const Text('احسب تكلفة القطعة'),
              ),
            ),
            const SizedBox(width: 8),
            OutlinedButton.icon(
              onPressed: _reset,
              icon: const Icon(Icons.refresh),
              label: const Text('مسح'),
            ),
          ],
        ),
        const SizedBox(height: 20),
        Card(
          elevation: 2,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _resultRow('التكلفة الفعلية للقطعة الواحدة', _costPerUnit.toStringAsFixed(2),
                    isHighlight: true),
                const Divider(),
                _resultRow('إجمالي التكاليف الكلي', _totalCost.toStringAsFixed(2)),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ==========================================
// عناصر مساعدة مشتركة
// ==========================================
Widget _buildInputField(TextEditingController ctrl, String label, IconData icon) {
  return TextField(
    controller: ctrl,
    keyboardType: const TextInputType.numberWithOptions(decimal: true),
    decoration: InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon),
      border: const OutlineInputBorder(),
    ),
  );
}

Widget _resultRow(String title, String value, {bool isHighlight = false}) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 6),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: isHighlight ? 16 : 14,
            fontWeight: isHighlight ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: isHighlight ? 20 : 16,
            fontWeight: FontWeight.bold,
            color: isHighlight ? const Color(0xFF0F766E) : null,
          ),
        ),
      ],
    ),
  );
}
