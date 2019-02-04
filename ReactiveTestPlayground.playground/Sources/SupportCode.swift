import Foundation
import RxSwift
import RxCocoa

public func delay(_ delay: TimeInterval, closure: @escaping ()->()) {
    DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
        closure()
    }
}

public func calculate1() -> Int {
    print("Lazy function invoked")
    return 1
}

#if NOT_IN_PLAYGROUND

public func playgroundTimeLimit(seconds: TimeInterval) {
}

#else

import PlaygroundSupport
public func playgroundTimeLimit(seconds: TimeInterval) {
    PlaygroundPage.current.needsIndefiniteExecution = true
    delay(seconds) {
        PlaygroundPage.current.finishExecution()
    }
}

#endif

