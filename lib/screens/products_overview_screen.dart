import 'package:flutter/material.dart';
import 'package:my_shop/providers/products_provider.dart';
import 'package:my_shop/screens/cart_screen.dart';
import 'package:my_shop/widgets/app_drawer.dart';
import 'package:my_shop/widgets/badge.dart';

import '../providers/cart.dart';
// import '../providers/product.dart';
import '../widgets/products_grid.dart';
import 'package:provider/provider.dart';

enum FilterProducts { Filter, All }

class ProductsOverviewScreen extends StatefulWidget {
  @override
  State<ProductsOverviewScreen> createState() => _ProductsOverviewScreenState();
}

class _ProductsOverviewScreenState extends State<ProductsOverviewScreen> {
  // final List<Product> presentproducts = [];
  var showFavorites = false;
  var _isInit = true;
  var isLoading = false;
  @override
  void initState() {
    //in initState all these methods or we can say properties with of context doesn't work
    //Here provider of context can work if listen==false

    //Two approaches to use when listen!=false
    //1  // Future.delayed(Duration.zero).then((_) {
    // Provider.of<ProductsProvider>(context).fetchAndSetProducts();
    // });

    super.initState();
  }

  @override
  void didChangeDependencies() {
    //2
    if (_isInit) {
      setState(() {
        isLoading = true;
      });
      
      Provider.of<ProductsProvider>(context).fetchAndSetProducts().then((_) {
        setState(() {
          isLoading = false;
        });
        
      });
    }
    _isInit = false;
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    final filterProducts =
        Provider.of<ProductsProvider>(context, listen: false);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).primaryColor,
        title: Text('My Shop'),
        actions: <Widget>[
          PopupMenuButton(
            onSelected: (FilterProducts valueChoosen) {
              setState(() {
                if (valueChoosen == FilterProducts.Filter) {
                  showFavorites = true;
                } else {
                  showFavorites = false;
                }
              });
            },
            itemBuilder: (c) => [
              PopupMenuItem(
                value: FilterProducts.Filter,
                child: Text('Only Favourites'),
              ),
              PopupMenuItem(
                value: FilterProducts.All,
                child: Text('Show All'),
              ),
            ],
            icon: Icon(Icons.more_vert),
          ),
          Consumer<Cart>(
            builder: (_, cartData, ch) => Badge(
              child: ch as Widget,
              value: cartData.itemCount.toString(),
              color: Theme.of(context).accentColor,
            ),
            child: IconButton(
              onPressed: () {
                Navigator.of(context).pushNamed(CartScreen.routeName);
              },
              icon: Icon(Icons.shopping_cart),
            ),
          )
        ],
      ),
      drawer: AppDrawer(),
      body: isLoading?  Center(child: CircularProgressIndicator(),) :  ProductsGrid(showFavorites),
    );
  }
}

//We are using Stateful approach so that our filtering logic to
//only the desired screen not when we move to other screens


