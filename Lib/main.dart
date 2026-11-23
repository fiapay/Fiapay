import 'package:flutter/material.dart';

void main() => runApp(const FiaPayApp());

class FiaPayApp extends StatelessWidget {
  const FiaPayApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FiaPay',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF7541A5)),
        useMaterial3: true,
      ),
      home: const HomePage(),
    );
  }
}

class Product {
  String name;
  double price;
  int stock;

  Product({required this.name, required this.price, required this.stock});
}

class SaleLine {
  final Product product;
  final int quantity;

  SaleLine(this.product, this.quantity);
}

class Sale {
  final String customer;
  final String seller;
  final String payment;
  final List<SaleLine> items;
  final double total;
  final DateTime date;

  Sale({
    required this.customer,
    required this.seller,
    required this.payment,
    required this.items,
    required this.total,
    required this.date,
  });
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final List<Product> products = [];
  final List<String> customers = [];
  final List<String> sellers = [];
  final List<Sale> sales = [];
  final List<String> activityLog = [];

  void log(String message) {
    activityLog.insert(0, '${DateTime.now().toLocal()} — $message');
  }

  String money(double value) => 'R\$ ${value.toStringAsFixed(2)}';

  Future<void> addProduct() async {
    final name = TextEditingController();
    final price = TextEditingController();
    final stock = TextEditingController(text: '0');

    final result = await showDialog<Product>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cadastrar produto'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: name, decoration: const InputDecoration(labelText: 'Nome')),
            TextField(
              controller: price,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(labelText: 'Preço (R\$)'),
            ),
            TextField(
              controller: stock,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Quantidade em estoque'),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
          FilledButton(
            onPressed: () {
              final parsedPrice = double.tryParse(price.text.replaceAll(',', '.'));
              final parsedStock = int.tryParse(stock.text);
              if (name.text.trim().isEmpty || parsedPrice == null ||
                  parsedPrice < 0 || parsedStock == null || parsedStock < 0) {
                return;
              }
              Navigator.pop(
                context,
                Product(name: name.text.trim(), price: parsedPrice, stock: parsedStock),
              );
            },
            child: const Text('Salvar'),
          ),
        ],
      ),
    );

    name.dispose();
    price.dispose();
    stock.dispose();

    if (result != null) {
      setState(() {
        products.add(result);
        log('Produto cadastrado: ${result.name}');
      });
    }
  }

  Future<void> addPerson(String type) async {
    final controller = TextEditingController();
    final name = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Cadastrar $type'),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(labelText: 'Nome do $type'),
          textCapitalization: TextCapitalization.words,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
          FilledButton(
            onPressed: () {
              if (controller.text.trim().isNotEmpty) {
                Navigator.pop(context, controller.text.trim());
              }
            },
            child: const Text('Salvar'),
          ),
        ],
      ),
    );
    controller.dispose();

    if (name != null) {
      setState(() {
        (type == 'cliente' ? customers : sellers).add(name);
        log('$type cadastrado: $name');
      });
    }
  }

  Future<void> newSale() async {
    if (products.isEmpty || customers.isEmpty || sellers.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cadastre pelo menos um produto, cliente e vendedor antes da venda.')),
      );
      return;
    }

    final sale = await Navigator.push<Sale>(
      context,
      MaterialPageRoute(
        builder: (_) => NewSalePage(
          products: products,
          customers: customers,
          sellers: sellers,
        ),
      ),
    );

    if (sale == null) return;

    setState(() {
      for (final line in sale.items) {
        line.product.stock -= line.quantity;
      }
      sales.insert(0, sale);
      log('Venda de ${money(sale.total)} concluída por ${sale.seller} para ${sale.customer}');
    });
  }

  Widget menuButton(String title, IconData icon, VoidCallback onPressed) {
    return Card(
      child: ListTile(
        leading: Icon(icon, color: const Color(0xFF7541A5)),
        title: Text(title),
        trailing: const Icon(Icons.chevron_right),
        onTap: onPressed,
      ),
    );
  }

  void showList(String title, List<String> values) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => SimpleListPage(title: title, values: values),
      ),
    );
  }

  void showProducts() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ProductListPage(products: products, money: money),
      ),
    );
  }

  void showLog() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => SimpleListPage(title: 'Log do sistema', values: activityLog),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final total = sales.fold<double>(0, (sum, sale) => sum + sale.total);

    return Scaffold(
      appBar: AppBar(
        title: const Text('FiaPay'),
        backgroundColor: const Color(0xFF7541A5),
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: ListTile(
              title: const Text('Resumo de vendas'),
              subtitle: Text('${sales.length} venda(s)'),
              trailing: Text(money(total), style: const TextStyle(fontWeight: FontWeight.bold)),
            ),
          ),
          const SizedBox(height: 8),
          FilledButton.icon(
            onPressed: newSale,
            icon: const Icon(Icons.add),
            label: const Text('Nova venda'),
          ),
          menuButton('Estoque e produtos', Icons.inventory_2, showProducts),
          menuButton('Cadastrar produto', Icons.add_box, addProduct),
          menuButton('Clientes', Icons.people, () => showList('Clientes', customers)),
          menuButton('Cadastrar cliente', Icons.person_add, () => addPerson('cliente')),
          menuButton('Vendedores', Icons.badge, () => showList('Vendedores', sellers)),
          menuButton('Cadastrar vendedor', Icons.person_add_alt_1, () => addPerson('vendedor')),
          menuButton('Log do sistema', Icons.history, showLog),
          const SizedBox(height: 12),
          const Text('Vendas recentes', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          if (sales.isEmpty) const Text('Nenhuma venda registrada.'),
          ...sales.map((sale) => Card(
            child: ListTile(
              title: Text(money(sale.total)),
              subtitle: Text('${sale.customer} • ${sale.seller} • ${sale.payment}'),
            ),
          )),
        ],
      ),
    );
  }
}

