import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/cart.dart' show Cart;
import '../providers/orders.dart';
import '../widgets/cartItem.dart ';

class CartScreen extends StatelessWidget {
  static const routeName = '/cartScreen';

  @override
  Widget build(BuildContext context) {
    final cartItem = Provider.of<Cart>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text("Your Cart"),
      ),
      body: Column(
        children: [
          Card(
            margin: EdgeInsets.all(15),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Total',
                    style: TextStyle(
                      fontSize: 20,
                    ),
                  ),
                  Spacer(),
                  //
                  Chip(
                    label: Text(
                      '\$${cartItem.TotalAmount.toStringAsFixed(2)}',
                      style: TextStyle(
                          color: Theme.of(context).primaryIconTheme.color),
                    ),
                    backgroundColor: Theme.of(context).primaryColor,
                  ),
                  OrderButton(cartItem: cartItem),
                ],
              ),
            ),
          ),
          SizedBox(
            height: 10,
          ),
          Expanded(
            child: ListView.builder(
              itemCount: cartItem.items.length,
              itemBuilder: (ctx, ind) => CartItem(
                id: cartItem.items.values.toList()[ind].id,
                price: cartItem.items.values.toList()[ind].price,
                prodId: cartItem.items.keys.toList()[ind],
                quantity: cartItem.items.values.toList()[ind].quantity,
                title: cartItem.items.values.toList()[ind].title,
              ),
            ),
          )
        ],
      ),
    );
  }
}

class OrderButton extends StatefulWidget {
  const OrderButton({
    Key? key,
    required this.cartItem,
  }) : super(key: key);

  final Cart cartItem;

  @override
  State<OrderButton> createState() => _OrderButtonState();
}

class _OrderButtonState extends State<OrderButton> {
  var _isLoading = false;
  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: (widget.cartItem.TotalAmount  <=0  ||  _isLoading)
          ? null
          : () async {
              setState(() {
                _isLoading = true;
              });
              await Provider.of<Orders>(context,listen: false).addOrder(
                  widget.cartItem.items.values.toList(),
                  widget.cartItem.TotalAmount);

              setState(() {
                _isLoading = false;
              });
              widget.cartItem.clearCart();
            },
      child:  _isLoading? CircularProgressIndicator() : Text('ORDER NOW'),
      style: TextButton.styleFrom(primary: Theme.of(context).primaryColor),
    );
  }
}

//It is a good practice to move your logic not into your widgets
//but into models/providers fodlers
