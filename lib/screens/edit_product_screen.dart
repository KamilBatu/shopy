import 'package:flutter/material.dart';
import 'package:shopy/screens/user_product_screen.dart';
import '../provider/product.dart';
import 'package:provider/provider.dart';
import '../provider/product_provider.dart';

class EditProductScreen extends StatefulWidget {
  static const routeName = '/edit-product-screen';

  @override
  State<EditProductScreen> createState() => _EditProductScreenState();
}

class _EditProductScreenState extends State<EditProductScreen> {
  final _priceFocusNode = FocusNode();
  final _descriptionNode = FocusNode();
  final _imageUrlController = TextEditingController();
  final _imageUrlFocusNode = FocusNode();
  final _form = GlobalKey<FormState>();
  var _editedProduct = Product(
    id: '',
    description: '',
    imageUrl: '',
    price: 0,
    title: '',
  );
  var _init = true;
  var _isLoading = false;
  var _initValues = {
    "title": '',
    "description": '',
    "price": '',
    "imageUrl": '',
  };

  @override
  void initState() {
    _imageUrlFocusNode.addListener(_updateImageUrl);
    super.initState();
  }

  @override
  void didChangeDependencies() {
    if (_init) {
      final prodId = ModalRoute.of(context)?.settings.arguments as String?;
      if (prodId != null && prodId.isNotEmpty) {
        final updatedItem = Provider.of<ProductProvider>(context, listen: false)
            .findById(prodId);
        _initValues = {
          "title": updatedItem.title,
          "description": updatedItem.description,
          "price": updatedItem.price.toString(),
          "imageUrl": '',
        };
        _imageUrlController.text = updatedItem.imageUrl;
        _editedProduct = updatedItem;
      }
    }
    _init = false;
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    _imageUrlFocusNode.removeListener(_updateImageUrl);
    _priceFocusNode.dispose();
    _descriptionNode.dispose();
    _imageUrlController.dispose();
    _imageUrlFocusNode.dispose();
    super.dispose();
  }

