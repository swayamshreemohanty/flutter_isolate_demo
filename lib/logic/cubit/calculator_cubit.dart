import 'dart:async';
import 'dart:isolate';
import 'package:flutter_bloc/flutter_bloc.dart';
part 'calculator_state.dart';

class CalculatorCubit extends Cubit<CalculatorState> {
  CalculatorCubit() : super(const CalculatorState(number: 0));

  Future<void> calculateSumOnMainThread(int number) async {
    emit(state.copyWith(isLoading: true));
    emit(state.copyWith(number: calculate(number)));
  }

  Future<void> calculateSumOnSeparateIsolate(int number) async {
    emit(state.copyWith(isLoading: true));
    final receivePort = ReceivePort();
    await Isolate.spawn(runInIsolate, receivePort.sendPort);
    final sendPort = await receivePort.first as SendPort;
    final responsePort = ReceivePort();

    //
    responsePort.listen((response) {
      emit(state.copyWith(number: response));
    });
    //
    sendPort.send([number, responsePort.sendPort]);
  }

  static void runInIsolate(SendPort sendPort) {
    final receivePort = ReceivePort();
    sendPort.send(receivePort.sendPort);

    receivePort.listen((message) async {
      final data = message[0] as int;
      final responsePort = message[1] as SendPort;

      // Return the result to the main isolate
      final sum = calculate(data);
      responsePort.send(sum);
    });
  }

  static int calculate(int number) {
    // Perform some calculations using the received data
    int sum = 0;
    for (var i = 0; i <= number; i++) {
      sum += i;
      print(sum);
    }
    return sum;
  }
}
