import 'dart:isolate';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:isolate_test/logic/cubit/calculator_cubit.dart';

class CalculatorScreen extends StatefulWidget {
  const CalculatorScreen({super.key});

  @override
  State<CalculatorScreen> createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends State<CalculatorScreen> {
  final numberTextController = TextEditingController();
  int lastEnteredNumber = 0;

  ReceivePort registerReceivePort = ReceivePort();
  @override
  void initState() {
    ///register a send port for the other isolates
    IsolateNameServer.registerPortWithName(
        registerReceivePort.sendPort, "calculate");

    ///Listening for the data is comming other isolataes
    registerReceivePort.listen((message) {
      final number = int.tryParse(message.toString()) ?? 0;
      context.read<CalculatorCubit>().emitNumber(number);
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Sum of number"),
      ),
      body: BlocBuilder<CalculatorCubit, CalculatorState>(
        builder: (context, state) {
          return Column(
            children: <Widget>[
              Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 30, horizontal: 10),
                child: TextField(
                  controller: numberTextController,
                  inputFormatters: [
                    LengthLimitingTextInputFormatter(10),
                    FilteringTextInputFormatter.digitsOnly,
                  ],
                  decoration: const InputDecoration(
                      hintText: "Enter number to find sum"),
                  keyboardType: TextInputType.phone,
                  onChanged: (value) {
                    setState(() {});
                  },
                ),
              ),
              ElevatedButton(
                onPressed: numberTextController.text.isEmpty || state.isLoading
                    ? null
                    : () async {
                        //Close soft keyboard
                        FocusScope.of(context).unfocus();
                        lastEnteredNumber =
                            int.tryParse(numberTextController.text) ?? 0;

                        //Calculate
                        context
                            .read<CalculatorCubit>()
                            // .calculateSumOnMainThread(lastEnteredNumber);
                            .calculateSumOnSeparateIsolate(lastEnteredNumber);
                        // .calculateSumUsingCompute(lastEnteredNumber);
                        //
                        //reset controller
                        numberTextController.clear();
                      },
                child: const Text("Start sum"),
              ),
              if (lastEnteredNumber != 0)
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          'Sum of the number till $lastEnteredNumber',
                          style: const TextStyle(fontSize: 16),
                        ),
                      ),
                      const SizedBox(height: 10),
                      state.isLoading
                          ? const CircularProgressIndicator()
                          : Text("${state.number}",
                              style: const TextStyle(fontSize: 40)),
                    ],
                  ),
                )
            ],
          );
        },
      ),
    );
  }
}
