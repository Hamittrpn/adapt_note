class Category {
  int categoryID;
  String categoryTitle;

  // Kategori eklerken kullanılacak. Çünkü id db tarafından oluşturuluyor.
  Category({
    this.categoryTitle,
  });

  Category.withID({
    this.categoryID,
    this.categoryTitle,
  });

  Map<String, dynamic> toMap() {
    var map = Map<String, dynamic>();
    map["CategoryID"] = categoryID;
    map["CategoryTitle"] = categoryTitle;

    return map;
  }

  Category.fromMap(Map<String, dynamic> map) {
    this.categoryID = map["CategoryID"];
    this.categoryTitle = map["CategoryTitle"];
  }

  @override
  String toString() {
    return 'Category{CategoryID: $categoryID, CategoryTitle: $categoryTitle}';
  }

  
}
