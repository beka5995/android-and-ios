import 'package:flutter/material.dart';

void main() {
  runApp(const Lab8App());
}

class Lab8App extends StatelessWidget {
  const Lab8App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Smart Catalog - Lab 8',
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: const Color(0xFF6059E8),
        scaffoldBackgroundColor: const Color(0xFFF7F8FC),
      ),
      home: const CatalogScreen(),
    );
  }
}

class Product {
  final int id;
  final String title;
  final String category;
  final double rating;
  final double price;
  final IconData icon;
  final Color color;
  final int photoIndex;

  const Product({
    required this.id,
    required this.title,
    required this.category,
    required this.rating,
    required this.price,
    required this.icon,
    required this.color,
    required this.photoIndex,
  });

  static List<Product> seedData() => [
    const Product(
      id: 1,
      photoIndex: 0,
      title: 'Wireless Headphones',
      category: 'Electronics',
      rating: 4.8,
      price: 24990,
      icon: Icons.headphones_rounded,
      color: Color(0xFF6D5DF6),
    ),
    const Product(
      id: 2,
      photoIndex: 1,
      title: 'Running Sneakers',
      category: 'Fashion',
      rating: 4.7,
      price: 39990,
      icon: Icons.directions_run_rounded,
      color: Color(0xFF0B9C87),
    ),
    const Product(
      id: 3,
      photoIndex: 2,
      title: 'Smart Watch',
      category: 'Electronics',
      rating: 4.9,
      price: 54990,
      icon: Icons.watch_rounded,
      color: Color(0xFFE77B31),
    ),
    const Product(
      id: 4,
      photoIndex: 3,
      title: 'Travel Backpack',
      category: 'Accessories',
      rating: 4.6,
      price: 18990,
      icon: Icons.backpack_rounded,
      color: Color(0xFF2678C8),
    ),
    const Product(
      id: 5,
      photoIndex: 4,
      title: 'Bluetooth Speaker',
      category: 'Electronics',
      rating: 4.5,
      price: 15990,
      icon: Icons.speaker_rounded,
      color: Color(0xFFD14E82),
    ),
    const Product(
      id: 6,
      photoIndex: 5,
      title: 'Sunglasses',
      category: 'Fashion',
      rating: 4.4,
      price: 9990,
      icon: Icons.wb_sunny_rounded,
      color: Color(0xFFCA9223),
    ),
    const Product(
      id: 7,
      photoIndex: 6,
      title: 'Laptop',
      category: 'Electronics',
      rating: 4.9,
      price: 329990,
      icon: Icons.laptop_mac_rounded,
      color: Color(0xFF4863A9),
    ),
    const Product(
      id: 8,
      photoIndex: 7,
      title: 'Coffee Mug',
      category: 'Home',
      rating: 4.6,
      price: 4990,
      icon: Icons.coffee_rounded,
      color: Color(0xFF98715D),
    ),
  ];
}

String formatPrice(double price) {
  final digits = price.toStringAsFixed(0);
  return '${digits.replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (m) => ' ')} ₸';
}

class CatalogScreen extends StatefulWidget {
  const CatalogScreen({super.key});

  @override
  State<CatalogScreen> createState() => _CatalogScreenState();
}

class _CatalogScreenState extends State<CatalogScreen> {
  List<Product> _products = Product.seedData();
  bool _isGridView = false;
  int _nextId = 100;
  int _newProductNumber = 0;

  Future<void> _refreshProducts() async {
    await Future.delayed(const Duration(milliseconds: 1500));
    if (!mounted) return;

    final newId = _nextId++;
    _newProductNumber++;

    final sample = Product.seedData()[(_newProductNumber - 1) % 8];
    final newProduct = Product(
      id: newId,
      title: 'New ${sample.title}',
      category: 'New Arrival',
      rating: sample.rating,
      price: sample.price,
      icon: sample.icon,
      color: sample.color,
      photoIndex: sample.photoIndex,
    );

    setState(() {
      _products.insert(0, newProduct);
    });
  }

