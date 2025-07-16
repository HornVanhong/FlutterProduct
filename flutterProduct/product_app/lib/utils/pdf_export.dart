import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';

import '../models/product.dart';

Future<void> exportToPdf(List<Product> products) async {
  final PdfDocument document = PdfDocument();
  final page = document.pages.add();
  PdfGrid grid = PdfGrid();
  grid.columns.add(count: 3);
  grid.headers.add(1);
  grid.headers[0].cells[0].value = 'Name';
  grid.headers[0].cells[1].value = 'Price';
  grid.headers[0].cells[2].value = 'Stock';

  for (var product in products) {
    final row = grid.rows.add();
    row.cells[0].value = product.name;
    row.cells[1].value = product.price.toString();
    row.cells[2].value = product.stock.toString();
  }

  grid.draw(page: page, bounds: Rect.zero);
  final List<int> bytes = await document.save();
  document.dispose();

  Directory? dir;
  if (Platform.isAndroid) {
    if (await Permission.storage.request().isGranted) {
      dir = await getExternalStorageDirectory();
    }
  } else {
    dir = await getApplicationDocumentsDirectory();
  }

  if (dir != null) {
    final file = File('${dir.path}/products.pdf');
    await file.writeAsBytes(bytes, flush: true);
  }
}
