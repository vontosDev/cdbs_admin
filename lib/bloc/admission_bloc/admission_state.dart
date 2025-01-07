part of 'admission_bloc.dart';

abstract class AdmissionState {}

class AdmissionInitial extends AdmissionState {}

class AdmissionStatusUpdated extends AdmissionState {
  final bool isComplete;

  AdmissionStatusUpdated(this.isComplete);
}

class AdmissionFailure extends AdmissionState {
  final String error;

  AdmissionFailure(this.error);
}


class AdmissionResultUpdated extends AdmissionState {
  final bool isComplete;
  final bool isResult;  // Whether the result is available (true or false)
  final bool isPassed;  // Whether the person has passed (true or false)

  AdmissionResultUpdated(
     this.isResult,  // The result is available (true or false)
     this.isPassed,  // The result is passed (true or false)
     this.isComplete
  );
}


class AdmissionIsLoading extends AdmissionState {
  final bool isLoading;

  AdmissionIsLoading(this.isLoading);
}


class AdmissionRemarksIsLoading extends AdmissionState {
  final bool isLoading;

  AdmissionRemarksIsLoading(this.isLoading);
}