  void _updateImageUrl() {
    if (!_imageUrlFocusNode.hasFocus) {
      if (_imageUrlController.text.isEmpty ||
          (!_imageUrlController.text.startsWith('http') &&
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
    final isValid = _form.currentState?.validate();
    if (!isValid!) {
      return;
    }
    _form.currentState!.save();
    setState(() {
      _isLoading = true;
    });

    if (_editedProduct.id.isNotEmpty) {
      try {
        await Provider.of<ProductProvider>(context, listen: false)
            .updateProduct(_editedProduct, _editedProduct.id);
      } catch (e) {
        print('error happened');
      } finally {
        print('done');
        setState(() {
          _isLoading = false;
        });
        Navigator.of(context).pushReplacementNamed(UserProductScreen.routeName);
      }
    } else {
      try {
        await Provider.of<ProductProvider>(context, listen: false)
            .addProduct(_editedProduct);
      } catch (error) {
        await showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: Text('Something went wrong.'),
            content: Text('yeah an error occured'),
            actions: <Widget>[
              TextButton(
                child: Text('Okay'),
                onPressed: () {
                  Navigator.of(ctx).pop();
                },
              ),
            ],
          ),
        );
      } finally {
        setState(() {
          _isLoading = false;
        });
        Navigator.of(context).pushReplacementNamed(UserProductScreen.routeName);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.deepPurple,
        iconTheme: IconThemeData(color: Colors.white),
        title: Text(
          'Edit Product',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : Padding(
              padding: const EdgeInsets.all(8.0),
              child: Form(
                key: _form,
                child: Padding(
                  padding: const EdgeInsets.all(30.0),
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        TextFormField(
                          initialValue: _initValues['title'],
                          onFieldSubmitted: (_) {
                            FocusScope.of(context)
                                .requestFocus(_priceFocusNode);
                          },
                          decoration: const InputDecoration(labelText: 'Title'),
                          keyboardType: TextInputType.text,
                          onSaved: (newValue) {
                            _editedProduct = Product(
                              id: _editedProduct.id,
                              description: _editedProduct.description,
                              imageUrl: _editedProduct.imageUrl,
                              price: _editedProduct.price,
                              title: newValue!,
                              isFavorite: _editedProduct.isFavorite,
                            );
                          },
                          validator: (value) {
                            if (value!.isEmpty) {
                              return 'Title cannot be empty';
                            }

                            return null;
                          },
                        ),
                        TextFormField(
                          initialValue: _initValues['price'],
                          onFieldSubmitted: (_) {
                            FocusScope.of(context)
                                .requestFocus(_descriptionNode);
                          },
                          decoration: const InputDecoration(labelText: 'Price'),
                          keyboardType: TextInputType.number,
                          focusNode: _priceFocusNode,
                          onSaved: (newValue) {
                            _editedProduct = Product(
                              id: _editedProduct.id,
                              description: _editedProduct.description,
                              imageUrl: _editedProduct.imageUrl,
                              price: double.parse(newValue!),
                              title: _editedProduct.title,
                              isFavorite: _editedProduct.isFavorite,
                            );
                          },
                          validator: (value) {
                            if (value!.isEmpty) {
                              return 'Please enter a price';
                            }
                            if (double.tryParse(value) == null) {
                              return 'Invalid price';
                            }
                            if (double.parse(value) <= 0) {
                              return 'Price must be greater than 0';
                            }
                            return null;
                          },
                        ),
                        TextFormField(
                          initialValue: _initValues['description'],
                          onFieldSubmitted: (_) {
                            FocusScope.of(context)
                                .requestFocus(_imageUrlFocusNode);
                          },
                          maxLines: 3,
                          decoration:
                              const InputDecoration(labelText: 'Description'),
                          keyboardType: TextInputType.multiline,
                          focusNode: _descriptionNode,
                          onSaved: (newValue) {
                            _editedProduct = Product(
                              id: _editedProduct.id,
                              description: newValue!,
                              imageUrl: _editedProduct.imageUrl,
                              price: _editedProduct.price,
                              title: _editedProduct.title,
                              isFavorite: _editedProduct.isFavorite,
                            );
                          },
                          validator: (value) {
                            if (value!.isEmpty) {
                              return 'Description cannot be empty';
                            }
                            if (value.length < 12) {
                              return 'Description is too short! Minimum 12 characters';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 10),
                        Card(
                          elevation: 5,
                          child: _imageUrlController.text.isEmpty
                              ? const CircleAvatar(
                                  maxRadius: 40,
                                  backgroundColor: Colors.white54,
                                  child: Text(
                                    'Enter URL',
                                    style: TextStyle(color: Colors.deepPurple),
                                  ),
                                )
                              : CircleAvatar(
                                  backgroundImage:
                                      NetworkImage(_imageUrlController.text),
                                  maxRadius: 40,
                                ),
                        ),
                        const SizedBox(height: 5),
                        TextFormField(
                          controller: _imageUrlController,
                          keyboardType: TextInputType.url,
                          decoration:
                              const InputDecoration(labelText: 'Image URL'),
                          focusNode: _imageUrlFocusNode,
                          onSaved: (newValue) {
                            _editedProduct = Product(
                              id: _editedProduct.id,
                              description: _editedProduct.description,
                              imageUrl: newValue!,
                              price: _editedProduct.price,
                              title: _editedProduct.title,
                              isFavorite: _editedProduct.isFavorite,
                            );
                          },
                          validator: (value) {
                            if (value!.isEmpty) {
                              return 'Please enter an image URL';
                            }
                            if (!value.startsWith('http') &&
                                !value.startsWith('https')) {
                              return 'Invalid image URL';
                            }
                            if (!value.endsWith('.png') &&
                                !value.endsWith('.jpg') &&
                                !value.endsWith('.jpeg')) {
                              return 'Invalid image URL';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(
                          height: 30,
                        ),
                        ElevatedButton(
                          style: ButtonStyle(
                            backgroundColor:
                                WidgetStateProperty.all(Colors.deepPurple),
                            elevation: WidgetStateProperty.all(10),
                          ),
                          onPressed: _saveForm,
                          child: const Text(
                            'Submit',
                            style: TextStyle(color: Colors.white, fontSize: 20),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
    );
  }
}
