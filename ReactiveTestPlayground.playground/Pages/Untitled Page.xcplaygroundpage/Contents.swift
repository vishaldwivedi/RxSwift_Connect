import UIKit
import RxCocoa
import RxSwift

// When to use Rx

/*Use Rx for orchestrating asynchronous and event-based computations
 Code that deals with more than one event or asynchronous computation gets complicated quickly as it needs to build a state-machine to deal with ordering issues. Next to this, the code needs to deal with successful and failure termination of each separate computation. This leads to code that doesn’t follow normal control-flow, is hard to understand and hard to maintain.
 Rx makes these computations first-class citizens. This provides a model that allows for readable and composable APIs to deal with these asynchronous computations. */

/*Use Rx to deal with asynchronous sequences of data*/

//Best practice for designing with Rx in Mind

//Consider drawing a Marble-diagram

//https://rxmarbles.com/

//Types of observables

/*“Hot” and “Cold” Observables
 When does an Observable begin emitting its sequence of items? It depends on the Observable. A “hot” Observable may begin emitting items as soon as it is created, and so any observer who later subscribes to that Observable may start observing the sequence somewhere in the middle. A “cold” Observable, on the other hand, waits until an observer subscribes to it before it begins to emit items, and so such an observer is guaranteed to see the whole sequence from the beginning.
 
 In some implementations of ReactiveX, there is also something called a “Connectable” Observable. Such an Observable does not begin emitting items until its Connect method is called, whether or not any observers have subscribed to it.*/

//https://github.com/ReactiveX/RxSwift/blob/master/Documentation/HotAndColdObservables.md

//Subject
//A Subject is a special form of an Observable Sequence, you can subscribe and dynamically add elements to it. There are currently 4 different kinds of Subjects in RxSwift

/*PublishSubject: If you subscribe to it you will get all the events that will happen after you subscribed.
 BehaviourSubject: A behavior subject will give any subscriber the most recent element and everything that is emitted by that sequence after the subscription happened.
 ReplaySubject: If you want to replay more than the most recent element to new subscribers on the initial subscription you need to use a ReplaySubject. With a ReplaySubject, you can define how many recent items you want to emit to new subscribers.
 Variable: A Variable is just a BehaviourSubject wrapper that feels more natural to a non reactive programmers. It can be used like a normal Variable.*/

