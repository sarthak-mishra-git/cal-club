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
        child: Column(
          children: [
            Row(
              children: [
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
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                          decoration: const InputDecoration(
                            filled: true,
                            fillColor: Colors.white,
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
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),

                SizedBox(width: 12),
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
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.black87),
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: Colors.white,
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
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
            const SizedBox(height: 15),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
              // decoration: BoxDecoration(
              //   color: Colors.orange[100],
              //   borderRadius: BorderRadius.circular(12),
              //   // border: Border.all(color: Colors.orange)
              // ),
              child: Row(
                children: [
                  const Icon(
                    Icons.local_fire_department_rounded,
                    size: 16,
                    color: Colors.orange,
                  ),
                  const SizedBox(width: 2),
                  Text(
                    '${widget.ingredient.calories.toStringAsFixed(1)} kcal',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey[800],
                    ),
                  )
                ],
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 5),
                  // decoration: BoxDecoration(
                  //     color: Colors.red[100],
                  //     borderRadius: BorderRadius.circular(12),
                  //     // border: Border.all(color: Colors.red)
                  // ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.bolt,
                        size: 15,
                        color: Colors.red,
                      ),
                      const SizedBox(width: 2),
                      Text(
                        '${widget.ingredient.protein.toStringAsFixed(1)} g',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey[800],
                        ),
                      )
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 5),
                  // decoration: BoxDecoration(
                  //     color: Colors.brown[100],
                  //     borderRadius: BorderRadius.circular(12),
                  //     // border: Border.all(color: Colors.brown)
                  // ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.grain,
                        size: 15,
                        color: Colors.brown,
                      ),
                      const SizedBox(width: 2),
                      Text(
                        '${widget.ingredient.carbs.toStringAsFixed(1)} g',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey[800],
                        ),
                      )
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 5),
                  // decoration: BoxDecoration(
                  //     color: Colors.blue[100],
                  //     borderRadius: BorderRadius.circular(12),
                  //     // border: Border.all(color: Colors.blue)
                  // ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.water_drop_outlined,
                        size: 15,
                        color: Colors.blue,
                      ),
                      const SizedBox(width: 2),
                      Text(
                        '${widget.ingredient.fat.toStringAsFixed(1)} g',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey[800],
                        ),
                      )
                    ],
                  ),
                ),
                // Text(
                //   '${widget.ingredient.calories.toStringAsFixed(1)} cal',
                //   style: TextStyle(
                //     fontSize: 12,
                //     color: Colors.grey[600],
                //   ),
                // ),
                // const SizedBox(width: 8),
                // Text(
                //   '${widget.ingredient.protein.toStringAsFixed(1)}g protein',
                //   style: TextStyle(
                //     fontSize: 12,
                //     color: Colors.grey[600],
                //   ),
                // ),
              ],
            ),
          ],
        ),
      ),
    );
  }
} 