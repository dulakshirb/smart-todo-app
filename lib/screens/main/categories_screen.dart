import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smart_todo_app/providers/category_provider.dart';
import 'package:smart_todo_app/utils/colors.dart';
import 'package:smart_todo_app/utils/validators.dart';
import 'package:smart_todo_app/widgets/custom_text_field_without_padding.dart';

class CategoriesScreen extends StatefulWidget {
  const CategoriesScreen({super.key});

  @override
  State<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<CategoryProvider>(context, listen: false).loadCategories();
    });
  }

  @override
  Widget build(BuildContext context) {
    final categoryProvider = Provider.of<CategoryProvider>(context);

    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showAddCategoryDialog(context);
        },
        child: const Icon(Icons.add),
      ),
      body: SafeArea(
        child: categoryProvider.isLoading
            ? Center(child: CircularProgressIndicator())
            : categoryProvider.categories.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Text(
                        'No categories available. Please add a new category.',
                        style: TextStyle(color: textColor, fontSize: 18),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  )
                : GridView.builder(
                    itemCount: categoryProvider.categories.length,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2),
                    itemBuilder: (context, index) {
                      final category = categoryProvider.categories[index];
                      return Container(
                        margin: const EdgeInsets.all(10),
                        padding: EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: category.categoryColor,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(category.categoryIcon,
                                color: Colors.white, size: 40),
                            SizedBox(height: 10),
                            Text(
                              category.categoryName,
                              style: TextStyle(
                                fontSize: 23,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            Text(
                              '20 todos', // Placeholder for todo count
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.white,
                              ),
                            ),
                            Spacer(),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Icon(
                                  Icons.edit,
                                  color: Colors.white,
                                ),
                                IconButton(
                                    icon:
                                        Icon(Icons.delete, color: Colors.white),
                                    onPressed: () {
                                      _confirmDeleteCategory(
                                          context, category.id);
                                    }),
                              ],
                            )
                          ],
                        ),
                      );
                    },
                  ),
      ),
    );
  }

  void _showAddCategoryDialog(BuildContext context) {
    final categoryProvider =
        Provider.of<CategoryProvider>(context, listen: false);
    TextEditingController categoryNameController = TextEditingController();
    Color selectedColor = primaryColor;
    IconData selectedIcon = Icons.category;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: primaryColor,
          title: Center(
            child: Text(
              'Add Category',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text(
                'Cancel',
                style: TextStyle(color: Colors.white),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: accentColor,
              ),
              onPressed: () {
                if (categoryNameController.text.isNotEmpty) {
                  categoryProvider.addCategory(
                    categoryNameController.text,
                    selectedColor,
                    selectedIcon,
                  );
                  Navigator.pop(context);
                }
              },
              child: Text('Add', style: TextStyle(color: textColor)),
            ),
          ],
          content: StatefulBuilder(builder: (context, setState) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CustomTextFieldInputWithoutPadding(
                  controller: categoryNameController,
                  hintText: 'Personal',
                  icon: Icons.category_outlined,
                  validator: Validators.validateName,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Select Color:',
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                    SizedBox(width: 15),
                    DropdownButton<Color>(
                      icon: Icon(
                        Icons.color_lens,
                        color: Colors.white,
                      ),
                      elevation: 0,
                      underline: Container(),
                      value: selectedColor,
                      items: [
                        primaryColor,
                        Colors.red,
                        Colors.green,
                        Colors.blue,
                        Colors.deepOrange,
                        Colors.purple,
                      ].map((color) {
                        return DropdownMenuItem<Color>(
                          value: color,
                          child: Container(
                            width: 20,
                            height: 20,
                            color: color,
                          ),
                        );
                      }).toList(),
                      onChanged: (Color? newColor) {
                        if (newColor != null) {
                          setState(() {
                            selectedColor = newColor;
                          });
                        }
                      },
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        'Select Icon:',
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
                    ),
                    SizedBox(width: 15),
                    DropdownButton<IconData>(
                      elevation: 0,
                      underline: Container(),
                      value: selectedIcon,
                      dropdownColor: primaryColor,
                      items: [
                        Icons.category,
                        Icons.work,
                        Icons.home,
                        Icons.school,
                        Icons.shopping_cart,
                      ].map((icon) {
                        return DropdownMenuItem<IconData>(
                          value: icon,
                          child: Icon(icon, color: Colors.white),
                        );
                      }).toList(),
                      onChanged: (IconData? newIcon) {
                        if (newIcon != null) {
                          setState(() {
                            selectedIcon = newIcon;
                          });
                        }
                      },
                    ),
                  ],
                ),
              ],
            );
          }),
        );
      },
    );
  }

  void _confirmDeleteCategory(BuildContext context, String categoryId) {
    final categoryProvider =
        Provider.of<CategoryProvider>(context, listen: false);
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Delete Category'),
          content: Text('Are you sure you want to delete this category?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                categoryProvider.deleteCategory(categoryId);
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text('Delete'),
            ),
          ],
        );
      },
    );
  }
}
