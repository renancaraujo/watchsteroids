import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

class RotationCubit extends Cubit<RotationState> {
  RotationCubit() : super(const RotationState.initial());

  void rotateBy(double delta) {
    emit(RotationState(state.shipAngle + delta));
  }

  void rotateTo(double rotation) {
    emit(RotationState(rotation));
  }
}

class RotationState extends Equatable {
  const RotationState(this.shipAngle);

  const RotationState.initial() : this(0);

  final double shipAngle;

  @override
  List<Object> get props => [shipAngle];
}
