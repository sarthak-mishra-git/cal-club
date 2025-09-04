import 'package:equatable/equatable.dart';

abstract class FooterEvent extends Equatable {
  const FooterEvent();

  @override
  List<Object?> get props => [];
}

class UpdateActiveTab extends FooterEvent {
  final String action;
  const UpdateActiveTab(this.action);

  @override
  List<Object?> get props => [action];
}
