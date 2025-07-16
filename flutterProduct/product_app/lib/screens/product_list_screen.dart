import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/product_provider.dart';
import '../utils/pdf_export.dart';
import 'add_product_screen.dart';
import 'edit_product_screen.dart';

class ProductListScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ProductProvider>(context);
    final products = provider.filteredProducts;

    return Scaffold(
      appBar: AppBar(
        title: Text("Product Management"),
        centerTitle: true,
        elevation: 2,
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) => provider.sortBy(value),
            itemBuilder: (_) => [
              PopupMenuItem(value: 'price', child: Text('Sort by Price')),
              PopupMenuItem(value: 'stock', child: Text('Sort by Stock')),
            ],
          ),
          IconButton(
            icon: Icon(Icons.picture_as_pdf),
            onPressed: () async {
              await exportToPdf(products);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('PDF exported successfully')),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: TextField(
              decoration: InputDecoration(
                labelText: 'Search by name...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onChanged: (value) => provider.search(value),
            ),
          ),
          Divider(height: 1),
          Expanded(
            child: NotificationListener<ScrollNotification>(
              onNotification: (scrollInfo) {
                if (scrollInfo.metrics.pixels >=
                    scrollInfo.metrics.maxScrollExtent - 50) {
                  provider.fetchMoreProducts();
                }
                return false;
              },
              child: RefreshIndicator(
                onRefresh: () => provider.fetchProducts(),
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  itemCount: products.length,
                  itemBuilder: (_, i) {
                    final product = products[i];
                    return Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 2,
                      margin: const EdgeInsets.symmetric(vertical: 6),
                      child: ListTile(
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
                        title: Text(
                          product.name,
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Padding(
                          padding: const EdgeInsets.only(top: 4.0),
                          child: Text(
                            "Price: \$${product.price}   •   Stock: ${product.stock}",
                            style: TextStyle(color: Colors.grey[700]),
                          ),
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: Icon(Icons.edit, color: Colors.blueAccent),
                              onPressed: () async {
                                await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => EditProductScreen(product),
                                  ),
                                );
                                await provider.fetchProducts();
                              },
                            ),
                            IconButton(
                              icon: Icon(Icons.delete, color: Colors.redAccent),
                              onPressed: () async {
                                final confirm = await showDialog<bool>(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    title: Text('Confirm Delete'),
                                    content: Text(
                                      'Are you sure you want to delete "${product.name}"?',
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () =>
                                            Navigator.pop(context, false),
                                        child: Text('Cancel'),
                                      ),
                                      TextButton(
                                        onPressed: () =>
                                            Navigator.pop(context, true),
                                        child: Text('Delete'),
                                      ),
                                    ],
                                  ),
                                );
                                if (confirm == true) {
                                  await provider.deleteProduct(product.id);
                                }
                              },
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        icon: Icon(Icons.add),
        label: Text("Add Product"),
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => AddProductScreen()),
          );
          await provider.fetchProducts();
        },
      ),
    );
  }
}