var publishSubject = PublishSubject<String>()
publishSubject.onNext("Hello")
publishSubject.onNext("World")
let subscription1 = publishSubject.subscribe(onNext:{
    print(#line,$0)
})
// Subscription1 receives these 2 events, Subscription2 won't
publishSubject.onNext("Hello")
publishSubject.onNext("Again")
// Sub2 will not get "Hello" and "Again" because it susbcribed later
let subscription2 = publishSubject.subscribe(onNext:{
    print(#line,$0)
})
publishSubject.onNext("Both Subscriptions receive this message")

//Relay
/*RxCocoa provides two kinds of Relays: PublishRelay and BehaviorRelay. They behave exactly like their parallel Subjects, with two changes:
 
 Relays never complete.
 Relays never emit errors.
 In essence, Relays only emit .next events, and never terminate.*/

// Some prominent operators

/*Creating Observables
 Create, Defer, Empty/Never/Throw, From, Interval, Just, Range, Repeat, Start, and Timer*/

//Creating and iterting an observable

let bag = DisposeBag()

let helloSequence = Observable.from([0,1,1,2,3,5,8])
let subscription = helloSequence.subscribe { event in
    print(event)
}

let sequence = Observable.from(["H","e","l","l","o"])
let sequenceSubscription = sequence.subscribe { event in
    switch event {
    case .next(let value):
        print(value)
    case .error(let error):
        print(error)
    case .completed:
        print("completed")
    }
}

subscription.disposed(by: bag)
sequenceSubscription.disposed(by: bag)

/*Transforming Observable Items
 Buffer, FlatMap, GroupBy, Map, Scan, and Window*/

Observable<Int>.of(1,2,3,4).map { value in
    return value * 10
    }.subscribe(onNext:{
        print($0)
    })

/*Filtering Observables
 Debounce, Distinct, ElementAt, Filter, First, IgnoreElements, Last, Sample, Skip, SkipLast, Take, and TakeLast*/

Observable.of(2,30,22,5,60,1).filter{$0 > 10}.subscribe(onNext:{
    print($0)
})

/*Combining Observables
 And/Then/When, CombineLatest, Join, Merge, StartWith, Switch, and Zip*/

//combineLatest
//Can be easily used for validation

let a = BehaviorRelay<Int>(value: 1)
let b = BehaviorRelay<Int>(value: 2)

let c = Observable.combineLatest(a,b) {$0 + $1}
    .filter {$0 > 0}
    .map {"\($0) is positive"}
c.subscribe(onNext: {print($0)})
a.accept(4)  // Will print as value is positive
b.accept(-8) // Will not print as value becomes negative

/*Error Handling Operators
 Catch and Retry
 
 Utility Operators
 Delay, Do, Materialize/Dematerialize, ObserveOn, Serialize, Subscribe, SubscribeOn, TimeInterval, Timeout, Timestamp, and Using*/

Observable.of(1,2,3,4,5).do(onNext: {
    $0 * 10 // This has no effect on the actual subscription
}).subscribe(onNext:{
    print($0)
})

/*Conditional and Boolean Operators
 All, Amb, Contains, DefaultIfEmpty, SequenceEqual, SkipUntil, SkipWhile, TakeUntil, and TakeWhile
 
 Mathematical and Aggregate Operators
 Average, Concat, Count, Max, Min, Reduce, and Sum
 
 Converting Observables
 To
 
 Connectable Observable Operators
 Connect, Publish, RefCount, and Replay
 
 Backpressure Operators
 a variety of operators that enforce particular flow-control policies*/

//You can create your custom operators also

//https://github.com/ReactiveX/RxSwift/blob/master/Documentation/GettingStarted.md#custom-operators

//Debugging an observable

//Debug observables

let debugSequence = Observable.from(["H","e","l","l","o"])
let debugSubscription = debugSequence
    .debug("debug probe")
    .map { e in
        return "This is simply \(e)"
    }
    .subscribe(onNext: { n in
        print(n)
    })

/*In debug mode Rx tracks all allocated resources in a global variable Resources.total.
 
 In order to enable debug mode, a TRACE_RESOURCES flag must be added to the RxSwift target build settings, under Other Swift Flags.
 
 In case you want to have some resource leak detection logic, the simplest method is just printing out RxSwift.Resources.total periodically to output.
 
 /* add somewhere in
 func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey : Any]? = nil)
 */
 _ = Observable<Int>.interval(1, scheduler: MainScheduler.instance)
 .subscribe(onNext: { _ in
 print("Resource count \(RxSwift.Resources.total)")
 })*/

//Schedulers in RxSwift

Observable<Int>.create { observer in
    observer.onNext(1)
    sleep(1)
    observer.onNext(2)
    return Disposables.create()
    }
    .observeOn(MainScheduler.instance)
    .subscribeOn(ConcurrentDispatchQueueScheduler(qos: .background))
    .subscribe(onNext: { el in
        print(Thread.isMainThread)
    })

// [main] subscribe() -> [background] create{ ... } -> [main] onNext { ... }

//Serial Schedulers
//1) CurrentThreadScheduler (Serial scheduler)
//2) MainScheduler (Serial scheduler)
//3) SerialDispatchQueueScheduler (Serial scheduler)

//Concurrent Schedulers
//1) ConcurrentDispatchQueueScheduler (Concurrent scheduler)
//2) OperationQueueScheduler (Concurrent scheduler)


//Few things to remember while working

//1. Avoid nesting subscribe calls at all cost.
//var textField = UITextField.init(frame: CGRect.init(x: 0, y: 0, width: 0, height: 0))
//textField.rx.text.subscribe(onNext: { text in
//    performURLRequest(url:text).subscribe(onNext: { result in
//
//    })
//    .disposed(by: bag)
//}).disposed(by: bag)

//Preferred way of chaining disposables by using operators

//textField.rx.text
//    .flatMapLatest { text in
//        // Assuming this doesn't fail and returns result on main scheduler,
//        // otherwise `catchError` and `observeOn(MainScheduler.instance)` can be used to
//        // correct this.
//        return performURLRequest(text)
//    }.disposed(by: bag) // only one top most disposable

//2. Observable should be lazy

func calculate1() -> Int {
    print("Lazy function invoked")
    return 1
}

func rx_myFunction() -> Observable<Int> {
    let someCalculationResult: Int = calculate1()
    return .just(someCalculationResult)
}

func rx_myFunction1() -> Observable<Int> {
    return Observable.deferred {
        let someCalculationResult: Int = calculate1()
        return .just(someCalculationResult)
    }
}

//This invokes the actual lazy operation
rx_myFunction()

//This does not invokes the actual lazy operation
rx_myFunction1()

//3. Make sure you are using correct diaposeBag [UIViewController, TableViewCell etc]

//4. Subscribing multiple times into 1 Observable

let shareObservable = Observable<Int>.create { observer in
    print("inside block")
    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
        observer.onCompleted()
    }
    return Disposables.create()
    }.share()

shareObservable.subscribe()
shareObservable.subscribe()

//Evaluate share vs replay vs shareReplay for better options

//5. Rx operators are as general as possible, but there will always be edge cases that will be hard to model. In those cases you can just create your own operator and possibly use one of the built-in operators as a reference.

playgroundTimeLimit(seconds:10)
