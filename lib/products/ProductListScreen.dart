import 'dart:convert';

import 'package:groceryapp/category_list/CategorytListScreen.dart';
import 'package:groceryapp/products/BrandDetails.dart';
import 'package:groceryapp/search/Search.dart';
import 'package:groceryapp/shopping_cart/ShoppingCartScreen.dart';
import 'package:groceryapp/util/AppColors.dart';
import 'package:groceryapp/util/Variables.dart';

import '../products/WishListModel.dart';
import '../util/Util.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../navigation_drawer/Navigation.dart';
import '../products/ItemProduct.dart';
import '../shapes/screen_clip.dart';
import '../util/Consts.dart';
import 'CatDetails.dart';
import 'ProductAttribute.dart';
import 'ProductModel.dart';

class ProductListScreen extends StatefulWidget {
  final String searchKeyword;
  final String categoryID;
  final String categoryName;
  final bool myFav;
  final bool isAgent;
  final Function() notify;
  const ProductListScreen(
      {Key key,
      this.searchKeyword,
      this.categoryID,
      this.categoryName,
      this.myFav,
      this.isAgent,
      this.notify})
      : super(key: key);

  @override
  _ProductListScreenState createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  String _pageTitle;
  Future<List<ProductModel>> _productList;
  Future<List<WishListModel>> _productwishList;
  bool _showLoder;
  bool dataLoad = true;
  List<String> sortByList = ["Product Sorting"];
  String _searchKey;
  String _categoryID;
  bool openSearch;
  bool isAvailable = true;
  String noProductMessage;
  var _searchController = new TextEditingController();

  bool isAgent;
  bool showMyFavourite;

  int quantity;

  @override
  void initState() {
    // TODO: implement initState
    quantity = 0;
    _handleFetchCart();

    noProductMessage = '';
    _searchKey = widget.searchKeyword;
    _pageTitle = widget.categoryName != null ? widget.categoryName : '';
    openSearch = false;
    // if (_searchKey != null && !_searchKey.isEmpty) {
    //   openSearch = true;
    // } else {
    //   openSearch = false;
    // }
    _categoryID = widget.categoryID;
    _showLoder = true;

    showMyFavourite = widget.myFav != null ? widget.myFav : false;

    _productList = _getProducts(_categoryID);
    // _productwishList = fetchWish();
    isAgent = widget.isAgent == true ? true : false;
    super.initState();
  }

  @override
  void dispose() {
    _searchController.text = "";
    super.dispose();
  }

  Future<List<ProductModel>> _getProducts(String catID) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var userID = prefs.getString('user_id');

    if (prefs.get("usertype") != null && prefs.get("usertype") == "DI") {
      setState(() {
        isAgent = true;
      });
    }

    List<ProductModel> mList = [];

    var requestParam;

    http.Response response;
    if (_searchKey != null && _searchKey != "") {
      requestParam = "?keyword=" + _searchKey;
      if (userID != null && int.parse(userID) > 0) {
        requestParam += "&user_id=" + userID;
      }
    } else if (showMyFavourite == true) {
      requestParam = "?my_wishlist=1";
      if (userID != null && int.parse(userID) > 0) {
        requestParam += "&user_id=" + userID;
      }
    } else {
      requestParam = "?cat_id=" + catID;
      if (userID != null && int.parse(userID) > 0) {
        requestParam += "&user_id=" + userID;
      }
    }
    //print("request param..." + requestParam.toString());
    response = await http.get(
      Uri.parse(Consts.PRODUCT_LIST + requestParam),
    );

    debugPrint("URl ${Uri.parse(Consts.PRODUCT_LIST + requestParam)}");

