import 'package:flutter/material.dart';
import '../../../models/widgets/footer_data.dart';
import '../../../constants.dart';

class FooterWidget extends StatefulWidget {
  final List<FooterItemData> footerItems;
  final Function(String action)? onTap;

  const FooterWidget({
    super.key,
    required this.footerItems,
    this.onTap,
  });

  @override
  State<FooterWidget> createState() => _FooterWidgetState();
}

class _FooterWidgetState extends State<FooterWidget> {
  late List<FooterItemData> _footerItems;

  @override
  void initState() {
    super.initState();
    _footerItems = List.from(widget.footerItems);
  }

  void _handleTap(String action) {
    setState(() {
      _footerItems = _footerItems.map((item) {
        return FooterItemData(
          active: item.action == action,
          icon: item.icon,
          title: item.title,
          action: item.action,
        );
      }).toList();
    });
    widget.onTap?.call(action);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 70,
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: Colors.grey, width: 0.2),
        ),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 16,
            offset: Offset(0, -3),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: _footerItems.map((item) => _buildFooterItem(item)).toList(),
      ),
    );
  }

  Widget _buildFooterItem(FooterItemData item) {
    return GestureDetector(
      onTap: () => _handleTap(item.action),
      child: Container(
        padding: const EdgeInsets.only(bottom: 8, left: 16, right: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Active indicator line
            Container(
              height: 5,
              width: 40,
              decoration: BoxDecoration(
                color: item.active ? Colors.black : Colors.transparent,
                borderRadius: BorderRadius.only(bottomLeft: Radius.circular(5), bottomRight: Radius.circular(5)),
              ),
            ),
            const SizedBox(height: 6),
            Icon(
              _iconForName(item.icon),
              size: 28,
              color: item.active ? Colors.black : Colors.grey[600],
            ),
            const SizedBox(height: 4),
            Text(
              item.title,
              style: TextStyle(
                fontSize: 12,
                fontWeight: item.active ? FontWeight.w600 : FontWeight.w500,
                color: item.active ? Colors.black : Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _iconForName(String iconName) {
    switch (iconName) {
      case 'home':
        return Icons.home_outlined;
      case 'progress':
        return Icons.trending_up;
      case 'settings':
        return Icons.settings_outlined;
      default:
        return Icons.circle_outlined;
    }
  }
}
