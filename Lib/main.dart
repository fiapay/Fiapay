import 'package:flutter/material.dart';

void main() {
  runApp(const FiaPayApp());
}

class FiaPayApp extends StatelessWidget {
  const FiaPayApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FiaPay',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF8E44AD),
        ),
        useMaterial3: true,
      ),
      home: const HomePage(),
    );
  }
}

class Sale {
  final String product;
  final int quantity;
  final double unitPrice;
  final double discountPercent;
  final double feePercent;
  final String seller;
  final String customer;
  final double total;

  Sale({
    required this.product,
    required this.quantity,
    required this.unitPrice,
    required this.discountPercent,
    required this.feePercent,
    required this.seller,
    required this.customer,
    required this.total,
  });
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final List<Sale> sales = [];

  double get totalSales => sales.fold(0, (sum, sale) => sum + sale.total);

  String money(double value) => 'R\$ ${value.toStringAsFixed(2)}';

  Future<void> openSales() async {
    final sale = await Navigator.push<Sale>(
      context,
      MaterialPageRoute(builder: (_) => const NewSalePage()),
    );

    if (sale != null) {
      setState(() => sales.insert(0, sale));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('FiaPay'),
        backgroundColor: const Color(0xFF8E44AD),
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'Resumo de vendas',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Total registrado'),
                  const SizedBox(height: 6),
                  Text(
                    money(totalSales),
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text('${sales.length} venda(s)'),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          FilledButton.icon(
            onPressed: openSales,
            icon: const Icon(Icons.add_shopping_cart),
            label: const Text('Registrar venda'),
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFF8E44AD),
              padding: const EdgeInsets.all(14),
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Vendas registradas',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          if (sales.isEmpty)
            const Padding(
              padding: EdgeInsets.only(top: 12),
              child: Text('Nenhuma venda registrada ainda.'),
            ),
          ...sales.map(
            (sale) => Card(
              child: ListTile(
                title: Text('${sale.product} — ${sale.quantity} un.'),
                subtitle: Text(
                  'Cliente: ${sale.customer}\nVendedor: ${sale.seller}',
                ),
                isThreeLine: true,
                trailing: Text(
                  money(sale.total),
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class NewSalePage extends StatefulWidget {
  const NewSalePage({super.key});

  @override
  State<NewSalePage> createState() => _NewSalePageState();
}

class _NewSalePageState extends State<NewSalePage> {
  final formKey = GlobalKey<FormState>();
  final productController = TextEditingController();
  final quantityController = TextEditingController(text: '1');
  final priceController = TextEditingController();
  final discountController = TextEditingController(text: '0');
  final feeController = TextEditingController(text: '0');
  final sellerController = TextEditingController();
  final customerController = TextEditingController();

  double parseNumber(String text) {
    return double.tryParse(text.replaceAll(',', '.')) ?? 0;
  }

  String? requiredText(String? value) {
    if (value == null || value.trim().isEmpty) return 'Preencha este campo';
    return null;
  }

  String? validNumber(String? value, {bool allowZero = false}) {
    final number = parseNumber(value ?? '');
    if (value == null || value.trim().isEmpty) return 'Preencha este campo';
    if (number < 0 || (!allowZero && number == 0)) {
      return allowZero ? 'Informe um valor igual ou maior que zero' : 'Informe um valor maior que zero';
    }
    return null;
  }

  double get subtotal =>
      parseNumber(priceController.text) * parseNumber(quantityController.text);

  double get discountAmount =>
      subtotal * parseNumber(discountController.text) / 100;

  double get feeAmount =>
      (subtotal - discountAmount) * parseNumber(feeController.text) / 100;

  double get total => subtotal - discountAmount + feeAmount;

  void saveSale() {
    if (!formKey.currentState!.validate()) return;

    final discount = parseNumber(discountController.text);
    final fee = parseNumber(feeController.text);

    if (discount > 100 || fee > 100) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Desconto e taxa devem ser de até 100%.')),
      );
      return;
    }

    Navigator.pop(
      context,
      Sale(
        product: productController.text.trim(),
        quantity: parseNumber(quantityController.text).toInt(),
        unitPrice: parseNumber(priceController.text),
        discountPercent: discount,
        feePercent: fee,
        seller: sellerController.text.trim(),
        customer: customerController.text.trim(),
        total: total,
      ),
    );
  }

  Widget field(
    String label,
    TextEditingController controller, {
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
        validator: validator,
        onChanged: (_) => setState(() {}),
      ),
    );
  }

  @override
  void dispose() {
    productController.dispose();
    quantityController.dispose();
    priceController.dispose();
    discountController.dispose();
    feeController.dispose();
    sellerController.dispose();
    customerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Registrar venda'),
        backgroundColor: const Color(0xFF8E44AD),
        foregroundColor: Colors.white,
      ),
      body: Form(
        key: formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            field('Produto', productController, validator: requiredText),
            field(
              'Quantidade',
              quantityController,
              keyboardType: TextInputType.number,
              validator: (v) {
                final error = validNumber(v);
                if (error != null) return error;
                if (parseNumber(v!) % 1 != 0) return 'Use uma quantidade inteira';
                return null;
              },
            ),
            field(
              'Preço unitário (R\$)',
              priceController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              validator: validNumber,
            ),
            field(
              'Desconto (%)',
              discountController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              validator: (v) => validNumber(v, allowZero: true),
            ),
            field(
              'Taxa (%)',
              feeController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              validator: (v) => validNumber(v, allowZero: true),
            ),
            field('Vendedor', sellerController, validator: requiredText),
            field('Cliente', customerController, validator: requiredText),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Subtotal: R\$ ${subtotal.toStringAsFixed(2)}'),
                    Text('Desconto: R\$ ${discountAmount.toStringAsFixed(2)}'),
                    Text('Taxa: R\$ ${feeAmount.toStringAsFixed(2)}'),
                    const Divider(),
                    Text(
                      'Total: R\$ ${total.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            FilledButton(
              onPressed: saveSale,
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF8E44AD),
                padding: const EdgeInsets.all(14),
              ),
              child: const Text('Salvar venda'),
            ),
          ],
        ),
      ),
    );
  }
}
}
