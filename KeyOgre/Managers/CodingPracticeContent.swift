// ABOUTME: Practice code content for different programming languages with lines under 30 characters
// ABOUTME: Provides realistic code samples for Python and JavaScript typing practice

import Foundation

struct CodingPracticeContent {
    
    static let pythonCode = [
        "def fibonacci(n):",
        "    if n <= 1:",
        "        return n",
        "    a, b = 0, 1",
        "    for i in range(2, n + 1):",
        "        a, b = b, a + b",
        "    return b",
        "",
        "result = fibonacci(10)",
        "print(f\"Fib(10): {result}\")",
        "",
        "nums = [1, 2, 3, 4, 5]",
        "for i, num in enumerate(nums):",
        "    if num % 2 == 0:",
        "        print(f\"{i}: even\")",
        "    else:",
        "        print(f\"{i}: odd\")",
        "",
        "class Calculator:",
        "    def __init__(self):",
        "        self.result = 0",
        "",
        "    def add(self, x):",
        "        self.result += x",
        "        return self",
        "",
        "calc = Calculator()",
        "calc.add(5).add(3)",
        "print(calc.result)"
    ]
    
    static let javascriptCode = [
        "function factorial(n) {",
        "    if (n <= 1) return 1;",
        "    return n * factorial(n - 1);",
        "}",
        "",
        "const nums = [1, 2, 3, 4, 5];",
        "const result = nums.filter(n => ",
        "    n % 2 === 0",
        ");",
        "",
        "console.log(result);",
        "",
        "for (let item of result) {",
        "    console.log(`Even: ${item}`);",
        "}",
        "",
        "class Timer {",
        "    constructor() {",
        "        this.seconds = 0;",
        "    }",
        "",
        "    tick() {",
        "        this.seconds++;",
        "        return this;",
        "    }",
        "",
        "    getTime() {",
        "        return this.seconds;",
        "    }",
        "}",
        "",
        "const timer = new Timer();",
        "timer.tick().tick();",
        "console.log(timer.getTime());"
    ]
    
    func getCodeLines(for language: ProgrammingLanguage) -> [String] {
        switch language {
        case .python:
            return Self.pythonCode
        case .javascript:
            return Self.javascriptCode
        }
    }
}