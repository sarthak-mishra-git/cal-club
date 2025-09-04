import 'package:bloc/bloc.dart';
import '../../models/widgets/footer_data.dart';
import 'footer_event.dart';
import 'footer_state.dart';

class FooterBloc extends Bloc<FooterEvent, FooterState> {
  List<FooterItemData> _footerItems = [];

  FooterBloc({required List<FooterItemData> footerItems}) : super(FooterLoaded(footerItems)) {
    _footerItems = footerItems;
    on<UpdateActiveTab>(_onUpdateActiveTab);
  }

  void _onUpdateActiveTab(
    UpdateActiveTab event,
    Emitter<FooterState> emit,
  ) {
    final updatedItems = _footerItems.map((item) {
      return FooterItemData(
        active: item.action == event.action,
        icon: item.icon,
        title: item.title,
        action: item.action,
      );
    }).toList();
    _footerItems = updatedItems;
    emit(FooterLoaded(_footerItems));
  }
}
