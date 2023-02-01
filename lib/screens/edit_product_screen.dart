import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import '../providers/product.dart';
import '../providers/products_provider.dart';

class EditProductScreen extends StatefulWidget {
  static const routeName = '/EditProducts';

  @override
  State<EditProductScreen> createState() => _EditProductScreenState();
}

class _EditProductScreenState extends State<EditProductScreen> {
  final _priceFocusNode = FocusNode();
  final _descriptionFocusNode = FocusNode();
  final _imageUrlController = TextEditingController();
  final _imageUrlFocusNode = FocusNode();
  final _formKey = GlobalKey<FormState>();
  var _editedProduct =
      Product(id: null, title: '', description: '', price: 0, imageUrl: '');
  var _isInit = true;
  var _isLoading = false;
  var _initValues = {
    'title': '',
    'description': '',
    'price': '',
    'imageUrl': '',
  };

  @override
  void initState() {
    _imageUrlFocusNode.addListener(_updateImageUrl);

    super.initState();
  }

  @override
  void didChangeDependencies() {
    if (_isInit) {
      final productId = ModalRoute.of(context)!.settings.arguments;
      if (productId != null) {
        _editedProduct = Provider.of<ProductsProvider>(context, listen: false)
            .findById(productId as String);
        _initValues = {
          'title': _editedProduct.title,
          'description': _editedProduct.description,
          'price': _editedProduct.price.toString(),
          'imageUrl': ''
        };
        _imageUrlController.text = _editedProduct.imageUrl;
      }
    }
    _isInit == false;
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    _imageUrlFocusNode.removeListener(_updateImageUrl);
    _priceFocusNode.dispose();
    _descriptionFocusNode.dispose();
    _imageUrlController.dispose();
    _imageUrlFocusNode.dispose();

    super.dispose();
  }

  void _updateImageUrl() {
    if (!_imageUrlFocusNode.hasFocus) {
      if ((!_imageUrlController.text.startsWith('http') &&
              !_imageUrlController.text.startsWith('https')) ||
          (!_imageUrlController.text.endsWith('.png') &&
              !_imageUrlController.text.endsWith('.jpg') &&
              !_imageUrlController.text.endsWith('.jpeg'))) {
        return;
      }
      setState(() {});
    }
  }

