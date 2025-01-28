import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smart_todo_app/models/category_model.dart';
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
  static final List<Color> colorOptions = [
    primaryColor,
    Colors.red,
    Colors.green,
    Colors.blue,
    Colors.deepOrange,
    Colors.purple,
  ];

  static final List<IconData> iconOptions = [
    Icons.category,
    Icons.work,
    Icons.home,
    Icons.school,
    Icons.person,
    Icons.shopping_cart,
  ];

  Color findMatchingColor(Color color) {
    return colorOptions.firstWhere(
      (option) => option.value == color.value,
      orElse: () => colorOptions[0],
    );
  }

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
            ? const Center(child: CircularProgressIndicator())
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
                    padding: const EdgeInsets.all(20),
                    itemCount: categoryProvider.categories.length,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 1,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                    ),
                    itemBuilder: (context, index) {
                      final category = categoryProvider.categories[index];
                      return _buildCategoryCard(category, context);
                    },
                  ),
      ),
    );
  }

  Widget _buildCategoryCard(CategoryModel category, BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: category.categoryColor,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            category.categoryIcon,
            color: Colors.white,
            size: 40,
          ),
          const SizedBox(height: 15),
          Text(
            category.categoryName,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const Text(
            '0 tasks', // TODO: Replace with actual task count
            style: TextStyle(
              fontSize: 16,
              color: Colors.white70,
            ),
          ),
          const Spacer(),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              InkWell(
                onTap: () => _showEditCategoryDialog(context, category),
                child: Icon(
                  Icons.edit,
                  color: Colors.white,
                ),
              ),
              SizedBox(
                width: 10,
              ),
              InkWell(
                onTap: () => _confirmDeleteCategory(context, category.id),
                child: Icon(
                  Icons.delete,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showAddCategoryDialog(BuildContext context) {
    final categoryProvider =
        Provider.of<CategoryProvider>(context, listen: false);
    final categoryNameController = TextEditingController();
    Color selectedColor = colorOptions[0];
    IconData selectedIcon = iconOptions[0];

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              backgroundColor: primaryColor,
              title: const Center(
                child: Text(
                  'Add Category',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CustomTextFieldInputWithoutPadding(
                      controller: categoryNameController,
                      hintText: 'Category Name',
                      icon: Icons.category_outlined,
                      validator: Validators.validateName,
                    ),
                    const SizedBox(height: 20),
                    _buildColorSelector(selectedColor, (Color? newColor) {
                      if (newColor != null) {
                        setState(() => selectedColor = newColor);
                      }
                    }),
                    const SizedBox(height: 20),
                    _buildIconSelector(selectedIcon, (IconData? newIcon) {
                      if (newIcon != null) {
                        setState(() => selectedIcon = newIcon);
                      }
                    }),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text(
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
            );
          },
        );
      },
    );
  }

  void _showEditCategoryDialog(BuildContext context, CategoryModel category) {
    final categoryProvider =
        Provider.of<CategoryProvider>(context, listen: false);
    final categoryNameController =
        TextEditingController(text: category.categoryName);
    Color selectedColor = findMatchingColor(category.categoryColor);
    IconData selectedIcon = iconOptions.contains(category.categoryIcon)
        ? category.categoryIcon
        : iconOptions[0];

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              backgroundColor: primaryColor,
              title: const Center(
                child: Text(
                  'Edit Category',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CustomTextFieldInputWithoutPadding(
                      controller: categoryNameController,
                      hintText: 'Category Name',
                      icon: Icons.category_outlined,
                      validator: Validators.validateName,
                    ),
                    const SizedBox(height: 20),
                    _buildColorSelector(selectedColor, (Color? newColor) {
                      if (newColor != null) {
                        setState(() => selectedColor = newColor);
                      }
                    }),
                    const SizedBox(height: 20),
                    _buildIconSelector(selectedIcon, (IconData? newIcon) {
                      if (newIcon != null) {
                        setState(() => selectedIcon = newIcon);
                      }
                    }),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text(
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
                      categoryProvider.updateCategory(
                        category.id,
                        categoryNameController.text,
                        selectedColor,
                        selectedIcon,
                      );
                      Navigator.pop(context);
                    }
                  },
                  child: Text('Save', style: TextStyle(color: textColor)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildColorSelector(Color currentColor, Function(Color?) onChanged) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'Select Color:',
          style: TextStyle(color: Colors.white, fontSize: 16),
        ),
        const SizedBox(width: 15),
        DropdownButton<Color>(
          icon: const Icon(Icons.color_lens, color: Colors.white),
          elevation: 0,
          underline: Container(),
          value: currentColor,
          dropdownColor: primaryColor,
          items: colorOptions.map((Color color) {
            return DropdownMenuItem<Color>(
              value: color,
              child: Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  color: color,
                  border: Border.all(color: Colors.white, width: 1),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ],
    );
  }

  Widget _buildIconSelector(
      IconData currentIcon, Function(IconData?) onChanged) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'Select Icon:',
          style: TextStyle(color: Colors.white, fontSize: 16),
        ),
        const SizedBox(width: 15),
        DropdownButton<IconData>(
          icon: const Icon(Icons.arrow_drop_down, color: Colors.white),
          elevation: 0,
          underline: Container(),
          value: currentIcon,
          dropdownColor: primaryColor,
          items: iconOptions.map((IconData icon) {
            return DropdownMenuItem<IconData>(
              value: icon,
              child: Icon(icon, color: Colors.white),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ],
    );
  }

  void _confirmDeleteCategory(BuildContext context, String categoryId) {
    final categoryProvider =
        Provider.of<CategoryProvider>(context, listen: false);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: primaryColor,
          title: const Text(
            'Delete Category',
            style: TextStyle(color: Colors.white),
          ),
          content: const Text(
            'Are you sure you want to delete this category?',
            style: TextStyle(color: Colors.white),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'Cancel',
                style: TextStyle(color: Colors.white),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
              ),
              onPressed: () {
                categoryProvider.deleteCategory(categoryId);
                Navigator.pop(context);
              },
              child: const Text(
                'Delete',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }
}
