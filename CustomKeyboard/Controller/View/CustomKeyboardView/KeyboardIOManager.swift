//
//  KeyboardIOManager.swift
//  CustomKeyboard
//
//  Created by CHUBBY on 2022/07/13.
//

import Foundation

struct Hangul {
    let cho:[String] = ["ㄱ","ㄲ","ㄴ","ㄷ","ㄸ","ㄹ","ㅁ","ㅂ","ㅃ","ㅅ","ㅆ","ㅇ","ㅈ","ㅉ","ㅊ","ㅋ","ㅌ","ㅍ","ㅎ"]

    let jung:[String] = ["ㅏ", "ㅐ", "ㅑ", "ㅒ", "ㅓ", "ㅔ", "ㅕ", "ㅖ", "ㅗ", "ㅘ", "ㅙ", "ㅚ", "ㅛ", "ㅜ", "ㅝ","ㅞ", "ㅟ", "ㅠ", "ㅡ", "ㅢ", "ㅣ"]
    let jong:[String] = [" ", "ㄱ", "ㄲ", "ㄳ", "ㄴ", "ㄵ", "ㄶ", "ㄷ", "ㄹ", "ㄺ", "ㄻ", "ㄼ", "ㄽ", "ㄾ", "ㄿ","ㅀ", "ㅁ", "ㅂ", "ㅄ", "ㅅ", "ㅆ", "ㅇ", "ㅈ", "ㅊ", "ㅋ", "ㅌ", "ㅍ", "ㅎ"]

    let twiceJungIndexAndValue: [(String, Int)] = [("ㅗㅏ", 9), ("ㅗㅐ", 10), ("ㅗㅣ", 11), ("ㅜㅓ", 14), ("ㅜㅔ", 15), ("ㅜㅣ", 16), ("ㅡㅣ", 19)]

    let twiceJongIndexAndValue: [(String, Int)] = [("ㄱㅅ", 3), ("ㄴㅈ", 5), ("ㄴㅎ", 6), ("ㄹㄱ", 9), ("ㄹㅁ", 10), ("ㄹㅂ", 11), ("ㄹㅅ", 12), ("ㄹㅌ", 13), ("ㄹㅍ", 14), ("ㄹㅎ", 15), ("ㅂㅅ", 18), ("ㅅㅅ", 20)]

    lazy var twiceJungValue = twiceJungIndexAndValue.map { $0.0 }
    lazy var twiceJongValue = twiceJongIndexAndValue.map { $0.0 }
}

class KeyboardIOManager {
    var input: String = "" {
        didSet {
            inputCaracter(input)
        }
    }
    var text: String = ""
    
    var inputCaracter: ((String) -> Void)!
    var deleteCaracter: ((String) -> Void)!
    
    // extension
    private var hangul = Hangul()
    private var inputQueue = [String]()
    private var sliceInputQueue = [[String]]()
    // extension
}

extension KeyboardIOManager: CustomKeyboardDelegate {
    func hangulKeypadTap(char: String) {
        inputQueue.append(char)
        print(inputQueue)
        let joinHangul = join(queue: inputQueue)
//        input = join(queue: inputQueue)
        inputCaracter(joinHangul)
    }
    
    func backKeypadTap() {
        if !inputQueue.isEmpty {
            inputQueue.removeLast()
        } else {
            // Todo: 텍스트뷰 마지막 단어 받아와서 분해후 큐에 집어넣고 삭제
        }
        guard let lastCaracter = join(queue: inputQueue).last else { return }
        deleteCaracter(String(lastCaracter))
        
//        sliceInputQueue[sliceInputQueue.count - 1].removeLast()
//        input = joinHangul(inputListMap: sliceInputQueue)
        
    }
    
    func enterKeypadTap() {
        
    }
    
    /*
     ㄱㅏㅁㅈㅏ
     감자
     0. 감자
     1. 감ㅈ
     2. 감
     3. 가
     4. ㄱ
     5.
     */
    
    func spaceKeypadTap() {
        
    }
}

