import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/product.dart';
import '../providers/product_provider.dart';

class EditProductScreen extends StatefulWidget {
  final Product product;
  const EditProductScreen(this.product, {Key? key}) : super(key: key);

  @override
  _EditProductScreenState createState() => _EditProductScreenState();
}

class _EditProductScreenState extends State<EditProductScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _priceController;
  late TextEditingController _stockController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.product.name);
    _priceController = TextEditingController(
      text: widget.product.price.toString(),
    );
    _stockController = TextEditingController(
      text: widget.product.stock.toString(),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _stockController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Edit Product")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: "Name"),
                validator: (v) => v!.isEmpty ? "Required" : null,
              ),
              TextFormField(
                controller: _priceController,
                decoration: const InputDecoration(labelText: "Price"),
                keyboardType: TextInputType.number,
                validator: (v) {
                  if (v!.isEmpty) return "Required";
                  if (double.tryParse(v) == null) return "Invalid number";
                  return null;
                },
              ),
              TextFormField(
                controller: _stockController,
                decoration: const InputDecoration(labelText: "Stock"),
                keyboardType: TextInputType.number,
                validator: (v) {
                  if (v!.isEmpty) return "Required";
                  if (int.tryParse(v) == null) return "Invalid number";
                  return null;
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                child: const Text("Save"),
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    try {
                      final updatedProduct = Product(
                        id: widget.product.id,
                        name: _nameController.text,
                        price: double.parse(_priceController.text),
                        stock: int.parse(_stockController.text),
                      );

                      await Provider.of<ProductProvider>(
                        context,
                        listen: false,
                      ).updateProduct(updatedProduct);

                      if (mounted) Navigator.pop(context);
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Failed to update: $e'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