  void _deleteProduct(Product product) {
    final originalIndex = _products.indexWhere((p) => p.id == product.id);
    if (originalIndex == -1) return;

    setState(() {
      _products.removeAt(originalIndex);
    });

    final messenger = ScaffoldMessenger.of(context);
    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 5),
        content: Text('${product.title} removed'),
        action: SnackBarAction(
          label: 'UNDO',
          onPressed: () {
            if (!mounted || _products.any((p) => p.id == product.id)) {
              return;
            }
            final insertIndex = originalIndex <= _products.length
                ? originalIndex
                : _products.length;
            setState(() {
              _products.insert(insertIndex, product);
            });
          },
        ),
      ),
    );
  }

  void _resetCatalog() {
    setState(() {
      _products = Product.seedData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Smart Catalog',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFFF7F8FC),
        actions: [
          IconButton(
            tooltip: _isGridView ? 'Switch to List View' : 'Switch to Grid View',
            onPressed: () {
              setState(() {
                _isGridView = !_isGridView;
              });
            },
            icon: Icon(
              _isGridView ? Icons.view_list_rounded : Icons.grid_view_rounded,
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${_products.length} products',
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 20,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _isGridView
                      ? 'Pull down to load a new product'
                      : 'Pull down to refresh • Swipe left to delete',
                  style: TextStyle(color: Colors.grey.shade700, fontSize: 13),
                ),
              ],
            ),
          ),
          Expanded(
            child: _products.isEmpty
                ? _buildEmptyState()
                : _isGridView
                ? _buildGridView()
                : _buildListView(),
          ),
        ],
      ),
    );
  }

  Widget _buildListView() {
    return RefreshIndicator(
      onRefresh: _refreshProducts,
      child: ListView.separated(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        itemCount: _products.length,
        separatorBuilder: (context, index) => const Divider(
          height: 12,
          thickness: 0.7,
          indent: 12,
          endIndent: 12,
        ),
        itemBuilder: (context, index) {
          final product = _products[index];
          return Dismissible(
            key: ValueKey(product.id),
            direction: DismissDirection.endToStart,
            background: Container(
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.only(right: 22),
              decoration: BoxDecoration(
                color: Colors.red.shade600,
                borderRadius: BorderRadius.circular(15),
              ),
              child: const Icon(
                Icons.delete,
                color: Colors.white,
                size: 30,
              ),
            ),
            onDismissed: (direction) => _deleteProduct(product),
            child: ProductListTile(product: product),
          );
        },
      ),
    );
  }

  Widget _buildGridView() {
    return RefreshIndicator(
      onRefresh: _refreshProducts,
      child: GridView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 0.72,
        ),
        itemCount: _products.length,
        itemBuilder: (context, index) {
          return ProductGridCard(product: _products[index]);
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return LayoutBuilder(
      builder: (context, constraints) {
        return RefreshIndicator(
          onRefresh: _refreshProducts,
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            children: [
              SizedBox(
                height: constraints.maxHeight,
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.inventory_2_outlined,
                          size: 72,
                          color: Colors.grey.shade500,
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Catalog is Empty',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'You removed all products. Restore the catalog to start again.',
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 20),
                        FilledButton.icon(
                          onPressed: _resetCatalog,
                          icon: const Icon(Icons.restart_alt_rounded),
                          label: const Text('Reset Catalog'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}


const List<String> _productImageUrls = [
  'https://images.unsplash.com/photo-1505740420928-5e560c06d30e?w=500', // Headphones
  'https://images.unsplash.com/photo-1542291026-7eec264c27ff?w=500', // Sneakers
  'https://images.unsplash.com/photo-1523275335684-37898b6baf30?w=500', // Watch
  'https://images.unsplash.com/photo-1553062407-98eeb64c6a62?w=500', // Backpack
  'https://images.unsplash.com/photo-1608043152269-423dbba4e7e1?w=500', // Speaker
  'https://images.unsplash.com/photo-1511499767150-a48a237f0083?w=500', // Sunglasses
  'https://images.unsplash.com/photo-1496181133206-80ce9b88a853?w=500', // Laptop
  'https://images.unsplash.com/photo-1514228742587-6b1558fcca3d?w=500', // Mug
];

class ProductPhoto extends StatelessWidget {
  final Product product;

  const ProductPhoto({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    return Image.network(
      _productImageUrls[product.photoIndex],
      width: double.infinity,
      height: double.infinity,
      fit: BoxFit.cover,
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return ColoredBox(
          color: product.color.withAlpha(18),
          child: const Center(
            child: SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          ),
        );
      },
      errorBuilder: (context, error, stackTrace) => ColoredBox(
        color: product.color.withAlpha(25),
        child: Center(
          child: Icon(product.icon, color: product.color, size: 32),
        ),
      ),
    );
  }
}

class ProductListTile extends StatelessWidget {
  final Product product;

  const ProductListTile({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(13),
            child: SizedBox(
              width: 60,
              height: 60,
              child: ProductPhoto(product: product),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 7,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF0EEFF),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        product.category,
                        style: const TextStyle(
                          fontSize: 10,
                          color: Color(0xFF6059E8),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.star_rounded,
                          size: 15,
                          color: Color(0xFFF4B400),
                        ),
                        const SizedBox(width: 2),
                        Text(
                          product.rating.toStringAsFixed(1),
                          style: const TextStyle(fontSize: 12),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            formatPrice(product.price),
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class ProductGridCard extends StatelessWidget {
  final Product product;

  const ProductGridCard({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      elevation: 1,
      color: Colors.white,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: ProductPhoto(product: product),
          ),
          Padding(
            padding: const EdgeInsets.all(9),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  product.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        product.category,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 11,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                    const Icon(
                      Icons.star_rounded,
                      color: Color(0xFFF4B400),
                      size: 15,
                    ),
                    Text(
                      product.rating.toStringAsFixed(1),
                      style: const TextStyle(fontSize: 11),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  formatPrice(product.price),
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}