// MARK: - automata
extension KeyboardIOManager {
    func sliceInputQueue(queue: [String]) -> [[String]] {
        let queue = queue
        var isFlag = false
        var buffer = [String]()
        var inputListMap = [[String]]()
        
        for (index, input) in queue.enumerated() {
            if isFlag { isFlag = false; continue }
            // buffer가 비었을경우
            if buffer.isEmpty {
                // input이 cho 일시 input을 buffer.append
                if hangul.cho.contains(input) {
                    buffer.append(input)
                } else {
                    // inputListMap이 비지 않았고 마지막의 마지막 원소가 cho인데
                    // input이 jung일때 inputListMap의 마지막의 마지막 원소를 빼서
                    // buffer 에 append 하고 input도 append
                    if !inputListMap.isEmpty,
                       hangul.cho.contains(inputListMap.last!.last!) {
                        let chosung = inputListMap[inputListMap.count - 1].removeLast()
                        buffer.append(chosung)
                        if index < queue.count - 1 &&
                            hangul.twiceJungValue.contains(input + queue[index + 1]) {
                            let target = input + queue[index + 1]
                            let targetIndex = hangul.twiceJungValue.firstIndex(of: target)!
                            buffer.append(hangul.jung[hangul.twiceJungIndexAndValue[targetIndex].1])
                            isFlag = true
                        } else {
                            buffer.append(input)
                        }
                    } else if !inputListMap.isEmpty,
                              hangul.jong.contains(inputListMap.last!.last!) {
                        inputListMap[inputListMap.count - 1].removeLast()
                        inputListMap[inputListMap.count - 1].append(queue[index - 2])
                        buffer.append(queue[index - 1])
                        buffer.append(input)
                    } else {
                        if index < queue.count - 1 &&
                            hangul.twiceJungValue.contains(input + queue[index + 1]) {
                            let target = input + queue[index + 1]
                            let targetIndex = hangul.twiceJungValue.firstIndex(of: target)!
                            buffer.append(hangul.jung[hangul.twiceJungIndexAndValue[targetIndex].1])
                            isFlag = true
                        } else {
                            buffer.append(input)
                        }
                    }
                }
                continue
                // buffer가 한개 차있을경우 그리고 그 버퍼가 cho이면서 input이 jung일경우
            } else if buffer.count == 1 {
                if hangul.cho.contains(buffer[0]),
                   hangul.jung.contains(input) {
                    
                    if index < queue.count - 1 &&
                        hangul.twiceJungValue.contains(input + queue[index + 1]) {
                        let target = input + queue[index + 1]
                        print(target)
                        let targetIndex = hangul.twiceJungValue.firstIndex(of: target)!
                        buffer.append(hangul.jung[hangul.twiceJungIndexAndValue[targetIndex].1])
                        isFlag = true
                    } else {
                        // buffer에 input append
                        buffer.append(input)
                    }
                    continue
                    // 아닐경우
                } else if hangul.twiceJungValue.contains(buffer.last! + input) {
                    let target = buffer.removeLast() + input
                    let targetIndex = hangul.twiceJungValue.firstIndex(of: target)!
                    buffer.append(hangul.jung[hangul.twiceJungIndexAndValue[targetIndex].1])
                    isFlag = true
                    continue
                } else {
                    // buffer를 inputListMap에 append 한 후 초기화 후 input append
                    inputListMap.append(buffer)
                    buffer.removeAll()
                    buffer.append(input)
                    continue
                }
                // 버퍼가 두개 차있고 마지막 원소가 jung이면서 input이 jong일경우
            } else if buffer.count == 2 {
                if hangul.jung.contains(buffer[1]),
                   hangul.jong.contains(input) {
                    if index < queue.count - 1 &&
                        hangul.twiceJongValue.contains(input + queue[index + 1]) {
                        //                    buffer.removeLast()
                        let target = input + queue[index + 1]
                        let targetIndex = hangul.twiceJongValue.firstIndex(of: target)!
                        buffer.append(hangul.jong[hangul.twiceJongIndexAndValue[targetIndex].1])
                        isFlag = true
                    } else {
                        // buffer에 input append
                        buffer.append(input)
                    }
                    // buffer가 꽉 찼으므로 inputListMap에 append 하고 초기화
                    inputListMap.append(buffer)
                    buffer.removeAll()
                    continue
                    // 아닐경우
                } else {
                    // inputListMap에 buffer append하고 초기화 후 input append
                    inputListMap.append(buffer)
                    buffer.removeAll()
                    buffer.append(input)
                }
            }
        }
        // 혹시 buffer에 데이터가 남아있을경우 inputListMap에 append
        if !buffer.isEmpty { inputListMap.append(buffer) }
        print(inputListMap)
        self.sliceInputQueue = inputListMap
        return inputListMap
    }
    
    
    func joinHangul(inputListMap: [[String]]) -> String {
        var result = ""
        
        // 조합
        inputListMap.forEach { buffer in
            // buffer가 3개 다있을경우 초성, 중성, 종성 계산해서 조합
            if buffer.count == 3 {
                let chosung = hangul.cho.firstIndex(of: buffer[0])!
                let jungsung = hangul.jung.firstIndex(of: buffer[1])!
                let jongsung = hangul.jong.firstIndex(of: buffer[2])!
                let joinChar = (chosung * 21 + jungsung) * 28 + jongsung + 0xAC00
                if let uni = Unicode.Scalar(joinChar) {
                    result += String(uni)
                }
                // buffer가 두개있을경우 초성, 중성만 계산해서 조합
            } else if buffer.count == 2 {
                let chosung = hangul.cho.firstIndex(of: buffer[0])!
                let jungsung = hangul.jung.firstIndex(of: buffer[1])!
                let joinChar = (chosung * 21 + jungsung) * 28 + 0xAC00
                if let uni = Unicode.Scalar(joinChar) {
                    result += String(uni)
                }
                // buffer가 한개일경우 그냥 사용
            } else if buffer.count == 1 {
                result += buffer.first!
            }
        }
        print(result)
//        input = result
        return result
    }

    func join(queue: [String]) -> String {
        let sliceInputQueue = sliceInputQueue(queue: queue)
        return joinHangul(inputListMap: sliceInputQueue)
    }
}
