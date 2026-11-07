import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const LiveApiApp());
}

class LiveApiApp extends StatelessWidget {
  const LiveApiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Week 10: RESTful API & Deep Links',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF02569B)),
      ),
      home: const ProductExplorerScreen(),
    );
  }
}

// ============================================================================
// 1. DATA MODEL & JSON DESERIALIZATION (МОДЕЛЬ ТОВАРА)
// ============================================================================
class Product {
  final int id;
  final String title;
  final double price;
  final String description;
  final String category;
  final String imageUrl;
  final double rating;
  final int reviewCount;

  const Product({
    required this.id,
    required this.title,
    required this.price,
    required this.description,
    required this.category,
    required this.imageUrl,
    required this.rating,
    required this.reviewCount,
  });

  // Галерея ракурсов для карусели
  List<String> get galleryImages => [imageUrl, imageUrl, imageUrl];

  // 🔗 ГЕНЕРАЦИЯ ДИПЛИНКА ТОВАРА ДЛЯ SHARE
  String get deepLink => 'narxoz://store/product/$id';
  String get webLink => 'https://store.narxoz.kz/products/$id';

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] as int,
      title: json['title'] as String? ?? 'No title',
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      description: json['description'] as String? ?? 'No description provided.',
      category: json['category'] as String? ?? 'General',
      imageUrl: json['image'] as String? ?? '',
      rating: (json['rating']?['rate'] as num?)?.toDouble() ?? 0.0,
      reviewCount: (json['rating']?['count'] as num?)?.toInt() ?? 0,
    );
  }
}

// ============================================================================
// 2. MAIN SCREEN: СПИСОК ТОВАРОВ + DEEP LINK СИМУЛЯТОР
// ============================================================================
class ProductExplorerScreen extends StatefulWidget {
  const ProductExplorerScreen({super.key});

  @override
  State<ProductExplorerScreen> createState() => _ProductExplorerScreenState();
}

