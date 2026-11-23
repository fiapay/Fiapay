```dart
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
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF8E4465)),
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
      appBar: AppBar(title: const Text('FiaPay')),
      body: const Center(
        child: Text(
          'Controle sua loja de roupas\\n\\nProdutos • Clientes • Vendas • Fiado',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}
```
