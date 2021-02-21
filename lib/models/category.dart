class Category {
  int categoryID;
  String categoryName;

  // Kategori eklerken kullanılacak. Çünkü id db tarafından oluşturuluyor.
  Category({
    this.categoryName,
  });

  Category.withID({
    this.categoryID,
    this.categoryName,
  });

  Map<String, dynamic> toMap() {
    var map = Map<String, dynamic>();
    map["categoryID"] = categoryID;
    map["categoryName"] = categoryName;

    return map;
  }

  Category.fromMap(Map<String, dynamic> map) {
    this.categoryID = map["categoryID"];
    this.categoryName = map["categoryName"];
  }

  @override
  String toString() {
    return 'Category{categoryID: $categoryID, categoryName: $categoryName}';
  }
}