    if (response.statusCode == 200) {
      var responseData = jsonDecode(response.body);
      var serverMessage = responseData['message'];
      var productData = responseData['productdata'];
      //print("...ppp...." + responseData.toString());
      print("...ppp...." + productData.length.toString());
      if (responseData['status'] == "success") {
        if (productData.length > 0) {
          debugPrint("success ${productData.length}");
          for (int i = 0; i < productData.length; i++) {
            List<String> galleryImages = [];
            var itemData = productData[i];
            ProductModel item = ProductModel();
            // var productDetails = itemData['productDetails'];
            debugPrint("success ${productData.length}");
            item.productId = itemData['product_id'];
            item.productType = itemData['product_type'];
            item.productCode = itemData['product_code'];
            item.uniqueKey = itemData['unique_key'];
            item.productTitle = itemData['product_title'];
            item.productDescription = itemData['product_description'];
            item.gstId = itemData['gst_id'];
            item.productPrice = itemData['product_price'];
            item.productRegularPrice = itemData['product_regular_price'];
            item.productDistributorPrice =
                itemData['product_distributor_price'];
            item.productUnit = itemData['product_unit'];
            item.productBatchNo = itemData['product_batch_no'];
            item.productQuantityInfo = itemData['product_quantity_info'];
            item.productImage = itemData['productcatimg'];
            item.stockCount = itemData['stock_count'];
            item.status = itemData['status'];

            item.isInWishList =
                int.parse(itemData['is_in_wishlist'].toString());

            var glImages = itemData['gallery_images'];
            if (glImages.length > 0) {
              for (int gi = 0; gi < glImages.length; gi++) {
                galleryImages.add(glImages[gi]);
              }
            }
            item.galleryImages = galleryImages;

            //Extra data

            item.categoryId = itemData['categoryID'];
            //item.categoryName = itemData['category_name'];

            var brandDDetails = itemData['brand_details'];
            List<BrandDetails> brandDetails = [];
            if (brandDetails.length > 0) {
              for (int bd = 0; bd < brandDDetails.length; bd++) {
                var bdDetails = brandDDetails[bd];
                BrandDetails brand = BrandDetails();
                brand.brandId = bdDetails["brand_id"];
                brand.brandName = bdDetails["brand_name"];
                brand.brandDescription = bdDetails["brand_description"];
                brandDetails.add(brand);
              }
              item.brandDetails = brandDetails;
              //print("brandDetails..." + item.brandDetails.toString());
            } else {
              item.brandDetails = brandDetails;
            }
            //print("item...1.." + item.toString());
            // var catDetails = itemData["cat_details"];
            // List<CatDetails> catDetails1 = [];
            // if (catDetails.length > 0) {
            //   for (int cd = 0; cd < catDetails.length; cd++) {
            //     var cdDetails = catDetails[cd];
            //     CatDetails cat = CatDetails();
            //     cat.categoryId = cdDetails["category_id"];
            //     cat.catName = cdDetails["cat_name"];
            //     cat.catDescription = cdDetails["cat_description"];
            //     catDetails1.add(cat);
            //   }
            //   item.catDetails = catDetails1;
            // } else {
            //   item.catDetails = catDetails1;
            //   //mList.add(item);
            // }
            // print("item...0.." + item.toString());
            var productAttribute = itemData["product_attribute"];
            List<ProductAttribute> pattribute = [];
            if (productAttribute.length > 0) {
              for (int pa = 0; pa < productAttribute.length; pa++) {
                var productAttr = productAttribute[pa];
                ProductAttribute product = ProductAttribute();
                product.productId = productAttr["product_id"];

                product.attributeId = productAttr["attribute_id"];
                product.name = productAttr["name"];
                product.productPrice = productAttr["product_price"];
                product.productRegularPrice =
                    productAttr["product_regular_price"];
                product.productDistributorPrice =
                    productAttr["product_distributor_price"];
                product.variationId = productAttr["variation_id"];
                product.variableAttributeId =
                    productAttr["variable_attribute_id"];
                pattribute.add(product);
              }
              item.productAttribute = pattribute;
            } else {
              item.productAttribute = pattribute;
              //mList.add(item);
            }
            //print("item...4.." + item.toString());
            // item.brandId = itemData['brand_id'];
            // item.brandName = itemData['brand_name'];
            // item.brandDesc = itemData['brand_description'];
            mList.add(item);
            //print("mList00..." + mList.toString());
          }
        }
      } else {
        setState(() {
          isAvailable = false;
          noProductMessage = "Product Not Found";
        });
        //showCustomToast(serverMessage);
      }
      setState(() {
        _showLoder = false;
        dataLoad = true;
      });
    } else {
      showCustomToast("Error while conneting to server");
      throw Exception("Error getting response  ${response.statusCode}");
    }
    debugPrint("mList ${mList.length}");
    return mList;
  }

  _gotoShoppinCartScreen() async {
    var openCart = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ShoppingCartScreen(),
      ),
    );
    if (openCart != null && openCart == "refresh cart") {
      debugPrint("Returned data $openCart");
      setState(() {
        _handleFetchCart();
      });
    }
  }

  //======== Fetch Cart ======
  _handleFetchCart() async {
    //print("notify.." + widget.notify.toString());
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var user_id = prefs.getString('user_id');
    if (user_id == null) {
      return null;
    }
    var requestParam = "?";
    requestParam += "user_id=" + user_id;
    //print(requestParam);
    final http.Response response = await http.get(
      Uri.parse(Consts.VIEW_CART + requestParam),
    );
    // print(Consts.VIEW_CART + requestParam);
    // print(response.body);
    if (response.statusCode == 200) {
      var responseData = jsonDecode(response.body);
      var serverCode = responseData['code'];
      var serverMessage = responseData['message'];
      if (serverCode == "200") {
        var arrCartProducts = responseData["productdata"];
        if (arrCartProducts.length > 0) {
          //print("cart length..." + arrCartProducts.length.toString());

          Variables.itemCount = arrCartProducts.length;
          setState(() {
            quantity = Variables.itemCount;
          });
        }
        widget.notify();
      } else {
        //print("Else part");
        setState(() {
          quantity = 0;
        });
      }
    }
  }

  void _updateCart() {
    debugPrint("Update cart");
    _handleFetchCart();
  }

  void dataUpdate() {
    print("showloader..." + _showLoder.toString());
    print("showloader..." + widget.myFav.toString());
    // setState(() {
    // });
    if (widget.myFav == true) {
      setState(() {
        dataLoad = false;
        _productList = _getProducts(_categoryID);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // print("categoryItem");
    // print("detals.." + widget.categoryID.toString());
    double shapeHeight = 150;
    // print(_searchKey);
    return Scaffold(
      backgroundColor: Colors.white,
      //drawer: Navigation(),
      appBar: CustomAppbar(),
      body: SafeArea(
        child: Container(
          height: double.infinity,
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage(
                "images/image_bg.png",
              ),
              fit: BoxFit.cover,
            ),
          ),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Stack(
                  children: <Widget>[
                    // The containers in the background
                    ClipPath(
                      clipper: RedShape(
                          MediaQuery.of(context).size.width, shapeHeight),
                      child: Container(
                        height: shapeHeight,
                        decoration: BoxDecoration(
                          color: Color(0XFFc80718),
                        ),
                        child: Container(
                          margin: EdgeInsets.only(
                            left: 35,
                            right: 10,
                          ),
                          width: MediaQuery.of(context).size.width,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(
                                height: 10,
                              ),
                              // Text(
                              //   _pageTitle,
                              //   style: TextStyle(
                              //     fontSize: 35,
                              //     color: Colors.white,
                              //   ),
                              // ),
                              // SizedBox(
                              //   height: 5,
                              // ),
                              Flexible(
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Expanded(
                                      child: Padding(
                                        padding:
                                            const EdgeInsets.only(top: 7.0),
                                        child: Text(
                                          _pageTitle,
                                          style: TextStyle(
                                            fontSize: 21,
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                      width: 20,
                                    ),
                                    // Container(
                                    //   height: 40,
                                    //   color: Color(0XFFA90415),
                                    //   child: Padding(
                                    //     padding: const EdgeInsets.all(8.0),
                                    //     child: DropdownButton<String>(
                                    //       value: "Product Sorting",
                                    //       items: sortByList.map((String value) {
                                    //         return new DropdownMenuItem<String>(
                                    //           value: value,
                                    //           child: new Text(
                                    //             value,
                                    //             textAlign: TextAlign.center,
                                    //             style: TextStyle(
                                    //               color: Colors.white,
                                    //               fontSize: 15.0,
                                    //               fontWeight: FontWeight.bold,
                                    //             ),
                                    //           ),
                                    //         );
                                    //       }).toList(),
                                    //       onChanged: (value) {
                                    //         setState(() {});
                                    //       },
                                    //     ),
                                    //   ),
                                    // ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    // The card widget with top padding,
                    // incase if you wanted bottom padding to work,
                    // set the `alignment` of container to Alignment.bottomCenter
                    Container(
                      alignment: Alignment.topCenter,
                      padding: new EdgeInsets.only(
                        top: shapeHeight * .70,
                        right: 20.0,
                        left: 20.0,
                      ),
                      child: Stack(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              color: Color(0xFFFFFFFF),
                              //color: Colors.red,
                              borderRadius: BorderRadius.circular(15),
                              border: Border.all(
                                color: Color(0XFFf9f7f7),
                                width: 4,
                              ),
                            ),
                            height: 100,
                            child: !isAvailable
                                ? Center(
                                    child: Text(
                                      noProductMessage,
                                      style: TextStyle(
                                        fontSize: 18,
                                      ),
                                    ),
                                  )
                                : Container(),
                          ),
                          dataLoad == true
                              ? Align(
                                  alignment: Alignment.topCenter,
                                  child: Padding(
                                    padding: const EdgeInsets.only(top: 5.0),
                                    child: Container(
                                      height:
                                          MediaQuery.of(context).size.height -
                                              200,
                                      child:
                                          //ProductList(productList: _productList,isAgent: isAgent,notifyCart: _updateCart)
                                          FutureBuilder(
                                        initialData: null,
                                        future: _productList,
                                        builder: (BuildContext context,
                                            AsyncSnapshot snapshot) {
                                          if (snapshot.hasData) {
                                            var arrProducts = snapshot.data;
                                            return ListView.builder(
                                              padding: EdgeInsets.all(0),
                                              shrinkWrap: true,
                                              itemCount: arrProducts.length,
                                              scrollDirection: Axis.vertical,
                                              itemBuilder:
                                                  (context, int index) {
                                                ProductModel itemProduct =
                                                    arrProducts[index];
                                                return ItemProduct(
                                                    itemProduct: itemProduct,
                                                    isAgent: isAgent,
                                                    notifyCart: _updateCart,
                                                    dataUpdate: dataUpdate);
                                              },
                                            );
                                          } else {
                                            return _showLoder
                                                ? Center(
                                                    child:
                                                        CircularProgressIndicator(),
                                                  )
                                                : Container();
                                          }
                                        },
                                      ),
                                    ),
                                  ),
                                )
                              : Center(child: CircularProgressIndicator()),
                        ],
                      ),
                    )
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget navDrawer() {
    return Drawer(
      child: Container(
        color: Colors.white,
        child: ListView(
          // Important: Remove any padding from the ListView.

          padding: EdgeInsets.only(top: 10),
          children: <Widget>[
            // DrawerHeader(
            //   child: Text('Drawer Header'),
            //   decoration: BoxDecoration(
            //     color: Colors.blue,
            //   ),
            // ),
            ListTile(
              title: Text(
                'Item 1',
                style: TextStyle(
                  color: Colors.black,
                ),
              ),
              onTap: () {
                // Update the state of the app.
                // ...
              },
            ),
            ListTile(
              title: Text(
                'Item 2',
                style: TextStyle(
                  color: Colors.black,
                ),
              ),
              onTap: () {
                // Update the state of the app.
                // ...
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget CustomAppbar() {
    return AppBar(
      leading: InkWell(
          onTap: () {
            print("button Clicked...");
            if (widget.myFav == true) {
              Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                      builder: (context) => CategorytListScreen()),
                  (route) => false);
            } else {
              Navigator.pop(context);
            }
          },
          child: Icon(Icons.arrow_back)),
      title: Center(
        child: Text(
          "Vedic",
          style: TextStyle(
            fontFamily: "Philosopher",
            fontSize: 36,
          ),
        ),
      ),
      actions: <Widget>[
        InkWell(
          child: Padding(
            padding: const EdgeInsets.only(right: 10.0),
            child: Container(
              width: 40,
              child: Stack(
                children: [
                  Center(
                    child: Icon(
                      Icons.shopping_cart,
                      color: Colors.white,
                      size: 34,
                    ),
                  ),
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 30.0),
                      child: Container(
                        width: 25,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.appMainColor,
                          border: Border.all(
                            color: Colors.white,
                            width: 0.2,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            Variables.itemCount == null
                                ? "0"
                                : "${Variables.itemCount}",
                            style: TextStyle(color: Colors.white, fontSize: 14),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          onTap: () {
            // _handleAddCart(itemProduct);
            _gotoShoppinCartScreen();
          },
        ),
        IconButton(
          icon: Icon(
            Icons.search,
            color: Colors.white,
            size: 35,
          ),
          onPressed: () {
            // if (openSearch && _searchKey != null && _searchKey.isNotEmpty) {
            print("subCategory..." + widget.isAgent.toString());
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => Search(agent: widget.isAgent),
              ),
            );
            //   setState(() {
            //     openSearch = !openSearch;
            //   });
            // } else {
            //   setState(() {
            //     openSearch = !openSearch;
            //   });
            // }
          },
        )
      ],
    );
  }
}

// class ProductList extends StatelessWidget {
//   const ProductList({ Key key,@required Future<List<ProductModel>> productList,bool isAgent,var _updateCart }) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return Container(

//     );
//   }
// }
