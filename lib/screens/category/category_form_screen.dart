import 'package:dd_smart_todo_app/models/category_model.dart';
import 'package:dd_smart_todo_app/providers/auth_provider.dart';
import 'package:dd_smart_todo_app/providers/category_provider.dart';
import 'package:dd_smart_todo_app/utils/constants.dart';
import 'package:dd_smart_todo_app/widgets/custom_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:provider/provider.dart';

class CategoryFormScreen extends StatefulWidget {
  final CategoryModel? category;

  const CategoryFormScreen({
    super.key,
    this.category,
  });

  @override
  State<CategoryFormScreen> createState() => _CategoryFormScreenState();
}

class _CategoryFormScreenState extends State<CategoryFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late Color _selectedColor;
  late IconData _selectedIcon;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.category?.name);

    _selectedColor = widget.category?.color ?? Constants.categoryColors[0];
    _selectedIcon = widget.category?.icon ?? Constants.categoryIcons[0];
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _saveCategory() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final userId =
          Provider.of<AuthProvider>(context, listen: false).currentUser!.id;

      final category = CategoryModel(
        id: widget.category?.id ?? '',
        name: _nameController.text.trim(),
        color: _selectedColor,
        icon: _selectedIcon,
        userId: userId,
        createdAt: widget.category?.createdAt ?? DateTime.now(),
        updatedAt: DateTime.now(),
      );

      if (widget.category != null) {
        await Provider.of<CategoryProvider>(context, listen: false)
            .updateCategory(category);
      } else {
        await Provider.of<CategoryProvider>(context, listen: false)
            .createCategory(category);
      }

      if (mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showColorPicker() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Pick a color'),
        content: SingleChildScrollView(
          child: BlockPicker(
            pickerColor: _selectedColor,
            onColorChanged: (color) {
              setState(() => _selectedColor = color);
              Navigator.pop(context);
            },
            availableColors: Constants.categoryColors,
          ),
        ),
      ),
    );
  }

  void _showIconPicker() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Pick an icon'),
        content: SizedBox(
          width: double.maxFinite,
          child: GridView.builder(
            shrinkWrap: true,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
            ),
            itemCount: Constants.categoryIcons.length,
            itemBuilder: (context, index) {
              final icon = Constants.categoryIcons[index];
              return InkWell(
                onTap: () {
                  setState(() => _selectedIcon = icon);
                  Navigator.pop(context);
                },
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  decoration: BoxDecoration(
                    color: _selectedIcon == icon
                        ? Theme.of(context).primaryColor.withValues(alpha: 0.1)
                        : null,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    icon,
                    color: _selectedIcon == icon
                        ? Theme.of(context).primaryColor
                        : null,
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.category != null ? 'Edit Category' : 'New Category'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Name
            TextFormField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: 'Name',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a name';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Color and Icon
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: _showColorPicker,
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Theme.of(context).colorScheme.surface,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Color',
                            style: TextStyle(
                              color: Colors.grey[400],
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            height: 40,
                            decoration: BoxDecoration(
                              color: _selectedColor,
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: GestureDetector(
                    onTap: _showIconPicker,
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Theme.of(context).colorScheme.surface,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Icon',
                            style: TextStyle(
                              color: Colors.grey[400],
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Icon(
                            _selectedIcon,
                            size: 40,
                            color: _selectedColor,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Save Button
            CustomButton(
              text: widget.category != null
                  ? 'Update Category'
                  : 'Create Category',
              onPressed: _saveCategory,
              isLoading: _isLoading,
            ),
          ],
        ),
      ),
    );
  }
}
