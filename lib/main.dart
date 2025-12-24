import 'package:flutter/material.dart';
import 'package:math_expressions/math_expressions.dart';

void main() {
  runApp(const CalculatorApp());
}

class CalculatorApp extends StatelessWidget {
  const CalculatorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const CalculatorScreen(),
    );
  }
}

class CalculatorScreen extends StatefulWidget {
  const CalculatorScreen({super.key});

  @override
  State<CalculatorScreen> createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends State<CalculatorScreen> {
  String input = "";
  String result = "0";

  final List<String> operators = ['+', '-', '*', '/', '^'];

  @override
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.of(context).size.height;
    final double buttonsHeight = screenHeight * 0.5;

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 19, 3, 13),
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(20),
                alignment: Alignment.bottomRight,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      input,
                      style: const TextStyle(
                        fontSize: 32,
                        color: Colors.white70,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      result,
                      style: const TextStyle(
                        fontSize: 48,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // дурацкие кнопки
            SizedBox(
              height: buttonsHeight,
              child: Column(
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        buildButton("C"),
                        buildButton("DEL"),
                        buildButton("("),
                        buildButton(")"),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Row(
                      children: [
                        buildButton("/"),
                        buildButton("*"),
                        buildButton("-"),
                        buildButton("+"),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Row(
                      children: [
                        buildButton("7"),
                        buildButton("8"),
                        buildButton("9"),
                        buildButton("√"),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Row(
                      children: [
                        buildButton("4"),
                        buildButton("5"),
                        buildButton("6"),
                        buildButton("^"),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Row(
                      children: [
                        buildButton("1"),
                        buildButton("2"),
                        buildButton("3"),
                        buildButton("."),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Row(
                      children: [
                        buildButton("0", flex: 2),
                        buildButton("=", flex: 2),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildButton(String text, {int flex = 1}) {
    Color backgroundColor = const Color.fromARGB(255, 178, 178, 178);
    const Color textColor = Colors.white;

    if (text == "C" || text == "DEL") {
      backgroundColor = const Color.fromARGB(255, 1, 1, 167);
    } else if (["=", "/", "*", "-", "+", "√", "^", "."].contains(text)) {
      backgroundColor = const Color.fromARGB(255, 59, 163, 255);
    } else if (text == "(" || text == ")") {
      backgroundColor = const Color.fromARGB(255, 1, 56, 255);
    }

    return Expanded(
      flex: flex,
      child: GestureDetector(
        onTap: () => onButtonPressed(text),
        child: Container(
          margin: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(15),
          ),
          child: Center(
            child: Text(
              text,
              style: const TextStyle(
                color: textColor,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Проверка на точки
  bool hasDotInCurrentNumber(String expression) {
    if (expression.isEmpty) return false;

    const List<String> separators = ['+', '-', '*', '/', '^', '(', ')'];

    int i = expression.length - 1;
    while (i >= 0 && !separators.contains(expression[i])) {
      i--;
    }

    final String lastPart = expression.substring(i + 1);
    return lastPart.contains('.');
  }

  // корень
  String replaceRootSymbol(String expression) {
    String updated = expression;

    while (updated.contains('√')) {
      final int pos = updated.indexOf('√');

      if (pos == updated.length - 1) {
        updated = updated.replaceFirst('√', '');
        continue;
      }

      final String before = updated.substring(0, pos);
      final String after = updated.substring(pos + 1);

      // никаких скобок с корнем
      if (after.startsWith('(')) {
        int depth = 0;
        int endIndex = 0;

        for (int i = 0; i < after.length; i++) {
          if (after[i] == '(') depth++;
          if (after[i] == ')') depth--;
          if (depth == 0) {
            endIndex = i;
            break;
          }
        }

        final String insideBrackets = after.substring(0, endIndex + 1);
        final String rest = after.substring(endIndex + 1);
        updated = before + 'sqrt' + insideBrackets + rest;
      } else {
        const List<String> ops = ['+', '-', '*', '/', '^'];
        int i = 0;
        while (i < after.length && !ops.contains(after[i])) {
          i++;
        }

        final String numberPart = after.substring(0, i);
        final String rest = after.substring(i);
        updated = before + 'sqrt(' + numberPart + ')' + rest;
      }
    }

    return updated;
  }

  void onButtonPressed(String button) {
    setState(() {
      if (button == "C") {
        input = "";
        result = "0";
        return;
      }

      if (button == "DEL") {
        if (input.isNotEmpty) {
          input = input.substring(0, input.length - 1);
        }
        return;
      }

      if (button == "=") {
        calculateResult();
        return;
      }

      if (button == ".") {
        if (input.isEmpty) {
          input = "0.";
        } else if (!hasDotInCurrentNumber(input)) {
          input += ".";
        }
        return;
      }

      if (operators.contains(button)) {
        handleOperator(button);
        return;
      }

      if (button == "(" || button == ")") {
        input += button;
        return;
      }

      input += button;
    });
  }

  void handleOperator(String operator) {
    if (input.isEmpty) {
      if (operator == "-") {
        input = "-";
      }
      return;
    }

    final String lastChar = input[input.length - 1];

    if (operators.contains(lastChar)) {
      input = input.substring(0, input.length - 1) + operator;
    } else {
      input += operator;
    }
  }

  void calculateResult() {
    try {
      if (input.isEmpty) {
        result = "0";
        return;
      }

      String expression = replaceRootSymbol(input);

      final int openBrackets = expression.split('(').length - 1;
      final int closeBrackets = expression.split(')').length - 1;
      int diff = openBrackets - closeBrackets;
      while (diff > 0) {
        expression += ")";
        diff--;
      }

      final Parser parser = Parser();
      final Expression exp = parser.parse(expression);
      final ContextModel context = ContextModel();
      final double value = exp.evaluate(EvaluationType.REAL, context);

      if (value.isInfinite || value.isNaN) {
        result = "Ошибка";
      } else if (value % 1 == 0) {
        result = value.toInt().toString();
      } else {
        result = value.toString();
      }
    } catch (_) {
      result = "Ошибка";
    }
  }
}
