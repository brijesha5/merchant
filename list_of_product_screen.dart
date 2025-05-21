import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:flutter_sample/category_model.dart';
import 'package:flutter_sample/pricing_modal.dart';
import 'package:flutter_sample/product_model.dart';
import 'FireConstants.dart';
import 'generate_bill_screen.dart';
import 'global_constatnts.dart';
import 'main.dart';
import 'main_menu.dart';
import 'main_menu_desk.dart';
import 'main_menu_desk.dart';
import 'modifier_model.dart';

void main() => runApp(const MyAppList());

class MyAppList extends StatefulWidget {
  const MyAppList({super.key});

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyAppList> {
  List<SelectedProduct> selectedProducts = [];
  List<SelectedProductModifier> selectedModifiers = [];
  Map<String, String> myStrings = {};

  void addToSelectedProducts(String name, double price, int quantity,
      String productcode, String costCenterCode) {
    setState(() {
      bool productExists = false;
      for (SelectedProduct product in selectedProducts) {
        if (product.name == name) {
          productExists = true;
          product.quantity = quantity;
          break;
        }
      }

      if (!productExists) {
        selectedProducts.add(SelectedProduct(
          name: name,
          price: price,
          quantity: quantity,
          costCenterCode: costCenterCode,
          code: productcode,
        ));
      }
    });
  }

  void addToSelectedModifiers(String name, double price, int quantity,
      String productcode, String itemcode) {
    setState(() {
      bool itemExists = false;
      for (var modifier in selectedModifiers) {
        if (modifier.name == name) {
          modifier.quantity += quantity;
          itemExists = true;
          break;
        }
      }

      if (!itemExists) {
        selectedModifiers.add(SelectedProductModifier(
          name: name,
          price_per_unit: price,
          quantity: quantity,
          code: productcode,
          product_code: itemcode,
        ));
      }
    });
  }

  void removeFromSelectedModifiers(String name, int quantity) {
    setState(() {
      int indexToRemove = -1;
      for (int i = 0; i < selectedModifiers.length; i++) {
        if (selectedModifiers[i].name == name) {
          if (selectedModifiers[i].quantity > quantity) {
            selectedModifiers[i].quantity -= quantity;
          } else {
            indexToRemove = i;
          }
          break;
        }
      }

      if (indexToRemove != -1) {
        selectedModifiers.removeAt(indexToRemove);
      }
    });
  }

  void removeSelectedProduct(String name) {
    setState(() {
      selectedProducts.removeWhere((product) => product.name == name);
    });
  }

  List<SelectedProduct> getSelectedProducts() {
    return selectedProducts;
  }

  int selectedButtonIndex = 0;
  int selectedCategory = 100;
  String whattofollow = "s";
  final TextEditingController _searchController = TextEditingController();

  int totalQuantity = 0;

  void updateTotalQuantity(int newQuantity) {
    setState(() {
      totalQuantity = newQuantity;
    });
  }


  Future<List<Pricing>> fetchPricing() async {
    final response = await http.get(Uri.parse('${apiUrl}pricing/getAll?DB=$CLIENTCODE'));

    if (response.statusCode == 200) {
      return pricingFromMap(response.body);
    } else {
      throw Exception('Failed to load pricing');
    }
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Future<List<Pricing>> futurePricing = fetchPricing();
    Map<String, String> receivedStrings =
        ModalRoute.of(context)!.settings.arguments as Map<String, String>;
    myStrings = ModalRoute.of(context)!.settings.arguments as Map<String, String>;

    gReceivedStrings = receivedStrings;

    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    void displayMessage(String msg) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          Future.delayed(const Duration(seconds: 2), () {
            Navigator.of(context).pop();
          });

          final backgroundColor = Colors.white.withOpacity(0.7);
          return AlertDialog(
            backgroundColor: backgroundColor,
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                const Icon(
                  Icons.error,
                  size: 48.0,
                  color: Color(0xBBA90000),
                ),
                const SizedBox(height: 16.0),
                Text(
                  msg,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'HammersmithOne',
                    color: Colors.blue.shade800,
                    fontSize: 16.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            actions: const [],
          );
        },
      );
    }

    return Scaffold(
      backgroundColor: Color(0xFFE0E0E0),
      body: Column(
        children: [

          Container(
            height: 80,
            color: const Color(0xffc00716),
            child: Padding(
              padding: const EdgeInsets.only(top: 15.0, left: 16.0),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    iconSize: 28.0,
                    onPressed: () async {
                      Navigator.of(context).pop();
                    },
                  ),
                  const SizedBox(width: 16),
                ],
              ),
            ),
          ),

