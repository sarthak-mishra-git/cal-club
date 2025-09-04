import 'package:equatable/equatable.dart';
import '../../models/widgets/footer_data.dart';

abstract class FooterState extends Equatable {
  const FooterState();

  @override
  List<Object?> get props => [];
}

class FooterLoaded extends FooterState {
  final List<FooterItemData> footerItems;
  const FooterLoaded(this.footerItems);

  @override
  List<Object?> get props => [footerItems];
}
