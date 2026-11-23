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
          seedColor: const Color(0xFF7541A5),
        ),
        useMaterial3: true,
      ),
      home: const HomePage(),
    );
  }
}

class SaleItem {
  final String product;
  final int quantity;
  final double price;

  SaleItem({
    required this.product,
    required this.quantity,
    required this.price,
  });

  double get total => quantity * price;
}

class Sale {
  final String customer;
  final String seller;
  final List<SaleItem> items;
  final double discount;
  final double fee;
  final String payment;
  final String status;
  final double total;

  Sale({
    required this.customer,
    required this.seller,
    required this.items,
    required this.discount,
    required this.fee,
    required this.payment,
    required this.status,
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

  String money(double value) => 'R\$ ${value.toStringAsFixed(2)}';

  Future<void> openNewSale() async {
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
    final totalSales = sales.fold<double>(0, (sum, sale) => sum + sale.total);

    return Scaffold(
      appBar: AppBar(
        title: const Text('FiaPay'),
        backgroundColor: const Color(0xFF7541A5),
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
            child: ListTile(
              title: const Text('Total registrado'),
              subtitle: Text('${sales.length} venda(s)'),
              trailing: Text(
                money(totalSales),
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
          const SizedBox(height: 12),
          FilledButton.icon(
            onPressed: openNewSale,
            icon: const Icon(Icons.add),
            label: const Text('Nova venda'),
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFF7541A5),
              padding: const EdgeInsets.all(14),
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Vendas recentes',
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
                title: Text('${sale.status} • ${money(sale.total)}'),
                subtitle: Text(
                  'Cliente: ${sale.customer}\n'
                  'Vendedor: ${sale.seller} • ${sale.payment}',
                ),
                isThreeLine: true,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ItemFields {
  final TextEditingController product = TextEditingController();
  final TextEditingController quantity =
      TextEditingController(text: '1');
  final TextEditingController price = TextEditingController();

  void dispose() {
    product.dispose();
    quantity.dispose();
    price.dispose();
  }
}

class NewSalePage extends StatefulWidget {
  const NewSalePage({super.key});

  @override
  State<NewSalePage> createState() => _NewSalePageState();
}

class _NewSalePageState extends State<NewSalePage> {
  final formKey = GlobalKey<FormState>();
  final customerController = TextEditingController();
  final sellerController = TextEditingController();
  final discountController = TextEditingController(text: '0');
  final feeController = TextEditingController(text: '0');
  final paidController = TextEditingController(text: '0');

  final List<ItemFields> items = [ItemFields()];
  String payment = 'Pix';

  double number(String value) =>
      double.tryParse(value.replaceAll(',', '.')) ?? 0;

  double get subtotal {
    return items.fold<double>(0, (sum, item) {
      return sum +
          number(item.quantity.text) * number(item.price.text);
    });
  }

  double get discountAmount {
    return subtotal * number(discountController.text) / 100;
  }

  double get feeAmount {
    return (subtotal - discountAmount) * number(feeController.text) / 100;
  }

  double get total => subtotal - discountAmount + feeAmount;

  double get change {
    final result = number(paidController.text) - total;
    return result > 0 ? result : 0;
  }

  String? requiredField(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Preencha este campo';
    }
    return null;
  }

  String? validPositive(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Preencha este campo';
    }
    if (number(value) <= 0) return 'Informe um valor maior que zero';
    return null;
  }

  String? validPercent(String? value) {
    if (value == null || value.trim().isEmpty) return 'Preencha este campo';
    final result = number(value);
    if (result < 0 || result > 100) {
      return 'Use um valor entre 0 e 100';
    }
    return null;
  }

  void addItem() {
    setState(() => items.add(ItemFields()));
  }

  void removeItem(int index) {
    if (items.length == 1) return;
    setState(() {
      items[index].dispose();
      items.removeAt(index);
    });
  }

  void saveSale(String status) {
    if (!formKey.currentState!.validate()) return;

    final saleItems = items.map((item) {
      return SaleItem(
        product: item.product.text.trim(),
        quantity: number(item.quantity.text).toInt(),
        price: number(item.price.text),
      );
    }).toList();

    Navigator.pop(
      context,
      Sale(
        customer: customerController.text.trim(),
        seller: sellerController.text.trim(),
        items: saleItems,
        discount: discountAmount,
        fee: feeAmount,
        payment: payment,
        status: status,
        total: total,
      ),
    );
  }

  Widget textField({
    required String label,
    required TextEditingController controller,
    String? Function(String?)? validator,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: controller,
        validator: validator,
        keyboardType: keyboardType,
        onChanged: (_) => setState(() {}),
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }

  Widget sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 12),
      child: Text(
        title,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
  }

  @override
  void dispose() {
    customerController.dispose();
    sellerController.dispose();
    discountController.dispose();
    feeController.dispose();
    paidController.dispose();
    for (final item in items) {
      item.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nova venda'),
        backgroundColor: const Color(0xFF7541A5),
        foregroundColor: Colors.white,
      ),
      body: Form(
        key: formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            sectionTitle('Cliente e vendedor'),
            textField(
              label: 'Nome do cliente',
              controller: customerController,
              validator: requiredField,
            ),
            textField(
              label: 'Nome do vendedor',
              controller: sellerController,
              validator: requiredField,
            ),
            sectionTitle('Produtos'),
            ...List.generate(items.length, (index) {
              final item = items[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              'Produto ${index + 1}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          IconButton(
                            onPressed: items.length > 1
                                ? () => removeItem(index)
                                : null,
                            icon: const Icon(Icons.delete_outline),
                          ),
                        ],
                      ),
                      textField(
                        label: 'Nome do produto',
                        controller: item.product,
                        validator: requiredField,
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: textField(
                              label: 'Quantidade',
                              controller: item.quantity,
                              keyboardType: TextInputType.number,
                              validator: validPositive,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: textField(
                              label: 'Preço unitário (R\$)',
                              controller: item.price,
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                decimal: true,
                              ),
                              validator: validPositive,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            }),
            OutlinedButton.icon(
              onPressed: addItem,
              icon: const Icon(Icons.add),
              label: const Text('Adicionar produto'),
            ),
            sectionTitle('Desconto e taxa'),
            Row(
              children: [
                Expanded(
                  child: textField(
                    label: 'Desconto (%)',
                    controller: discountController,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    validator: validPercent,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: textField(
                    label: 'Taxa (%)',
                    controller: feeController,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    validator: validPercent,
                  ),
                ),
              ],
            ),
            sectionTitle('Pagamento'),
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: DropdownButtonFormField<String>(
                value: payment,
                decoration: const InputDecoration(
                  labelText: 'Forma de pagamento',
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(value: 'Pix', child: Text('Pix')),
                  DropdownMenuItem(
                    value: 'Dinheiro',
                    child: Text('Dinheiro'),
                  ),
                  DropdownMenuItem(
                    value: 'Cartão de crédito',
                    child: Text('Cartão de crédito'),
                  ),
                  DropdownMenuItem(
                    value: 'Cartão de débito',
                    child: Text('Cartão de débito'),
                  ),
                  DropdownMenuItem(value: 'Pendente', child: Text('Pendente')),
                ],
                onChanged: (value) {
                  if (value != null) setState(() => payment = value);
                },
              ),
            ),
            textField(
              label: 'Valor recebido (R\$)',
              controller: paidController,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Preencha este campo';
                }
                if (number(value) < 0) return 'O valor não pode ser negativo';
                return null;
              },
            ),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Subtotal: R\$ ${subtotal.toStringAsFixed(2)}'),
                    Text(
                      'Desconto: R\$ ${discountAmount.toStringAsFixed(2)}',
                    ),
                    Text('Taxa: R\$ ${feeAmount.toStringAsFixed(2)}'),
                    const Divider(),
                    Text(
                      'Total: R\$ ${total.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text('Troco: R\$ ${change.toStringAsFixed(2)}'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            OutlinedButton(
              onPressed: () => saveSale('Rascunho'),
              child: const Text('Salvar como rascunho'),
            ),
            const SizedBox(height: 8),
            FilledButton(
              onPressed: () => saveSale('Concluída'),
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF7541A5),
                padding: const EdgeInsets.all(14),
              ),
              child: const Text('Concluir venda'),
            ),
          ],
        ),
      ),
    );
  }
}
```
