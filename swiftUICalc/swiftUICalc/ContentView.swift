//
//  ContentView.swift
//  swiftUICalc
//
//  Created by Young Soo Hwang on 2022/01/27.
//

import SwiftUI

enum CalculatorButton: String {
    
    case zero, one, two, three, four, five, six, seven, eight, nine, decimal
    case equals, plus, minus, multiply, divide
    case ac, plusMinus, percent
    
    var title: String {
        switch self {
        case .zero: return "0"
        case .one: return "1"
        case .two: return "2"
        case .three: return "3"
        case .four: return "4"
        case .five: return "5"
        case .six: return "6"
        case .seven: return "7"
        case .eight: return "8"
        case .nine: return "9"
        case .plus: return "+"
        case .minus: return "-"
        case .multiply: return "X"
        case .divide: return "/"
        case .plusMinus: return "+/-"
        case .percent: return "%"
        case .equals: return "="
        case .decimal: return "."
        default: return "AC"
        }
    }
    
    var background: Color {
        switch self {
        case .ac, .plusMinus, .percent:
            return Color(.lightGray)
        case .plus, .minus, .multiply, .divide, .equals:
            return Color(.darkGray)
        default:
            return Color("green")
        }
    }
    
}

// MARK: Env Objects
// I can treat this as the Global Application State

class GlobalEnvironment: ObservableObject {

    @Published var display = "0"
    @Published var expression: [String] = []
    
    func receiveInput(calculatorButton: CalculatorButton) {
        switch calculatorButton {
        case .ac, .plusMinus, .percent:
            expression = []
            self.display = ""
        case .plus, .minus, .multiply, .divide, .equals:
            if calculatorButton == .equals {
                calcInput()
            } else {
                expression.append(self.display)
                expression.append(calculatorButton.title)
                self.display = ""
            }
        default:
            if self.display != "0" && self.display != "오류" {
                self.display = self.display + calculatorButton.title
            } else {
                self.display = calculatorButton.title
            }
        }
    }
    
    // MARK: Calculate Inputs by expression
    func calcInput() {
        if expression.count == 2 {
            switch expression.popLast() {
            case "-":
                if let first = expression.popLast() {
                    let a = (first as NSString).floatValue
                    let b = (self.display as NSString).floatValue
                    self.display = String(a - b)
                }
            case "*":
                if let first = expression.popLast() {
                    let a = (first as NSString).floatValue
                    let b = (self.display as NSString).floatValue
                    self.display = String(a * b)
                }
            case "/":
                if let first = expression.popLast() {
                    if self.display == "0" {
                        self.display = "오류"
                    } else {
                        let a = (first as NSString).floatValue
                        let b = (self.display as NSString).floatValue
                        self.display = String(a / b)
                    }
                }
            default:
                if let first = expression.popLast() {
                    let a = (first as NSString).floatValue
                    let b = (self.display as NSString).floatValue
                    self.display = String(a + b)
                }
            }
        }
    }
    
}

struct ContentView: View {
    
    @EnvironmentObject var env: GlobalEnvironment
    
    let buttons: [[CalculatorButton]]  = [
        [.ac, .plusMinus, .percent, .divide],
        [.seven, .eight, .nine, .multiply],
        [.four, .five, .six, .minus],
        [.one, .two, .three, .plus],
        [.zero, .decimal, .equals]
    ]
    var body: some View {
        
        ZStack (alignment: .bottom){
            Color.black.edgesIgnoringSafeArea(.all)
            VStack (spacing: 12) {
                HStack {
                    Spacer()
                    Text(env.display).foregroundColor(.white)
                        .font(.system(size: 64))
                }.padding()
                ForEach(buttons, id: \.self) { row in
                    HStack {
                        ForEach(row, id: \.self) { button in
                            CalculatorButtonView(button: button)
                        }
                    }
                }
            }.padding(.bottom)
        }
    }

}

struct CalculatorButtonView: View {
    
    var button: CalculatorButton
    
    @EnvironmentObject var env: GlobalEnvironment
    
    var body: some View {
        Button(action: {
            
            self.env.receiveInput(calculatorButton: button)
            
        }) {
        Text(button.title)
            .font(.system(size: 32))
            .frame(width: self.buttonWidth(button), height: (UIScreen.main.bounds.width - 5 * 12) / 4)
                .foregroundColor(.white)
                .background(button.background)
                .cornerRadius(30)
        }
    }
    
    private func buttonWidth(_ button: CalculatorButton) -> CGFloat {
        if button == .zero {
            return (UIScreen.main.bounds.width - 4 * 12) / 4 * 2
        }
        return (UIScreen.main.bounds.width - 5 * 12) / 4
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().environmentObject(GlobalEnvironment()).previewInterfaceOrientation(.portrait)
    }
}
