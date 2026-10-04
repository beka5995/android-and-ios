//lab5
import 'package:flutter/material.dart';

void main() => runApp(const MaterialApp(home: ProductScreen()));

class ProductScreen extends StatefulWidget {
  const ProductScreen({super.key});

  @override
  State<ProductScreen> createState() => _ProductScreenState();
}

class _ProductScreenState extends State<ProductScreen> {
  bool saved = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Product Details')),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                Container(
                  height: 250,
                  width: double.infinity,
                  color: Colors.grey[300],
                  child: Image.network(
                    'https://images.unsplash.com/photo-1542291026-7eec264c27ff',
                    fit: BoxFit.cover,
                  ),
                ),

                Positioned(
                  top: 10,
                  right: 10,
                  child: IconButton(
                    onPressed: () {
                      setState(() {
                        saved = !saved;
                      });
                    },
                    icon: Icon(
                      saved ? Icons.bookmark : Icons.bookmark_border,
                      color: Colors.black,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            const Row(
              children: [
                Expanded(
                  child: Text(
                    'Nike Air Max',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Text(
                  '\$150',
                  style: TextStyle(fontSize: 20),
                ),
              ],
            ),

            const SizedBox(height: 10),

            const Row(
              children: [
                Icon(Icons.star, color: Colors.amber),
                Text(' 4.8'),
              ],
            ),

            const SizedBox(height: 15),

            const Wrap(
              spacing: 10,
              children: [
                Chip(label: Text('Nike')),
                Chip(label: Text('Shoes')),
                Chip(label: Text('Sport')),
              ],
            ),
          ],
        ),
      ),

      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Added to cart'),
                      ),
                    );
                  },
                  child: const Text('Add to Cart'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}