          Padding(
            padding: EdgeInsets.only(top: 20.0, left: 16, right: 16),
            child: Container(
              height: 50,
              child: TextField(
                style: const TextStyle(
                  color: Color(0xFF808080),
                ),
                controller: _searchController,
                onChanged: (value) {
                  whattofollow = "s";
                  setState(() {});
                },
                decoration: InputDecoration(
                  hintText: 'Search for foodssss...',
                  hintStyle: const TextStyle(
                    fontFamily: 'HammersmithOne',
                    color: Color(0xFF808080),
                  ),
                  prefixIcon: const Icon(
                    Icons.search,
                    color: Color(0xFF808080),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding:
                      const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
                  enabledBorder: OutlineInputBorder(
                    borderSide: const BorderSide(
                      color: Colors.white,
                    ),
                    borderRadius: BorderRadius.circular(5.0),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: const BorderSide(
                      color: Colors.white,
                    ),
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
              ),
            ),
          ),

          SizedBox(height: 10),

          Container(
            margin: EdgeInsets.only(top: 5),
            height: 35,
            color: Colors.grey[200],
            child: FutureBuilder<List<Category>>(
              future: screenWidth > screenHeight
                  ? futureCategoryWindows
                  : futureCategory,
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: snapshot.data!.length,
                    itemBuilder: (BuildContext context, int index) {
                      bool isSelected = index == selectedButtonIndex;
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            selectedButtonIndex = index;
                            whattofollow = "c";
                            selectedCategory =
                                snapshot.data![index].categoryCode;
                          });
                        },
                        child: Container(
                          margin: EdgeInsets.symmetric(horizontal: 4.0),
                          padding: EdgeInsets.symmetric(
                              horizontal: 10.0, vertical: 5.0),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? Color(0xffc00716)
                                : Colors.transparent,
                            border: Border.all(
                              color: isSelected
                                  ? Colors.transparent
                                  : Color(
                                      0xffc00716),
                            ),
                            borderRadius:
                                BorderRadius.circular(5),
                          ),
                          child: Center(
                            child: Text(
                              snapshot.data![index].categoryName,
                              style: TextStyle(
                                color: isSelected
                                    ? Colors.white
                                    : Color(
                                        0xffc00716),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  );
                } else {
                  return const Center(child: CircularProgressIndicator());
                }
              },
            ),
          ),

          Expanded(
            child: Container(
              color: Colors.white,
              child:FutureBuilder<List<Pricing>>(
                future: fetchPricing(),
                builder: (context, pricingSnapshot) {
                  if (pricingSnapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  } else if (pricingSnapshot.hasError) {
                    print('Error fetching pricing data: ${pricingSnapshot.error}');
                    return Center(child: Text('Error: ${pricingSnapshot.error}'));
                  } else if (!pricingSnapshot.hasData || pricingSnapshot.data!.isEmpty) {
                    print('No pricing data available');
                    return Center(child: Text('No pricing data available'));
                  } else {
                    List<Pricing> pricingData = pricingSnapshot.data!;
                    print('Fetched pricing data: $pricingData');

                    return FutureBuilder<List<Product>>(
                      key: Key(selectedCategory.toString()),
                      future: screenWidth > screenHeight ? futurePostWindows : futurePost,
                      builder: (context, snapshot) {
                        if (snapshot.hasData) {
                          final List<Product> filteredProducts;

                          if (whattofollow == "s") {
                            filteredProducts = snapshot.data!
                                .where((product) => product.productName
                                .toLowerCase()
                                .contains(_searchController.text.toLowerCase()))
                                .toList();
                          } else if (whattofollow == "c") {
                            filteredProducts = snapshot.data!
                                .where((product) =>
                            product.categoryCode == selectedCategory)
                                .toList();
                          } else {
                            filteredProducts = snapshot.data!;
                          }

                          print('Filtered products: $filteredProducts');

                          return ListView.builder(
                            padding: EdgeInsets.zero,
                            itemCount: filteredProducts.length,
                            itemBuilder: (context, index) {
                              String area = myStrings['area'] ?? '';
                              String lastClickedModule = Lastclickedmodule ?? '';
                              print('Current area: $area');
                              print('Last clicked module: $lastClickedModule');

                              Pricing? pricing = pricingData.firstWhere(
                                    (p) => p.itemCode == filteredProducts[index].productCode.toString() && (p.area == area || p.area == lastClickedModule),
                                orElse: () => Pricing(
                                  id: 0,
                                  status: false,
                                  itemName: filteredProducts[index].productName,
                                  itemCode: filteredProducts[index].productCode.toString(),
                                  price: 0,
                                  area: area,
                                ),
                              );

                              print('Pricing for product ${filteredProducts[index].productCode}: $pricing');

                              // Ensure price is valid
                              int price = pricing.price > 0 ? pricing.price : 0;

                              return FoodMenuItemCard(
                                imageUrl: filteredProducts[index].productImage,
                                name: filteredProducts[index].productName,
                                code: filteredProducts[index].productCode.toString(),
                                cuisine: filteredProducts[index].productCode.toString(),
                                price: price,
                                description: filteredProducts[index]
                                    .productDescription
                                    .toString(),
                                costcentercode:
                                filteredProducts[index].costcenterCode.toString(),
                                addToSelectedProducts: addToSelectedProducts,
                                addToSelectedModifiers: addToSelectedModifiers,
                                removeFromSelectedModifiers:
                                removeFromSelectedModifiers,
                                getSelectedProducts: getSelectedProducts,
                                removeSelectedProduct: removeSelectedProduct,
                                dietary: filteredProducts[index].dietary.toString(),
                              );
                            },
                          );
                        } else {
                          print('Product data is still loading');
                          return const Center(child: CircularProgressIndicator());
                        }
                      },
                    );
                  }
                },
              )
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        color: Color(0xFFD5282A),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Text(
              '${selectedProducts.length} Items selected',
              style: const TextStyle(
                  fontSize: 20,
                  color: Colors.white),
            ),
            SizedBox(
              width: MediaQuery.of(context).size.width > 1632 ? 700 : 5,
            ),
            Spacer(),
            ElevatedButton(
              onPressed: () {
                if (selectedProducts.isNotEmpty) {
                  Map<String, dynamic> routeArguments = {
                    'selectedProducts': selectedProducts,
                    'selectedModifiers': selectedModifiers,
                    'tableinfo': receivedStrings,
                  };
                  Navigator.pushNamed(context, '/placeorderscreen',
                      arguments: routeArguments);
                } else {
                  displayMessage('Please Select Item First');
                }
              },
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(5)),
                  side: const BorderSide(
                    color: Colors.black,
                    width: 0.1,
                  ),
                ),
                minimumSize: const Size(130, 50),
                backgroundColor: Colors.white,
              ),
              child: const Text(
                'Continue',
                style: TextStyle(
                    fontFamily: 'HammersmithOne',
                    fontSize: 20,
                    color: Color(0xFFD5282A)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class FoodMenuItemCard extends StatefulWidget {
  final String imageUrl;
  final String name;
  final String code;
  final String cuisine;
  final String dietary;
  final int price;
  final String description;
  final String costcentercode;
  final Function(String name, double price, int quantity, String code,
      String costcentercode) addToSelectedProducts;
  final Function(
      String name, double price, int quantity, String code, String itemCode)
  addToSelectedModifiers;
  final Function(String name, int quantity) removeFromSelectedModifiers;
  final Function(String name) removeSelectedProduct;
  final Function() getSelectedProducts;

  const FoodMenuItemCard({
    required this.imageUrl,
    required this.name,
    required this.code,
    required this.cuisine,
    required this.dietary,
    required this.price,
    required this.description,
    required this.costcentercode,
    required this.addToSelectedProducts,
    required this.addToSelectedModifiers,
    required this.removeFromSelectedModifiers,
    required this.removeSelectedProduct,
    required this.getSelectedProducts,
    Key? key,
  }) : super(key: key);

  @override
  _FoodMenuItemCardState createState() => _FoodMenuItemCardState();
}

class _FoodMenuItemCardState extends State<FoodMenuItemCard>
    with
        TickerProviderStateMixin,
        AutomaticKeepAliveClientMixin<FoodMenuItemCard> {
  List<String> allFoodItems = [
    'Food Item 1',
    'Food Item 2',
    'Food Item 3',
  ];

  List<String> filteredFoodItems = [];

  @override
  bool get wantKeepAlive => true;

  bool _expanded = false;
  bool _added = false;
  int _quantity = 1;

  void _toggleExpansion() {
    setState(() {
      _expanded = !_expanded;
    });
  }

  void _toggleAdded() {
    setState(() {
      _added = !_added;
      if (_added) {
        _expanded = true;
        widget.addToSelectedProducts(
            widget.name,
            widget.price.toDouble(),
            _quantity,
            widget.code,
            widget.costcentercode);

        List<SelectedProduct> sselectedProducts = [];
        sselectedProducts = widget.getSelectedProducts();

        for (int i = 0; i <= sselectedProducts.length - 1; i++) {
          SelectedProduct sp = sselectedProducts[i];
          print("selected ${sp.name} -- ${sp.quantity}");
        }
        _quantity = 1;
      }
    });
  }

  void _incrementQuantity() {
    setState(() {
      _quantity++;

      widget.addToSelectedProducts(
          widget.name,
          widget.price.toDouble(),
          _quantity,
          widget.code,
          widget.costcentercode);

      List<SelectedProduct> sselectedProducts = [];
      sselectedProducts = widget.getSelectedProducts();

      for (int i = 0; i <= sselectedProducts.length - 1; i++) {
        SelectedProduct sp = sselectedProducts[i];
        print("selected ${sp.name} -- ${sp.quantity}");
      }
    });
  }

  void _decrementQuantity() {
    setState(() {
      if (_quantity > 1) {
        _quantity--;
        widget.addToSelectedProducts(
            widget.name,
            widget.price.toDouble(),
            _quantity,
            widget.code,
            widget.costcentercode);
      } else {
        widget.removeSelectedProduct(widget.name);
        _added = false;
        _expanded = false;
      }
    });
    List<SelectedProduct> sselectedProducts = [];
    sselectedProducts = widget.getSelectedProducts();

    for (int i = 0; i <= sselectedProducts.length - 1; i++) {
      SelectedProduct sp = sselectedProducts[i];
      print("selected ${sp.name} -- ${sp.quantity}");
    }
  }

  String hdecimal(int price) {
    double number = price.toDouble();
    return '₹${number.toStringAsFixed(2)}';
  }

  void showCustomModifierDialog(String pcode) async {
    TextEditingController nameController = TextEditingController();
    TextEditingController priceController = TextEditingController();
    TextEditingController quantityController = TextEditingController();

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        return Theme(
          data: ThemeData(
            dialogBackgroundColor: Colors.white,
          ),
          child: AlertDialog(
            title: Center(
              child: const Text(
                'Custom Addon',
                style: TextStyle(color: Color(0xffcb0707)),
              ),
            ),
            content: Container(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    height: 40,
                    child: TextField(
                      controller: nameController,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey,
                      ),
                      cursorColor: Color(0xffcb0707),
                      decoration: const InputDecoration(
                        labelText: 'Name',
                        labelStyle: TextStyle(color: Colors.black54),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.black26),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.black26),
                        ),
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    height: 40,
                    child: TextField(
                      controller: priceController,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey,
                      ),
                      keyboardType: TextInputType.number,
                      cursorColor: Color(0xffcb0707),
                      decoration: const InputDecoration(
                        labelText: 'Price',
                        labelStyle: TextStyle(color: Colors.black54),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.black26),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.black26),
                        ),
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    height: 40,
                    child: TextField(
                      controller: quantityController,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey,
                      ),
                      keyboardType: TextInputType.number,
                      cursorColor: Color(0xffcb0707),
                      decoration: const InputDecoration(
                        labelText: 'Quantity',
                        labelStyle: TextStyle(color: Colors.black54),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.black26),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.black26),
                        ),
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(5)),
                        side: BorderSide(
                          color: Colors.black,
                          width: 0.1,
                        ),
                      ),
                      backgroundColor:
                          Color(0xFFD5282A),
                    ),
                    onPressed: () {
                      int qty = int.parse(quantityController.text);
                      double price = double.parse(priceController.text);

                      widget.addToSelectedModifiers(nameController.text, price,
                          qty, pcode.toString(), widget.code);

                      Navigator.of(context).pop();
                    },
                    child: const Text(
                      'Add',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            actions: const [],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    bool isSelected = widget
        .getSelectedProducts()
        .any((product) => product.name == widget.name);

    int quantity = 0;
    if (isSelected) {
      quantity = widget
          .getSelectedProducts()
          .firstWhere((product) => product.name == widget.name)
          .quantity;
    }

    return GestureDetector(
      onTap: _toggleExpansion,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Stack(
          children: [
            Positioned(
              top: 8,
              right: 8,
              child: Image.asset(
                widget.dietary == 'Veg'
                    ? 'assets/images/veg.png'
                    : 'assets/images/nonveg.png',
                height: 20,
                width: 20,
              ),
            ),
            Positioned(
              top: 34,
              right: 8,
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: isSelected
                    ? SizedBox(
                        width: 114,
                        height: 40,
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            border: Border.all(
                              color: Colors.black12,
                              width: 0.8,
                            ),
                            borderRadius: BorderRadius.circular(5),
                          ),
                          child: Row(
                            children: [
                              IconButton(
                                onPressed: _decrementQuantity,
                                icon: const Icon(
                                  Icons.remove,
                                  color:
                                      Color(0xFFD5282A),
                                ),
                              ),
                              Text(
                                quantity.toString(),
                                style: const TextStyle(
                                  color:
                                      Color(0xFFD5282A),
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              IconButton(
                                onPressed: _incrementQuantity,
                                icon: const Icon(
                                  Icons.add,
                                  color:
                                      Color(0xFFD5282A),
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    : SizedBox(
                        width: 90,
                        height: 40,
                        child: ElevatedButton(
                          onPressed: _toggleAdded,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(5),
                              side: const BorderSide(
                                color:
                                    Color(0xFFD5282A),
                                width: 0.5,
                              ),
                            ),
                          ),
                          child: const Text(
                            'Add',
                            style: TextStyle(
                              fontFamily: 'HammersmithOne',
                              color: Color(0xFFD5282A),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.memory(
                        base64Decode(widget.imageUrl),
                        width: 80,
                        height: 80,
                        fit: BoxFit.cover,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.name,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                          Text(
                            widget.cuisine,
                            style: const TextStyle(
                              fontFamily: 'HammersmithOne',
                              fontWeight: FontWeight.w400,
                              color: Colors.grey,
                            ),
                          ),
                          Text(
                            hdecimal(widget.price),
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color:
                                  Color(0xFFD5282A),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 20),
                  ],
                ),
                const SizedBox(height: 8),
                Divider(
                  color: Colors.grey[300],
                  thickness: 1,
                  indent: 10,
                  endIndent: 10,
                ),
                Padding(
                  padding: const EdgeInsets.all(0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AnimatedSize(
                        duration: const Duration(milliseconds: 300),
                        child: _expanded
                            ? Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(height: 8),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 16),
                                    child: Text(
                                      widget.description,
                                      style: const TextStyle(
                                        fontFamily: 'HammersmithOne',
                                        fontSize: 14,
                                        fontWeight: FontWeight.w400,
                                        color: Colors.black54,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 1),
                                  Padding(
                                    padding:
                                        const EdgeInsets.fromLTRB(20, 0, 0, 0),
                                    child: ElevatedButton(
                                      onPressed: () {
                                        showCustomModifierDialog(widget.code);
                                      },
                                      style: ElevatedButton.styleFrom(
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(5)),
                                          side: BorderSide(
                                            color: Colors.black,
                                            width: 0.1,
                                          ),
                                        ),
                                        backgroundColor: Colors
                                            .grey[300],
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Transform.translate(
                                            offset: Offset(-7, 0),
                                            child: Icon(Icons.edit,
                                                color: Colors.red,
                                                size:
                                                    18),
                                          ),
                                          const Text(
                                            'Custom Addon',
                                            style: TextStyle(
                                              fontFamily: 'HammersmithOne',
                                              fontSize: 14,
                                              color: Colors
                                                  .black54,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    height: 150,
                                    width: 250,
                                    child: FutureBuilder<List<Modifier>>(
                                      future: screenWidth > screenHeight
                                          ? futureModifierWindows
                                          : futureModifier,
                                      builder: (context, snapshot) {
                                        if (snapshot.connectionState ==
                                            ConnectionState.waiting) {
                                          return Center(
                                              child:
                                                  CircularProgressIndicator());
                                        } else if (snapshot.hasError) {
                                          return Center(
                                              child: Text(
                                                  'Error: ${snapshot.error}'));
                                        } else if (!snapshot.hasData ||
                                            snapshot.data!.isEmpty) {
                                          return const Center(
                                              child: Text(
                                                  'Facing Problem with Modifiers'));
                                        } else {
                                          final modifiers = snapshot.data!
                                              .where((modifier) =>
                                                  modifier.productCode ==
                                                  int.parse(widget.code))
                                              .toList();

                                          if (modifiers.isEmpty) {
                                            return const Center(
                                                child: Text(
                                                    'No Modifications Available for this item'));
                                          }

                                          return ListView.builder(
                                            itemCount: modifiers.length,
                                            itemBuilder: (context, index) {
                                              final modifier = modifiers[index];
                                              return Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 16.0,
                                                        vertical: 0.0),
                                                child: Card(
                                                  elevation: 0.0,
                                                  color: Colors.grey[300],
                                                  child: Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    children: <Widget>[
                                                      Expanded(
                                                        child: ListTile(
                                                          title: Text(
                                                            modifier
                                                                .modifierName,
                                                            style: TextStyle(
                                                                fontFamily:
                                                                    'HammersmithOne',
                                                                color: Colors
                                                                    .black54),
                                                          ),
                                                          subtitle: modifier
                                                                      .price >
                                                                  0
                                                              ? Text(
                                                                  '${modifier.price.toStringAsFixed(2)}',
                                                                  style: TextStyle(
                                                                      color: Colors
                                                                          .black54))
                                                              : null,
                                                        ),
                                                      ),
                                                      Container(
                                                        width: 100,
                                                        height: 30,
                                                        decoration:
                                                            BoxDecoration(
                                                          border: Border.all(
                                                            color: Colors.grey,
                                                            width:
                                                                1.0,
                                                          ),
                                                          borderRadius:
                                                              BorderRadius.circular(
                                                                  5),
                                                        ),
                                                        child: Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .center,
                                                          children: [
                                                            IconButton(
                                                              icon: Icon(
                                                                  Icons.exposure_neg_1,
                                                                  color: Colors.red),
                                                              padding: EdgeInsets.zero,
                                                              constraints:
                                                                  BoxConstraints(),

                                                              onPressed: () {
                                                                widget.removeFromSelectedModifiers(
                                                                    modifier.modifierName, 1);
                                                              },
                                                            ),
                                                            SizedBox(width: 0),

                                                            IconButton(
                                                              icon: Icon(
                                                                  Icons
                                                                      .plus_one,
                                                                  color: Colors
                                                                      .green),
                                                              padding:
                                                                  EdgeInsets
                                                                      .zero,
                                                              constraints:
                                                                  BoxConstraints(),
                                                              onPressed: () {
                                                                widget.addToSelectedModifiers(modifier.modifierName, modifier.price, 1, modifier.productCode.toString(), widget.code);
                                                              },
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                      const SizedBox(width: 10),
                                                    ],
                                                  ),
                                                ),
                                              );
                                            },
                                          );
                                        }
                                      },
                                    ),
                                  ),
                                ],
                              )
                            : const SizedBox.shrink(),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class RoundedButton extends StatelessWidget {
  final String label;
  final bool selected;

  const RoundedButton({
    super.key,
    required this.label,
    this.selected = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 8, bottom: 8, left: 16, right: 0),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: selected ? const Color(0xffc00716) : const Color(0xFFdde0ed),
        borderRadius: BorderRadius.circular(5),
      ),
      child: Center(
        child: Text(
          label,
          style: TextStyle(
            fontFamily: 'HammersmithOne',
            color: selected ? Colors.white : const Color(0xffd5282b),
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

class SelectedProduct {
  final String name;
  final String code;
  final String status;
  final String notes;
  final String costCenterCode;
  double price;
  double pricebckp;
  bool isComp;
  int quantity;

  SelectedProduct(
      {required this.name,
      required this.code,
      required this.price,
      this.quantity = 1,
      this.status = "active",
      this.notes = "",
      required this.costCenterCode,
      this.isComp = false,
      this.pricebckp = 0.0

      });

  Map<String, dynamic> toJson() {
    MyAppList ma = const MyAppList();

    return {
      "orderNumber": 1,
      "tableNumber": gReceivedStrings['name'],
      "itemName": name,
      "itemCode": code,
      "quantity": quantity,
      "notes": notes,
      "costCenterCode": costCenterCode,
      "status": status,
      "price": price,
    };
  }
}

class SelectedProductModifier {
  final String name;
  final String code;
  final String product_code;
  final String order_id;
  double price_per_unit;
  int quantity;

  SelectedProductModifier({
    required this.name,
    required this.code,
    required this.price_per_unit,
    required this.product_code,
    this.order_id = "",
    this.quantity = 1,
  });

  Map<String, dynamic> toJson() {
    MyAppList ma = const MyAppList();

    return {
      "orderNumber": 1,
      "name": name,
      "code": code,
      "product_code": product_code,
      "order_id": order_id,
      "quantity": quantity,
      "price_per_unit": price_per_unit,
    };
  }
}
