import 'dart:async';
import 'dart:isolate';
import 'dart:ui';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
part 'calculator_state.dart';

class CalculatorCubit extends Cubit<CalculatorState> {
  CalculatorCubit() : super(const CalculatorState(number: 0));

  void emitNumber(int number) {
    print("#######: $number");
    emit(state.copyWith(number: number));
  }

  Future<void> calculateSumUsingCompute(int number) async {
    emit(state.copyWith(isLoading: true));
    final calculatedNumber = await compute(calculate, number);
    emitNumber(calculatedNumber);
  }

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
      //Only for testing
      ///Looking up for a send port
      // SendPort sendLookUpPort =
      //     IsolateNameServer.lookupPortByName("calculate")!;
      ///sending the data to the screen
      // sendLookUpPort.send(response);
      emitNumber(response);
    });
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
    //find for the registered isolate
    final sendLookUpPort = IsolateNameServer.lookupPortByName("calculate");

    // Perform some calculations using the received data
    int sum = 0;

    //start the calculation
    for (var i = 0; i <= number; i++) {
      sum += i;

      //Send the realtime calculation data to screen
      if (sendLookUpPort != null) {
        sendLookUpPort.send(sum);
      }
    }
    return sum;
  }
}
