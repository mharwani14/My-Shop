import 'package:flutter/material.dart';
import 'package:my_shop/widgets/app_drawer.dart';
import 'package:provider/provider.dart';
import '../providers/orders.dart' show Orders;
import '../widgets/order_item.dart';

class OrdersScreen extends StatefulWidget {
  static const routeName = '/orders';

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  late Future _ordersFuture;
  Future _obtainOrdersFuture() {
    return Provider.of<Orders>(context, listen: false).fetchAndSet();
  }

  @override
  void initState() {
    _ordersFuture = _obtainOrdersFuture();
    // Future.delayed(Duration.zero).then((_) async {
    //   setState(() {
    //     _isLoading = true;
    //   });
    //   await Provider.of<Orders>(context, listen: false).fetchAndSet();
    //   setState(() {
    //     _isLoading = false;
    //   });
    // });

    //Provider.of<Orders>(context, listen: false).fetchAndSet();

    super.initState();
  }

  var _isLoading = false;

  @override
  Widget build(BuildContext context) {
    print('building orders');
    // final orderData = Provider.of<Orders>(context);
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).primaryColor,
          title: Text('Your Orders'),
        ),
        drawer: AppDrawer(),
        body: FutureBuilder(
          future: _ordersFuture,
          builder: (ctx, orderSnapshot) {
            if (orderSnapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            } else {
              if (orderSnapshot.error != null) {
                return Center(child: Text('An  error has occurred'));
              } else {
                return Consumer<Orders>(
                  builder: (ctx, orderData, child) => ListView.builder(
                    itemCount: orderData.orders.length,
                    itemBuilder: (ctx, ind) => OrderItem(orderData.orders[ind]),
                  ),
                );
              }
            }
          },
        ));
  }
}


 // 
      // body:_isLoading
      //     ? Center(child: CircularProgressIndicator())
      //     : ListView.builder(
      //         itemCount: orderData.orders.length,
      //         itemBuilder: (ctx, ind) => OrderItem(orderData.orders[ind]),
      //       ),

      /*
       Here we can use Future builder instead of stateful widget also
       One thing to keep in mind is not use ( final orderData = Provider.of<Orders>(context);)
       in Widget Build because it will cause us to trap in a infinte loop that is why we are using consumer
      */ 




      /*
      We are again converting to stateful widget 
      because to make sure that our future runs only once just because we don't want to fetch again  
      even if our builder is called again and again for some other app or widget

      It is considered a good practic :)


      */