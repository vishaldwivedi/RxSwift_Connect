# RxSwift_Connect
This repository explains RxSwift [Reactive Extension for Swift], what are its main components, capabilities and most importantly things to watch out for.

## The Playground availabel in the project can be used to play with the concepts and see them in practise

# When to use Rx

Use Rx for orchestrating asynchronous and event-based computations
Code that deals with more than one event or asynchronous computation gets complicated quickly as it needs to build a state-machine to deal with ordering issues. Next to this, the code needs to deal with successful and failure termination of each separate computation. This leads to code that doesn’t follow normal control-flow, is hard to understand and hard to maintain.
    Rx makes these computations first-class citizens. This provides a model that allows for readable and composable APIs to deal with these asynchronous computations. 

Use Rx to deal with asynchronous sequences of data


# Best practice for designing with Rx in Mind
Consider drawing a Marble-diagram

Details can be found here https://rxmarbles.com/

# Types of observables

“Hot” and “Cold” Observables
When does an Observable begin emitting its sequence of items? It depends on the Observable. A “hot” Observable may begin emitting items as soon as it is created, and so any observer who later subscribes to that Observable may start observing the sequence somewhere in the middle. A “cold” Observable, on the other hand, waits until an observer subscribes to it before it begins to emit items, and so such an observer is guaranteed to see the whole sequence from the beginning.

In some implementations of ReactiveX, there is also something called a “Connectable” Observable. Such an Observable does not begin emitting items until its Connect method is called, whether or not any observers have subscribed to it.

https://github.com/ReactiveX/RxSwift/blob/master/Documentation/HotAndColdObservables.md

# Subject
A Subject is a special form of an Observable Sequence, you can subscribe and dynamically add elements to it. There are currently 4 different kinds of Subjects in RxSwift

* PublishSubject: If you subscribe to it you will get all the events that will happen after you subscribed.
* BehaviourSubject: A behavior subject will give any subscriber the most recent element and everything that is emitted by that sequence after the subscription happened.
* ReplaySubject: If you want to replay more than the most recent element to new subscribers on the initial subscription you need to use a ReplaySubject. With a ReplaySubject, you can define how many recent items you want to emit to new subscribers.
* Variable: A Variable is just a BehaviourSubject wrapper that feels more natural to a non reactive programmers. It can be used like a normal Variable.
 
# Relay
RxCocoa provides two kinds of Relays: PublishRelay and BehaviorRelay. They behave exactly like their parallel Subjects, with two changes:
 
* Relays never complete.
* Relays never emit errors.
 
In essence, Relays only emit .next events, and never terminate.

# Schedulers in RxSwift

```swift
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
```
so basically this happens in real time
[main] subscribe() -> [background] create{ ... } -> [main] onNext { ... }

Serial Schedulers
1) CurrentThreadScheduler (Serial scheduler)
2) MainScheduler (Serial scheduler)
3) SerialDispatchQueueScheduler (Serial scheduler)

Concurrent Schedulers
1) ConcurrentDispatchQueueScheduler (Concurrent scheduler)
2) OperationQueueScheduler (Concurrent scheduler)

# Traits Reactive Extensions

1)Single: A Single is a variation of Observable that, instead of emitting a series of elements, is always guaranteed to emit either a single element or an error.

Emits exactly one element, or an error.
Doesn't share side effects.

2) Completeable : A Completable is a variation of Observable that can only complete or emit an error. It is guaranteed to not emit any elements.

Emits zero elements.
Emits a completion event, or an error.
Doesn't share side effects.

3)Maybe : A Maybe is a variation of Observable that is right in between a Single and a Completable. It can either emit a single element, complete without emitting an element, or emit an error.

Note: Any of these three events would terminate the Maybe, meaning - a Maybe that completed can't also emit an element, and a Maybe that emitted an element can't also send a Completion event.

Emits either a completed event, a single element or an error.
Doesn't share side effects.

Driver: Driver is an Observable with observeOn, catchErrorJustReturn and shareReplay operators already applied. If you want to expose a secure API in your view model it’s a good idea to always use a Driver!

Can't error out.
Observe occurs on main scheduler.
Shares side effects (share(replay: 1, scope: .whileConnected)). 
 
 # Some prominent operators

###### Creating Observables
Create, Defer, Empty/Never/Throw, From, Interval, Just, Range, Repeat, Start, and Timer*/
 
###### Transforming Observable Items
Buffer, FlatMap, GroupBy, Map, Scan, and Window

###### Filtering Observables
Debounce, Distinct, ElementAt, Filter, First, IgnoreElements, Last, Sample, Skip, SkipLast, Take, and TakeLast

###### Combining Observables
And/Then/When, CombineLatest, Join, Merge, StartWith, Switch, and Zip

###### Error Handling Operators
Catch and Retry

###### Utility Operators
Delay, Do, Materialize/Dematerialize, ObserveOn, Serialize, Subscribe, SubscribeOn, TimeInterval, Timeout, Timestamp, and Using

###### Conditional and Boolean Operators
All, Amb, Contains, DefaultIfEmpty, SequenceEqual, SkipUntil, SkipWhile, TakeUntil, and TakeWhile

###### Mathematical and Aggregate Operators
Average, Concat, Count, Max, Min, Reduce, and Sum

###### Converting Observables
To
 
###### Connectable Observable Operators
Connect, Publish, RefCount, and Replay
 
###### Backpressure Operators
a variety of operators that enforce particular flow-control policies

# You can create your custom operators also

https://github.com/ReactiveX/RxSwift/blob/master/Documentation/GettingStarted.md#custom-operators

# Debugging an observable

1) use debug operator

2) Enable debug mode. In debug mode Rx tracks all allocated resources in a global variable Resources.total.
 
In order to enable debug mode, a TRACE_RESOURCES flag must be added to the RxSwift target build settings, under Other Swift Flags.

In case you want to have some resource leak detection logic, the simplest method is just printing out RxSwift.Resources.total periodically to output.

add somewhere in
```swift
 func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey : Any]? = nil)
_ = Observable<Int>.interval(1, scheduler: MainScheduler.instance)
.subscribe(onNext: { _ in
print("Resource count \(RxSwift.Resources.total)")
})
```
    
# Few things to remember while working [Samples in playground]

1. Avoid nesting subscribe calls at all cost.

2. Observable should be lazy

3. Make sure you are using correct diaposeBag [UIViewController, TableViewCell etc]

4. Subscribing multiple times into 1 Observable

5. Rx operators are as general as possible, but there will always be edge cases that will be hard to model. In those cases you can just create your own operator and possibly use one of the built-in operators as a reference.

6. It is good practice to make sure all sequences which UIViewController or UIView subscribes to should be a Driver

