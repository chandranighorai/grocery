//import 'package:groceryapp/products/ProductAttribute.dart';

class SearchModel {
  String status;
  String message;
  List<Productdata> productdata;

  SearchModel({this.status, this.message, this.productdata});

  SearchModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    if (json['productdata'] != null) {
      productdata = new List<Productdata>();
      json['productdata'].forEach((v) {
        productdata.add(new Productdata.fromJson(v));
        print("v..." + v.toString());
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['status'] = this.status;
    data['message'] = this.message;
    if (this.productdata != null) {
      data['productdata'] = this.productdata.map((v) => v.toJson()).toList();
    }
    //print("DAta..." + data.toString());
    return data;
  }
}

class Productdata {
  String categoryID;
  String categoryName;
  String brandName;
  String brandDescription;
  String productId;
  String productType;
  String productCode;
  String uniqueKey;
  String productTitle;
  String productKeyword;
  String productDescription;
  String categoryId;
  String brandId;
  String gstId;
  String productPrice;
  String productRegularPrice;
  String productDistributorPrice;
  Null productUnit;
  String productBatchNo;
  String productQuantityInfo;
  String productImage;
  String stockCount;
  String status;
  String metaTitle;
  String metaKeyword;
  String metaDescription;
  String addedDate;
  String productcatimg;
  int isInWishlist;
  List<String> galleryImages;
  List<ProductAttribute> productAttribute;

  // String variableAttributeId;
  // String variationId;
  // String productAttributePrice;
  // String productAttributeRegularPrice;
  // String productName;

  Productdata(
      {this.categoryID,
      this.categoryName,
      this.brandName,
      this.brandDescription,
      this.productId,
      this.productType,
      this.productCode,
      this.uniqueKey,
      this.productTitle,
      this.productKeyword,
      this.productDescription,
      this.categoryId,
      this.brandId,
      this.gstId,
      this.productPrice,
      this.productRegularPrice,
      this.productDistributorPrice,
      this.productUnit,
      this.productBatchNo,
      this.productQuantityInfo,
      this.productImage,
      this.stockCount,
      this.status,
      this.metaTitle,
      this.metaKeyword,
      this.metaDescription,
      this.addedDate,
      this.productcatimg,
      this.isInWishlist,
      this.galleryImages,
      this.productAttribute
      // this.variableAttributeId,
      // this.variationId,
      // this.productAttributePrice,
      // this.productAttributeRegularPrice,
      // this.productName
      });

  Productdata.fromJson(Map<String, dynamic> json) {
    categoryID = json['categoryID'];
    categoryName = json['category_name'];
    brandName = json['brand_name'];
    brandDescription = json['brand_description'];
    productId = json['product_id'];
    productType = json['product_type'];
    productCode = json['product_code'];
    uniqueKey = json['unique_key'];
    productTitle = json['product_title'];
    productKeyword = json['product_keywords'];
    productDescription = json['product_description'];
    categoryId = json['category_id'];
    brandId = json['brand_id'];
    gstId = json['gst_id'];
    productPrice = json['product_price'];
    productRegularPrice = json['product_regular_price'];
    productDistributorPrice = json['product_distributor_price'];
    productUnit = json['product_unit'];
    productBatchNo = json['product_batch_no'];
    productQuantityInfo = json['product_quantity_info'];
    productImage = json['product_image'];
    stockCount = json['stock_count'];
    status = json['status'];
    metaTitle = json['meta_title'];
    metaKeyword = json['meta_keyword'];
    metaDescription = json['meta_description'];
    addedDate = json['added_date'];
    productcatimg = json['productcatimg'];
    isInWishlist = json['is_in_wishlist'];
    galleryImages = json['gallery_images'].cast<String>();
    print(
        "product_Attribute..1." + json['product_attribute'].length.toString());
    if (json['product_attribute'].length != 0) {
      print("product_Attribute..." + json['product_attribute'].toString());
      productAttribute = new List<ProductAttribute>();
      json['product_attribute'].forEach((v) {
        productAttribute.add(new ProductAttribute.fromJson(v));
      });
    }

    // variableAttributeId = json["product_attribute"];
    // variationId =
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['categoryID'] = this.categoryID;
    data['category_name'] = this.categoryName;
    data['brand_name'] = this.brandName;
    data['brand_description'] = this.brandDescription;
    data['product_id'] = this.productId;
    data['product_type'] = this.productType;
    data['product_code'] = this.productCode;
    data['unique_key'] = this.uniqueKey;
    data['product_title'] = this.productTitle;
    data['product_keywords'] = this.productKeyword;
    data['product_description'] = this.productDescription;
    data['category_id'] = this.categoryId;
    data['brand_id'] = this.brandId;
    data['gst_id'] = this.gstId;
    data['product_price'] = this.productPrice;
    data['product_regular_price'] = this.productRegularPrice;
    data['product_distributor_price'] = this.productDistributorPrice;
    data['product_unit'] = this.productUnit;
    data['product_batch_no'] = this.productBatchNo;
    data['product_quantity_info'] = this.productQuantityInfo;
    data['product_image'] = this.productImage;
    data['stock_count'] = this.stockCount;
    data['status'] = this.status;
    data['meta_title'] = this.metaTitle;
    data['meta_keyword'] = this.metaKeyword;
    data['meta_description'] = this.metaDescription;
    data['added_date'] = this.addedDate;
    data['productcatimg'] = this.productcatimg;
    data['is_in_wishlist'] = this.isInWishlist;
    data['gallery_images'] = this.galleryImages;
    if (this.productAttribute != null) {
      data['product_attribute'] =
          this.productAttribute.map((v) => v.toJson()).toList();
    }
    print("Data..." + data.toString());
    return data;
  }
}

class ProductAttribute {
  String variableAttributeId;
  String productId;
  String attributeId;
  String variationId;
  String productPrice;
  String productRegularPrice;
  String productDistributorPrice;
  String name;

  ProductAttribute(
      {this.variableAttributeId,
      this.productId,
      this.attributeId,
      this.variationId,
      this.productPrice,
      this.productRegularPrice,
      this.productDistributorPrice,
      this.name});

  ProductAttribute.fromJson(Map<String, dynamic> json) {
    variableAttributeId = json['variable_attribute_id'];
    productId = json['product_id'];
    attributeId = json['attribute_id'];
    variationId = json['variation_id'];
    productPrice = json['product_price'];
    productRegularPrice = json['product_regular_price'];
    productDistributorPrice = json['product_distributor_price'];
    name = json['name'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['variable_attribute_id'] = this.variableAttributeId;
    data['product_id'] = this.productId;
    data['attribute_id'] = this.attributeId;
    data['variation_id'] = this.variationId;
    data['product_price'] = this.productPrice;
    data['product_regular_price'] = this.productRegularPrice;
    data['product_distributor_price'] = this.productDistributorPrice;
    data['name'] = this.name;
    return data;
  }
}
