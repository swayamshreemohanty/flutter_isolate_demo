// ignore_for_file: public_member_api_docs, sort_constructors_first
part of 'calculator_cubit.dart';

class CalculatorState {
  final int number;
  final bool isLoading;

  const CalculatorState({
    required this.number,
    this.isLoading = false,
  });

  CalculatorState copyWith({int? number, bool? isLoading}) {
    return CalculatorState(
      number: number ?? this.number,
      isLoading: isLoading ?? false,
    );
  }
}
