import 'package:my_shop/providers/products_provider.dart';
import 'package:my_shop/widgets/product_item.dart';
import 'package:provider/provider.dart';
import '../providers/product.dart';
import 'package:flutter/material.dart';

class ProductsGrid extends StatelessWidget {
  final bool showFavs;
  ProductsGrid(this.showFavs);
  @override
  Widget build(BuildContext context) {
    final productsData = Provider.of<ProductsProvider>(context);
    final products = showFavs?  productsData.favourites : productsData.items;
    return GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 3 / 2,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10),
        padding: const EdgeInsets.all(10),
        itemCount: products.length,
        itemBuilder: (ctx, index) => ChangeNotifierProvider.value(
              value: products[index],
              // create: (ctx) => products[index],
              child: ProductItem(
                  // products[index].id,
                  // products[index].title,
                  // products[index].imageUrl)
                  ),
            ));
  }
}
//We can use a different method as well for listening to our changes.
//We can wrap our widget tree which is interested in listening to changes in a CONSUMER widget
