import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/product.dart';
import '../providers/product_provider.dart';

class AddProductScreen extends StatefulWidget {
  @override
  _AddProductScreenState createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final _formKey = GlobalKey<FormState>();
  String name = "";
  double price = 0;
  int stock = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Add Product")),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                decoration: InputDecoration(labelText: "Name"),
                onSaved: (v) => name = v!,
                validator: (v) => v!.isEmpty ? "Required" : null,
              ),
              TextFormField(
                decoration: InputDecoration(labelText: "Price"),
                keyboardType: TextInputType.number,
                onSaved: (v) => price = double.parse(v!),
                validator: (v) =>
                    double.tryParse(v!) == null ? "Invalid" : null,
              ),
              TextFormField(
                decoration: InputDecoration(labelText: "Stock"),
                keyboardType: TextInputType.number,
                onSaved: (v) => stock = int.parse(v!),
                validator: (v) => int.tryParse(v!) == null ? "Invalid" : null,
              ),
              SizedBox(height: 20),
              ElevatedButton(
                child: Text("Add"),
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    _formKey.currentState!.save();
                    Provider.of<ProductProvider>(
                      context,
                      listen: false,
                    ).addProduct(
                      Product(id: 0, name: name, price: price, stock: stock),
                    );
                    Navigator.pop(context);
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