class SimpleListPage extends StatelessWidget {
  final String title;
  final List<String> values;

  const SimpleListPage({super.key, required this.title, required this.values});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: values.isEmpty
          ? const Center(child: Text('Nenhum cadastro ainda.'))
          : ListView.builder(
              itemCount: values.length,
              itemBuilder: (_, index) => ListTile(title: Text(values[index])),
            ),
    );
  }
}

class ProductListPage extends StatelessWidget {
  final List<Product> products;
  final String Function(double) money;

  const ProductListPage({super.key, required this.products, required this.money});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Estoque e produtos')),
      body: products.isEmpty
          ? const Center(child: Text('Nenhum produto cadastrado.'))
          : ListView.builder(
              itemCount: products.length,
              itemBuilder: (_, index) {
                final product = products[index];
                return ListTile(
                  title: Text(product.name),
                  subtitle: Text('Estoque: ${product.stock}'),
                  trailing: Text(money(product.price)),
                );
              },
            ),
    );
  }
}

class NewSalePage extends StatefulWidget {
  final List<Product> products;
  final List<String> customers;
  final List<String> sellers;

  const NewSalePage({
    super.key,
    required this.products,
    required this.customers,
    required this.sellers,
  });

  @override
  State<NewSalePage> createState() => _NewSalePageState();
}

class _NewSalePageState extends State<NewSalePage> {
  String? customer;
  String? seller;
  String payment = 'Pix';
  final Map<Product, int> quantities = {};

  double get total => quantities.entries.fold(
        0,
        (sum, entry) => sum + entry.key.price * entry.value,
      );

  void finishSale() {
    final selected = quantities.entries.where((entry) => entry.value > 0).toList();

    if (customer == null || seller == null || selected.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Escolha cliente, vendedor e pelo menos um produto.')),
      );
      return;
    }

    for (final entry in selected) {
      if (entry.value > entry.key.stock) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Estoque insuficiente para ${entry.key.name}.')),
        );
        return;
      }
    }

    Navigator.pop(
      context,
      Sale(
        customer: customer!,
        seller: seller!,
        payment: payment,
        items: selected.map((e) => SaleLine(e.key, e.value)).toList(),
        total: total,
        date: DateTime.now(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Nova venda')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          DropdownButtonFormField<String>(
            value: customer,
            decoration: const InputDecoration(labelText: 'Cliente'),
            items: widget.customers.map((name) => DropdownMenuItem(value: name, child: Text(name))).toList(),
            onChanged: (value) => setState(() => customer = value),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            value: seller,
            decoration: const InputDecoration(labelText: 'Vendedor'),
            items: widget.sellers.map((name) => DropdownMenuItem(value: name, child: Text(name))).toList(),
            onChanged: (value) => setState(() => seller = value),
          ),
          const SizedBox(height: 20),
          const Text('Produtos', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ...widget.products.map((product) => Card(
                child: ListTile(
                  title: Text(product.name),
                  subtitle: Text('Estoque: ${product.stock} • R\$ ${product.price.toStringAsFixed(2)}'),
                  trailing: SizedBox(
                    width: 80,
                    child: TextFormField(
                      initialValue: '0',
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Qtd.'),
                      onChanged: (value) {
                        quantities[product] = int.tryParse(value) ?? 0;
                        setState(() {});
                      },
                    ),
                  ),
                ),
              )),
          DropdownButtonFormField<String>(
            value: payment,
            decoration: const InputDecoration(labelText: 'Forma de pagamento'),
            items: const ['Pix', 'Dinheiro', 'Cartão de crédito', 'Cartão de débito', 'Pendente']
                .map((value) => DropdownMenuItem(value: value, child: Text(value)))
                .toList(),
            onChanged: (value) {
              if (value != null) setState(() => payment = value);
            },
          ),
          const SizedBox(height: 16),
          Text('Total: R\$ ${total.toStringAsFixed(2)}',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          FilledButton(onPressed: finishSale, child: const Text('Concluir venda')),
        ],
      ),
    );
  }
}
