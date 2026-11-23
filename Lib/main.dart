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

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'FiaPay',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
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
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text('Vendas de hoje'),
                  SizedBox(height: 8),
                  Text(
                    'R\$ 0,00',
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text('Nenhuma venda registrada ainda'),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Acesso rápido',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          _menuButton(
            context,
            icon: Icons.inventory_2_outlined,
            label: 'Produtos',
          ),
          _menuButton(
            context,
            icon: Icons.point_of_sale,
            label: 'Vendas',
          ),
          _menuButton(
            context,
            icon: Icons.people_outline,
            label: 'Clientes',
          ),
        ],
      ),
    );
  }

  Widget _menuButton(
    BuildContext context, {
    required IconData icon,
    required String label,
  }) {
    return Card(
      child: ListTile(
        leading: Icon(icon, color: const Color(0xFF8E44AD)),
        title: Text(label),
        trailing: const Icon(Icons.chevron_right),
        onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('A área "$label" será criada em seguida.')),
          );
        },
      ),
    );
  }
