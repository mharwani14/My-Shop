import 'package:flutter/material.dart';
import 'package:my_shop/helpers/custom_route.dart';
import 'package:my_shop/providers/auth.dart';
import 'package:my_shop/providers/cart.dart';
import 'package:my_shop/providers/orders.dart';
import 'package:my_shop/screens/auth_screen.dart';
import 'package:my_shop/screens/cart_screen.dart';
import 'package:my_shop/screens/edit_product_screen.dart';
import 'package:my_shop/screens/my_auth_screen.dart';
import 'package:my_shop/screens/orders_screen.dart';
import 'package:my_shop/screens/product_detail_screen.dart';
import 'package:my_shop/screens/products_overview_screen.dart';
import 'package:my_shop/screens/user_products_Screen.dart';
import 'package:my_shop/widgets/splash_screen.dart';
import './providers/products_provider.dart';
import 'package:provider/provider.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      //we can also use changeNotifer.value here as well as in the product  grid too if our value doesnt depend on the context
      providers: [
        ChangeNotifierProvider(
          create: (ctx) => Auth(),
        ),

        //here we are using changeNotifierProxyprovider to send that token from auth to products

        ChangeNotifierProxyProvider<Auth, ProductsProvider>(
          update: (ctx, auth, previousProdutcs) =>
              ProductsProvider(auth.token, auth.userId),
          create: (ctx) => ProductsProvider(Auth().token, Auth().userId),
        ),
        ChangeNotifierProvider(
          create: (ctx) => Cart(),
        ),
        ChangeNotifierProxyProvider<Auth, Orders>(
          update: (ctx, auth, previousOrder) => Orders(auth.token, auth.userId),
          create: (ctx) => Orders(Auth().token, Auth().userId),
        ),
      ],

      child: Consumer<Auth>(
        builder: (ctx, auth, _) => MaterialApp(
            title: 'MyShop',
            theme: ThemeData(
                primaryColor: Colors.purple,
                accentColor: Colors.deepOrange,
                errorColor: Colors.red,
                pageTransitionsTheme: PageTransitionsTheme(
                  builders: {
                    TargetPlatform.android: CustomPageTransitionBuilder(),
                    TargetPlatform.iOS: CustomPageTransitionBuilder()
                  }
                )
                ),
            home: auth.isAuthenticated
                ? ProductsOverviewScreen()
                : FutureBuilder(
                    future: auth.tryAutoLogin(),
                    builder: (ctx, dataSnapshot) =>
                        dataSnapshot.connectionState == ConnectionState.waiting
                            ? SplashScreen()
                           : AuthScreen(),
                  ),
            routes: {
              ProductDetailScreen.routeName: (ctx) => ProductDetailScreen(),
              CartScreen.routeName: (ctx) => CartScreen(),
              OrdersScreen.routeName: (ctx) => OrdersScreen(),
              UserProductsScreen.routeNamme: (ctx) => UserProductsScreen(),
              EditProductScreen.routeName: (ctx) => EditProductScreen(),
            }),
      ),
    );
  }
}

//It is recommended to use create in change Notifier when we are creating an insatnce of our provider class 
//and if we are using an existing object like products then we should use dot value approach of changeNotifer

//Since we need Cart at multiple places we are gonna add it to our root widget with 
//help of MultiProvider