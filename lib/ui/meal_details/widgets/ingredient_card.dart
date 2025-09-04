import 'package:flutter/material.dart';
import '../../../models/meal_details/meal_details_model.dart';

class IngredientCard extends StatefulWidget {
  final IngredientItem ingredient;
  final String mealId;
  final bool isEditing;
  final Function(String itemId, double newQuantity, String newName)? onIngredientChanged;

  const IngredientCard({
    super.key,
    required this.ingredient,
    required this.mealId,
    required this.isEditing,
    this.onIngredientChanged,
  });

  @override
  State<IngredientCard> createState() => _IngredientCardState();
}

class _IngredientCardState extends State<IngredientCard> {
  late TextEditingController _quantityController;
  late TextEditingController _nameController;

  @override
  void initState() {
    super.initState();
    _quantityController = TextEditingController(
      text: widget.ingredient.quantity.toString(),
    );
    _nameController = TextEditingController(
      text: widget.ingredient.name,
    );
  }

  @override
  void dispose() {
    _quantityController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      color: const Color(0xFFFFFAF0), // Light beige
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            // Ingredient image
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: Colors.grey[300],
              ),
              child: widget.ingredient.imageUrl.isNotEmpty
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        widget.ingredient.imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return const Icon(Icons.fastfood, color: Colors.grey);
                        },
                      ),
                    )
                  : const Icon(Icons.fastfood, color: Colors.grey),
            ),
            const SizedBox(width: 12),
            
            // Ingredient details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (widget.isEditing) ...[
                    // Editable name field
                    TextField(
                      controller: _nameController,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                      decoration: const InputDecoration(
                        contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        border: OutlineInputBorder(),
                        isDense: true,
                      ),
                      onChanged: (newName) {
                        // Auto-save name changes to pendingChanges
                        if (newName.trim().isNotEmpty) {
                          widget.onIngredientChanged?.call(
                            widget.ingredient.itemId,
                            double.tryParse(_quantityController.text) ?? widget.ingredient.quantity,
                            newName.trim(),
                          );
                        }
                      },
                    ),
                  ] else ...[
                    // Static name display
                    Text(
                      widget.ingredient.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        '${widget.ingredient.calories.toStringAsFixed(1)} cal',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${widget.ingredient.protein.toStringAsFixed(1)}g protein',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            // Quantity section
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                if (widget.isEditing) ...[
                  // Editable quantity field
                  SizedBox(
                    width: 80,
                    child: TextField(
                      controller: _quantityController,
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 14),
                      decoration: InputDecoration(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        border: const OutlineInputBorder(),
                        isDense: true,
                        suffixText: widget.ingredient.unit,
                      ),
                      onChanged: (newQuantity) {
                        // Auto-save quantity changes to pendingChanges
                        final quantity = double.tryParse(newQuantity);
                        if (quantity != null && quantity > 0) {
                          widget.onIngredientChanged?.call(
                            widget.ingredient.itemId,
                            quantity,
                            _nameController.text.trim().isNotEmpty 
                                ? _nameController.text.trim() 
                                : widget.ingredient.name,
                          );
                        }
                      },
                    ),
                  ),
                ] else ...[
                  // Static quantity display
                  Text(
                    '${widget.ingredient.quantity} ${widget.ingredient.unit}',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
} 