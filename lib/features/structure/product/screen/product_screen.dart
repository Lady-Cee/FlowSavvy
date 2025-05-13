import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../providers/product_provider.dart';
import 'package:url_launcher/url_launcher.dart';


// import '../../../models/product_model.dart';
// import '../../providers/product_provider.dart';

class ProductScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final products = Provider.of<ProductProvider>(context).products;

    return Scaffold(
      appBar: AppBar(title: Text('Recommended Products')),
      body: ListView.builder(
        itemCount: products.length,
        itemBuilder: (ctx, i) {
          final product = products[i];
          return Card(
            margin: EdgeInsets.all(10),
            child: ListTile(
              leading: Image.network(product.imageUrl, width: 60, fit: BoxFit.cover),
              title: Text(product.name),
              subtitle: Text(product.description),
              trailing: Icon(Icons.arrow_forward),

                onTap: () async {
                  final url = Uri.parse(product.link);

                  if (await launchUrl(url, mode: LaunchMode.inAppWebView)) {
                    // print("Launched in in-app view");
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Could not launch product link')),
                    );
                  }
                }
            ),
          );
        },
      ),
    );
  }
}
