import 'package:flutter/material.dart';
import '../models/category.dart';
import '../services/admin_data_service.dart';
import '../constants/admin_colors.dart';

class IncidentCategoriesPage extends StatefulWidget {
  const IncidentCategoriesPage({super.key});

  @override
  State<IncidentCategoriesPage> createState() => _IncidentCategoriesPageState();
}

class _IncidentCategoriesPageState extends State<IncidentCategoriesPage> {
  final dataService = AdminDataService();

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final int crossAxisCount = screenWidth >= 1000 ? 3 : (screenWidth >= 600 ? 2 : 1);

    return ListenableBuilder(
      listenable: dataService,
      builder: (context, _) {
        return Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header actions bar
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Manage Incident Categories",
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AdminColors.textDark),
                      ),
                      SizedBox(height: 4),
                      Text(
                        "Define incident categories available in the mobile reporting app.",
                        style: TextStyle(fontSize: 13, color: AdminColors.textLight),
                      ),
                    ],
                  ),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AdminColors.primaryGreen,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    onPressed: () => _showAddCategoryDialog(context),
                    icon: const Icon(Icons.add, size: 18),
                    label: const Text("Add Category", style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
              const SizedBox(height: 25),

              // Categories Grid
              Expanded(
                child: dataService.categories.isEmpty
                    ? const Center(
                        child: Text(
                          "No incident categories defined yet.",
                          style: TextStyle(color: AdminColors.textLight, fontSize: 15),
                        ),
                      )
                    : GridView.builder(
                        physics: const BouncingScrollPhysics(),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: crossAxisCount,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                          childAspectRatio: 1.8,
                        ),
                        itemCount: dataService.categories.length,
                        itemBuilder: (context, index) {
                          final category = dataService.categories[index];
                          return _buildCategoryCard(context, category);
                        },
                      ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCategoryCard(BuildContext context, IncidentCategory category) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2)),
        ],
        border: Border.all(color: AdminColors.border),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Icon + Name
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AdminColors.primaryGreen.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.folder_open_outlined,
                      color: AdminColors.primaryGreen,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    category.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: AdminColors.textDark,
                    ),
                  ),
                ],
              ),
              // Option triggers
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit, color: Colors.blue, size: 18),
                    tooltip: "Edit Category",
                    onPressed: () => _showEditCategoryDialog(context, category),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, color: AdminColors.dangerRed, size: 18),
                    tooltip: "Delete Category",
                    onPressed: () => _confirmDeleteCategory(context, category),
                  ),
                ],
              )
            ],
          ),
          const SizedBox(height: 12),
          // Description
          Expanded(
            child: Text(
              category.description,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 13,
                color: AdminColors.textLight,
                height: 1.3,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Add Category dialog popup
  void _showAddCategoryDialog(BuildContext context) {
    final formKey = GlobalKey<FormState>();
    final nameController = TextEditingController();
    final descController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Add New Incident Category"),
          content: SizedBox(
            width: 400,
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: nameController,
                    decoration: const InputDecoration(
                      labelText: "Category Name",
                      hintText: "e.g. Environmental Hazard",
                      border: OutlineInputBorder(),
                    ),
                    validator: (val) => val == null || val.isEmpty ? "Enter category name" : null,
                  ),
                  const SizedBox(height: 15),
                  TextFormField(
                    controller: descController,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      labelText: "Description",
                      hintText: "Enter explanation of what this category covers...",
                      border: OutlineInputBorder(),
                      alignLabelWithHint: true,
                    ),
                    validator: (val) => val == null || val.isEmpty ? "Enter category explanation" : null,
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AdminColors.primaryGreen, foregroundColor: Colors.white),
              onPressed: () {
                if (formKey.currentState!.validate()) {
                  final newCat = IncidentCategory(
                    id: "CAT-${DateTime.now().millisecondsSinceEpoch.toString().substring(8)}",
                    name: nameController.text.trim(),
                    description: descController.text.trim(),
                  );
                  dataService.addCategory(newCat);
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Category '${newCat.name}' created successfully")),
                  );
                }
              },
              child: const Text("Add Category"),
            ),
          ],
        );
      },
    );
  }

  // Edit Category dialog popup
  void _showEditCategoryDialog(BuildContext context, IncidentCategory category) {
    final formKey = GlobalKey<FormState>();
    final nameController = TextEditingController(text: category.name);
    final descController = TextEditingController(text: category.description);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Edit Category: ${category.name}"),
          content: SizedBox(
            width: 400,
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: nameController,
                    decoration: const InputDecoration(labelText: "Category Name", border: OutlineInputBorder()),
                    validator: (val) => val == null || val.isEmpty ? "Enter category name" : null,
                  ),
                  const SizedBox(height: 15),
                  TextFormField(
                    controller: descController,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      labelText: "Description",
                      border: OutlineInputBorder(),
                      alignLabelWithHint: true,
                    ),
                    validator: (val) => val == null || val.isEmpty ? "Enter category explanation" : null,
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AdminColors.primaryGreen, foregroundColor: Colors.white),
              onPressed: () {
                if (formKey.currentState!.validate()) {
                  final updated = category.copyWith(
                    name: nameController.text.trim(),
                    description: descController.text.trim(),
                  );
                  dataService.editCategory(updated);
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Category successfully updated")),
                  );
                }
              },
              child: const Text("Save Changes"),
            ),
          ],
        );
      },
    );
  }

  // Confirm delete category dialog popup
  void _confirmDeleteCategory(BuildContext context, IncidentCategory category) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Delete Category"),
          content: Text("Are you sure you want to permanently delete category '${category.name}'? This won't affect past submitted reports of this type but will prevent new submissions."),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AdminColors.dangerRed, foregroundColor: Colors.white),
              onPressed: () {
                dataService.deleteCategory(category.id);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Category '${category.name}' deleted successfully")),
                );
              },
              child: const Text("Delete"),
            ),
          ],
        );
      },
    );
  }
}
