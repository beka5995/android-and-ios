import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(
    // ШАГ 1: Вешаем "склад" на самый верх приложения
    ChangeNotifierProvider(
      create: (context) => CartProvider(),
      child: const MaterialApp(
        debugShowCheckedModeBanner: false,
        home: CatalogScreen(),
      ),
    ),
  );
}

// ==========================================
// 1. НАШ "СКЛАД" (STATE / DATA STORE)
// ==========================================
class CartProvider extends ChangeNotifier {
  final List<String> _cartItems = [];

  List<String> get items => _cartItems;
  int get count => _cartItems.length;

  void toggleItem(String itemName) {
    if (_cartItems.contains(itemName)) {
      _cartItems.remove(itemName);
    } else {
      _cartItems.add(itemName);
    }
    // 📢 САМАЯ ВАЖНАЯ СТРОЧКА: кричим в рацию всем подписчикам!
    notifyListeners();
  }
}

// ==========================================
// 2. ЭКРАН 1: КАТАЛОГ МАГАЗИНА
// ==========================================
class CatalogScreen extends StatelessWidget {
  const CatalogScreen({super.key});

  final List<String> products = const [
    'iPhone 16 Pro',
    'MacBook Air M3',
    'AirPods Pro 2',
    'Apple Watch Ultra',
  ];

  @override
  Widget build(BuildContext context) {
    // 👀 ГЛАЗА 1: AppBar смотрит на количество товаров через context.watch
    final cartCount = context.watch<CartProvider>().count;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Kaspi / Wolt Store'),
        backgroundColor: Colors.blueAccent,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: Badge(
              label: Text('$cartCount'),
              isLabelVisible: cartCount > 0,
              child: const Icon(Icons.shopping_cart, size: 28),
            ),
            onPressed: () {
              // Переход на экран корзины (НОЛЬ параметров передано!)
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const CartScreen()),
              );
            },
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: products.length,
        itemBuilder: (context, index) {
          final item = products[index];
          // 👀 ГЛАЗА 2: каждая строка следит, лежит ли данный товар в корзине
          final inCart = context.watch<CartProvider>().items.contains(item);

          return ListTile(
            leading: Icon(
              Icons.phone_iphone,
              color: inCart ? Colors.green : Colors.grey,
            ),
            title: Text(item, style: const TextStyle(fontWeight: FontWeight.bold)),
            trailing: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: inCart ? Colors.red.shade100 : Colors.blue.shade50,
                foregroundColor: inCart ? Colors.red : Colors.blue,
              ),
              onPressed: () {
                // ⚡ ДЕЙСТВИЕ: context.read (нажали и сообщили на склад)
                context.read<CartProvider>().toggleItem(item);
              },
              child: Text(inCart ? 'Убрать ✕' : 'Купить +'),
            ),
          );
        },
      ),
    );
  }
}

// ==========================================
// 3. ЭКРАН 2: ЭКРАН КОРЗИНЫ
// ==========================================
class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // 👀 Корзина целиком читает данные со склада через context.watch
    final cart = context.watch<CartProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Моя Корзина'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),
      body: cart.items.isEmpty
          ? const Center(
        child: Text('Корзина пустая 🛒', style: TextStyle(fontSize: 20)),
      )
          : ListView.builder(
        itemCount: cart.items.length,
        itemBuilder: (context, index) {
          final item = cart.items[index];
          return ListTile(
            leading: const Icon(Icons.check_circle, color: Colors.green),
            title: Text(item),
            trailing: IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () {
                context.read<CartProvider>().toggleItem(item);
              },
            ),
          );
        },
      ),
    );
  }
}