class _ProductExplorerScreenState extends State<ProductExplorerScreen> {
  List<Product> _products = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchProducts();
  }

  Future<void> _fetchProducts() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final url = Uri.parse('https://fakestoreapi.com/products');

    try {
      final response = await http.get(url).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final List<dynamic> jsonList = jsonDecode(response.body);
        final List<Product> loaded = jsonList
            .map((item) => Product.fromJson(item as Map<String, dynamic>))
            .toList();

        setState(() {
          _products = loaded;
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = 'Server error: ${response.statusCode}';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to connect. Check internet connection.\n($e)';
        _isLoading = false;
      });
    }
  }

  // ==========================================================================
  // 🚀 DEEP LINK HANDLER: ПЕРЕХОД ПО ССЫЛКЕ НАПРЯМУЮ К ТОВАРУ
  // ==========================================================================
  void _openDeepLink(String rawUri) {
    // Парсим URI: narxoz://store/product/5 или https://store.narxoz.kz/products/5
    final uri = Uri.tryParse(rawUri);
    if (uri == null) return;

    final idString = uri.pathSegments.isNotEmpty ? uri.pathSegments.last : null;
    final productId = int.tryParse(idString ?? '');

    if (productId != null) {
      final found = _products.where((p) => p.id == productId).toList();
      if (found.isNotEmpty) {
        // Открываем товар напрямую через диплинк!
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => ProductDetailScreen(product: found.first)),
        );
        return;
      }
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('⚠️ Product with Link "$rawUri" not found!')),
    );
  }

  // Диалоговое окно для симуляции клика по диплинку
  void _showDeepLinkSimulatorDialog() {
    final controller = TextEditingController(text: 'narxoz://store/product/3');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.link, color: Colors.blueAccent),
            SizedBox(width: 8),
            Text('Simulate Deep Link'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Enter a Deep Link (as if clicked in Telegram/WhatsApp):',
              style: TextStyle(fontSize: 13, color: Colors.grey),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: controller,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.open_in_browser),
                labelText: 'Deep Link URL',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              _openDeepLink(controller.text.trim());
            },
            child: const Text('Open Link 🚀'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Live REST API Store', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.blueAccent,
        foregroundColor: Colors.white,
        actions: [
          // Кнопка для живой демонстрации перехода по диплинку на лекции!
          IconButton(
            icon: const Icon(Icons.link),
            tooltip: 'Simulate Deep Link',
            onPressed: _showDeepLinkSimulatorDialog,
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Reload API',
            onPressed: _fetchProducts,
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Fetching live data from cloud API...', style: TextStyle(color: Colors.grey)),
          ],
        ),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.wifi_off_rounded, size: 72, color: Colors.redAccent),
              const SizedBox(height: 16),
              const Text(
                'Network Connection Error',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                _errorMessage!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.grey, fontSize: 13),
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  foregroundColor: Colors.white,
                ),
                onPressed: _fetchProducts,
                icon: const Icon(Icons.refresh),
                label: const Text('Retry Connection'),
              ),
            ],
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _fetchProducts,
      child: ListView.separated(
        padding: const EdgeInsets.all(12),
        itemCount: _products.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final product = _products[index];
          return Card(
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => ProductDetailScreen(product: product)),
                );
              },
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Hero(
                      tag: 'product_image_${product.id}',
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          width: 90,
                          height: 90,
                          color: Colors.white,
                          padding: const EdgeInsets.all(4),
                          child: Image.network(
                            product.imageUrl,
                            fit: BoxFit.contain,
                            loadingBuilder: (context, child, progress) =>
                            progress == null ? child : const Center(child: CircularProgressIndicator(strokeWidth: 2)),
                            errorBuilder: (_, __, ___) => const Icon(Icons.broken_image, size: 40, color: Colors.grey),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: Colors.blue.shade50,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              product.category.toUpperCase(),
                              style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.blueAccent),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            product.title,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                          ),
                          const SizedBox(height: 6),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '\$${product.price.toStringAsFixed(2)}',
                                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Color(0xFF02569B)),
                              ),
                              Row(
                                children: [
                                  const Icon(Icons.star, size: 16, color: Colors.amber),
                                  const SizedBox(width: 2),
                                  Text('${product.rating}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                                  const SizedBox(width: 4),
                                  const Icon(Icons.arrow_forward_ios, size: 12, color: Colors.grey),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

// ============================================================================
// 3. PRODUCT DETAIL SCREEN С КАРУСЕЛЬЮ И НАСТОЯЩИМ SHARE SHEET
// ============================================================================
class ProductDetailScreen extends StatefulWidget {
  final Product product;

  const ProductDetailScreen({super.key, required this.product});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  final PageController _pageController = PageController();
  int _currentImageIndex = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  // ==========================================================================
  // 📲 ИНТЕРАКТИВНЫЙ SHARE SHEET С ДИПЛИНКОМ И КНОПКАМИ МЕССЕНДЖЕРОВ
  // ==========================================================================
  void _openShareModal(Product product) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Полоска-держатель
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2)),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Share Product via Deep Link',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 6),
              Text(
                'Friends clicking this link will open this exact product screen!',
                style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
              ),
              const SizedBox(height: 16),

              // Карточка с диплинком и кнопкой копирования
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.link, color: Colors.blueAccent),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        product.deepLink,
                        style: const TextStyle(fontFamily: 'Courier', fontSize: 13, fontWeight: FontWeight.bold),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.copy, size: 20),
                      tooltip: 'Copy Deep Link',
                      onPressed: () {
                        Clipboard.setData(ClipboardData(text: product.deepLink));
                        Navigator.pop(ctx);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('📋 Deep Link copied to clipboard!'),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Кнопки соцсетей и мессенджеров
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildShareOption(
                    icon: Icons.send,
                    label: 'Telegram',
                    color: Colors.blue,
                    onTap: () => _simulateSend(ctx, 'Telegram', product),
                  ),
                  _buildShareOption(
                    icon: Icons.chat_bubble_outline,
                    label: 'WhatsApp',
                    color: Colors.green,
                    onTap: () => _simulateSend(ctx, 'WhatsApp', product),
                  ),
                  _buildShareOption(
                    icon: Icons.qr_code,
                    label: 'QR Code',
                    color: Colors.purple,
                    onTap: () => _simulateSend(ctx, 'QR Code', product),
                  ),
                  _buildShareOption(
                    icon: Icons.more_horiz,
                    label: 'More',
                    color: Colors.grey.shade700,
                    onTap: () => _simulateSend(ctx, 'System Share Sheet', product),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildShareOption({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        child: Column(
          children: [
            CircleAvatar(
              radius: 24,
              backgroundColor: color.withOpacity(0.12),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(height: 6),
            Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }

  void _simulateSend(BuildContext modalContext, String channel, Product product) {
    Navigator.pop(modalContext);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('🚀 Sent via $channel:\n"${product.deepLink}"'),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final product = widget.product;
    final images = product.galleryImages;

    return Scaffold(
      appBar: AppBar(
        title: Text(product.category.toUpperCase(), style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.blueAccent,
        foregroundColor: Colors.white,
        actions: [
          // 📢 КНОПКА SHARE: ВЫЗЫВАЕТ ОКНО ШЕЙРИНГА С ДИПЛИНКОМ
          IconButton(
            icon: const Icon(Icons.share),
            tooltip: 'Share Deep Link',
            onPressed: () => _openShareModal(product),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Карусель фотографий
            Container(
              color: Colors.white,
              child: Column(
                children: [
                  SizedBox(
                    height: 280,
                    child: Stack(
                      children: [
                        PageView.builder(
                          controller: _pageController,
                          itemCount: images.length,
                          onPageChanged: (idx) => setState(() => _currentImageIndex = idx),
                          itemBuilder: (context, index) {
                            final imgWidget = Padding(
                              padding: const EdgeInsets.all(24.0),
                              child: Image.network(images[index], fit: BoxFit.contain),
                            );
                            if (index == 0) {
                              return Hero(tag: 'product_image_${product.id}', child: imgWidget);
                            }
                            return imgWidget;
                          },
                        ),
                        Positioned(
                          top: 12,
                          right: 12,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.6),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              '${_currentImageIndex + 1} / ${images.length}',
                              style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      images.length,
                          (index) => AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 12),
                        height: 8,
                        width: _currentImageIndex == index ? 24 : 8,
                        decoration: BoxDecoration(
                          color: _currentImageIndex == index ? const Color(0xFF02569B) : Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Данные товара
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade50,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          product.category.toUpperCase(),
                          style: const TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.bold, fontSize: 12),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.amber.shade50,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.star, color: Colors.amber, size: 16),
                            const SizedBox(width: 4),
                            Text(
                              '${product.rating} (${product.reviewCount} reviews)',
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    product.title,
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, letterSpacing: -0.5),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    '\$${product.price.toStringAsFixed(2)}',
                    style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: Color(0xFF02569B)),
                  ),
                  const SizedBox(height: 20),
                  const Divider(),
                  const SizedBox(height: 12),
                  const Text('Product Description', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text(
                    product.description,
                    style: TextStyle(fontSize: 15, color: Colors.grey.shade700, height: 1.5),
                  ),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 10,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: SafeArea(
          child: Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF02569B),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Added "${product.title}" to cart! 🛒'), behavior: SnackBarBehavior.floating),
                    );
                  },
                  icon: const Icon(Icons.add_shopping_cart),
                  label: const Text('Add to Cart', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
