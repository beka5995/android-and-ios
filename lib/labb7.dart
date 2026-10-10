import 'package:flutter/material.dart';

void main() => runApp(MaterialApp(
  debugShowCheckedModeBanner: false,
  home: Home(),
));

class Home extends StatefulWidget {
  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  int tab = 0;
  List<int> favorites = [];

  final items = [
    {'title': 'Laptop', 'description': 'Powerful laptop for study',
      'image': 'https://picsum.photos/seed/phone/300',
      'price': '\$800', 'category': 'Electronics'},
    {'title': 'Phone', 'description': 'Modern smartphone',
      'image': 'https://cdn.new-brz.net/app/public/models/MPV03SX-A/large/w/230309170022057511.webp',
      'price': '\$500', 'category': 'Electronics'},
    {'title': 'Headphones', 'description': 'Wireless headphones',
      'image': 'https://m.media-amazon.com/images/I/61RahTQtAqL.jpg',
      'price': '\$100', 'category': 'Accessories'},
  ];

  Widget itemTile(int i) => ListTile(
    leading: Image.network(items[i]['image']!, width: 60,
        errorBuilder: (_, __, ___) => Icon(Icons.image)),
    title: Text(items[i]['title']!),
    subtitle: Text(items[i]['price']!),
    onTap: () => Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => Detail(item: items[i])),
    ),
    trailing: IconButton(
      icon: Icon(favorites.contains(i)
          ? Icons.favorite : Icons.favorite_border),
      onPressed: () => setState(() {
        favorites.contains(i) ? favorites.remove(i) : favorites.add(i);
      }),
    ),
  );

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text(['Feed', 'Favorites', 'Profile'][tab])),
    body: tab == 2
        ? Center(child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.person, size: 70),
        Text('Student Profile'),
        Text('Role: Student'),
      ],
    ))
        : ListView(
      children: List.generate(items.length, (i) =>
      (tab == 0 || favorites.contains(i))
          ? itemTile(i) : SizedBox.shrink()),
    ),
    bottomNavigationBar: BottomNavigationBar(
      currentIndex: tab,
      onTap: (i) => setState(() => tab = i),
      items: [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Feed'),
        BottomNavigationBarItem(icon: Icon(Icons.favorite), label: 'Favorites'),
        BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
      ],
    ),
  );
}

class Detail extends StatelessWidget {
  final Map<String, String> item;
  Detail({required this.item});

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text(item['title']!)),
    body: Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.network(item['image']!, width: 200,
              errorBuilder: (_, __, ___) => Icon(Icons.image, size: 100)),
          Text(item['title']!, style: TextStyle(fontSize: 24)),
          Text(item['description']!),
          Text('Price: ${item['price']}'),
          Text('Category: ${item['category']}'),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Back'),
          ),
        ],
      ),
    ),
  );
}