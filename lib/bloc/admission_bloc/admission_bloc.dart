import 'package:flutter_bloc/flutter_bloc.dart';

part 'admission_event.dart';
part 'admission_state.dart';

class AdmissionBloc extends Bloc<AdmissionEvent, AdmissionState> {
  AdmissionBloc() : super(AdmissionInitial()) {
    // Registering the event handler
    on<MarkAsCompleteClicked>(_onMarkAsCompleteClicked);
    on<MarkAsResultPassedClicked>(_onMarkAsResultPassedClicked);
    on<IsLoadingClicked>(_isLoadingClicked);
    on<RemarksIsLoadingClicked>(_remarksIsLoadingClicked);
  }

  // Event handler for MarkAsCompleteClicked
  void _onMarkAsCompleteClicked(
      MarkAsCompleteClicked event, Emitter<AdmissionState> emit) {
    try {
      // Emit the updated state based on the value of isComplete
      emit(AdmissionStatusUpdated(event.isComplete));
    } catch (e) {
      // In case of an error, emit a failure state
      emit(AdmissionFailure('Failed to update admission status'));
    }
  }

  void _onMarkAsResultPassedClicked(
      MarkAsResultPassedClicked event, Emitter<AdmissionState> emit) {
    try {
      // Emit the updated state based on the value of isComplete
      emit(AdmissionResultUpdated(event.isResult, event.isPassed, event.isComplete));
    } catch (e) {
      // In case of an error, emit a failure state
      emit(AdmissionFailure('Failed to update admission status'));
    }
  }

  void _isLoadingClicked(
      IsLoadingClicked event, Emitter<AdmissionState> emit) {
    try {
      // Emit the updated state based on the value of isComplete
      emit(AdmissionIsLoading(event.isLoading));
    } catch (e) {
      // In case of an error, emit a failure state
      emit(AdmissionFailure('Failed to update admission status'));
    }
  }


  void _remarksIsLoadingClicked(
      RemarksIsLoadingClicked event, Emitter<AdmissionState> emit) {
    try {
      // Emit the updated state based on the value of isComplete
      emit(AdmissionRemarksIsLoading(event.isLoading));
    } catch (e) {
      // In case of an error, emit a failure state
      emit(AdmissionFailure('Failed to update admission status'));
    }
  }
}
