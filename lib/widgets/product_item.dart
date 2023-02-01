import 'package:flutter/material.dart';
import 'package:my_shop/screens/product_detail_screen.dart';
import 'package:provider/provider.dart';

import '../providers/auth.dart';
import '../providers/cart.dart';
import '../providers/product.dart';

class ProductItem extends StatelessWidget {
  // final String id;
  // final String title;
  // final String imageUrl;
  // const ProductItem(this.id, this.title, this.imageUrl);

  @override
  Widget build(BuildContext context) {
    final product = Provider.of<Product>(context, listen: false);
    final cart = Provider.of<Cart>(context, listen: false);
    final authData = Provider.of<Auth>(context,listen: false);
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: GridTile(
        child: GestureDetector(
          onTap: () {
            Navigator.of(context).pushNamed(
                arguments: product.id, ProductDetailScreen.routeName);
          },

          //Hero animation is used between two screens with a unique tag same for both screens
          child: Hero(
            tag: product.id,
            child: FadeInImage(
              placeholder: AssetImage('assets/images/product-placeholder.png'),
              image: NetworkImage(product.imageUrl),
              fit: BoxFit.cover,
            ),
          ),
        ),
        footer: GridTileBar(
          trailing: IconButton(
            color: Theme.of(context).accentColor,
            onPressed: () {
              cart.addItem(product.id, product.price, product.title);
              ScaffoldMessenger.of(context).hideCurrentSnackBar();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  duration: Duration(seconds: 3),
                  content: Text(
                    'Added item to cart',
                  ),
                  action: SnackBarAction(
                      label: 'UNDO',
                      onPressed: () {
                        cart.removeSingleItem(product.id);
                      }),
                ),
              );
            },
            icon: Icon(Icons.shopping_cart),
          ),
          leading: Consumer<Product>(
            builder: (ctx, product, _) => IconButton(
              color: Theme.of(context).accentColor,
              onPressed: () {
                product.togglefav(authData.token, authData.userId);
              },
              icon: Icon(
                  product.isFavorite ? Icons.favorite : Icons.favorite_border),
            ),
          ),
          title: Text(product.title),
          backgroundColor: Colors.black87,
        ),
      ),
    );
  }
}

//We can use a different method as well for listening to our changes.
//We can wrap our widget tree which is interested in listening to changes in a CONSUMER widget

//If we use the provider of for listening then the whole builder will run 
//but if we want to run a subpart of a widget tree if the dta changes then we cn use the consumer 

//Here we can use another apporach as well by using the provier.of approach with listen as false 
// And then we can use Consumer in the iconButton 