  Future<void> _saveForm() async {
    final _isValid = _formKey.currentState!.validate();
    if (!_isValid) {
      return;
    }
    _formKey.currentState!.save();
    setState(() {
      _isLoading = true;
    });

    if (_editedProduct.id != null) {
      await Provider.of<ProductsProvider>(context, listen: false)
          .updateProduct(_editedProduct.id, _editedProduct);
    } else {
      try {
        await Provider.of<ProductsProvider>(context, listen: false)
            .addProduct(_editedProduct);
      } catch (error) {
        await showDialog<Null>(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: Text('An error occurred'),
                content: Text('Something went wrong'),
                actions: [
                  TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: Text('Okay'))
                ],
              );
            });
        //finally only works in conjunction with try and catch,
        //Code in finally runs no matter whether we succedd or not.
      }
      // finally{
      //   setState(() {
      //           _isLoading = false;

      //               });

      //   Navigator.of(context).pop();

      // }

      // Provider.of<ProductsProvider>(context, listen: false)
      //     .addProduct(_editedProduct)
      //     .catchError((error) {
      //   return showDialog<Null>(
      //       context: context,
      //       builder: (context) {
      //         return AlertDialog(
      //           title: Text('An error occurred'),
      //           content: Text('Something went wrong'),
      //           actions: [
      //             TextButton(
      //                 onPressed: () {
      //                   Navigator.of(context).pop();

      //                 },
      //                 child: Text('Okay'))
      //           ],
      //         );
      //       });
      // }).then((_) {
      //   setState(() {
      //           _isLoading = false;

      //               });

      //   Navigator.of(context).pop();
      // });
    }
    setState(() {
      _isLoading = false;
    });
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          actions: [
            IconButton(onPressed: _saveForm, icon: Icon(Icons.save)),
          ],
          title: Text('Edit Product'),
          backgroundColor: Theme.of(context).primaryColor,
        ),
        body: _isLoading
            ? Center(
                child: CircularProgressIndicator(),
              )
            : Padding(
                padding: const EdgeInsets.all(16.0),
                child: Form(
                  key: _formKey,
                  child: ListView(children: [
                    TextFormField(
                      initialValue: _initValues['title'],
                      decoration: InputDecoration(
                        labelText: 'Title',
                      ),
                      textInputAction: TextInputAction.next,
                      onFieldSubmitted: (_) {
                        FocusScope.of(context).requestFocus(_priceFocusNode);
                      },
                      onSaved: (value) {
                        _editedProduct = Product(
                            id: _editedProduct.id,
                            description: "_editedProduct.description",
                            title: value.toString(),
                            imageUrl: _editedProduct.imageUrl,
                            price: _editedProduct.price,
                            isFavorite: _editedProduct.isFavorite);
                      },
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Please enter a value';
                        }
                        return null;
                      },
                    ),
                    TextFormField(
                      initialValue: _initValues['price'],
                      decoration: InputDecoration(
                        labelText: 'Price',
                      ),
                      textInputAction: TextInputAction.next,
                      keyboardType: TextInputType.number,
                      focusNode: _priceFocusNode,
                      onFieldSubmitted: (_) {
                        FocusScope.of(context)
                            .requestFocus(_descriptionFocusNode);
                      },
                      onSaved: (value) {
                        _editedProduct = Product(
                            id: _editedProduct.id,
                            description: _editedProduct.description,
                            title: _editedProduct.title,
                            imageUrl: _editedProduct.imageUrl,
                            price: double.parse(value as String),
                            isFavorite: _editedProduct.isFavorite);
                      },
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Please enter a price';
                        }
                        if (double.tryParse(value) == null) {
                          return 'Please enter a valid number';
                        }
                        if (double.parse(value) <= 0) {
                          return 'Please enter a price greater than zero';
                        }
                        return null;
                      },
                    ),
                    TextFormField(
                      initialValue: _initValues['description'],
                      decoration: InputDecoration(
                        labelText: 'Description',
                      ),
                      maxLines: 3,
                      keyboardType: TextInputType.multiline,
                      focusNode: _descriptionFocusNode,
                      onSaved: (value) {
                        _editedProduct = Product(
                            id: _editedProduct.id,
                            description: value as String,
                            title: _editedProduct.title,
                            imageUrl: _editedProduct.imageUrl,
                            price: _editedProduct.price,
                            isFavorite: _editedProduct.isFavorite);
                      },
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Please enter description';
                        }
                        if (value.length < 10) {
                          return 'Description should be atleast 10 characters long';
                        }
                        return null;
                      },
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Container(
                            width: 100,
                            height: 100,
                            margin: EdgeInsets.only(top: 8, right: 10),
                            decoration: BoxDecoration(
                                border:
                                    Border.all(width: 1, color: Colors.grey)),
                            child: _imageUrlController.text.isEmpty
                                ? Text('Enter a URL')
                                : FittedBox(
                                    child: Image.network(
                                        _imageUrlController.text,
                                        fit: BoxFit.cover),
                                  )),
                        Expanded(
                          child: TextFormField(
                            decoration: InputDecoration(labelText: 'Image URL'),
                            keyboardType: TextInputType.url,
                            textInputAction: TextInputAction.done,
                            controller: _imageUrlController,
                            onEditingComplete: () {
                              setState(() {});
                            },
                            focusNode: _imageUrlFocusNode,
                            onFieldSubmitted: (_) => _saveForm(),
                            onSaved: (value) {
                              _editedProduct = Product(
                                  id: _editedProduct.id,
                                  description: _editedProduct.description,
                                  title: _editedProduct.title,
                                  imageUrl: value as String,
                                  price: _editedProduct.price,
                                  isFavorite: _editedProduct.isFavorite);
                            },
                            // initialValue: _initValues['imageUrl'],
                            validator: (value) {
                              if (value!.isEmpty) {
                                return 'Please enter a image url';
                              }
                              if (!value.startsWith('http') &&
                                  !value.startsWith('https')) {
                                return 'Please enter a valid url';
                              }
                              if (!value.endsWith('.png') &&
                                  !value.endsWith('.jpg') &&
                                  !value.endsWith('.jpeg')) {
                                return 'Please enter a valid image url';
                              }
                              return null;
                            },
                          ),
                        )
                      ],
                    )
                  ]),
                ),
              ));
  }
}

//We can use focus node  methodology to move our input cursor to the next field 
//when we press the submit button on first field

//Note:- We have to dispose focus nodes when our state gets cleared/when we leave that screen.
//Note:- When we passed an argument/arguements from pushNamedRouting, we can't use that data in initState, 
//otherwise from any other resource we can use that data in initState 
//Note:- We cannot have both initial value and imageController, we can't use both