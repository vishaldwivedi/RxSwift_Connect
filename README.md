# RxSwift_Connect
This repository explains RxSwift [Reactive Extension for Swift], what are its main components, capabilities and most importantly things to watch out for

When to use Rx

Use Rx for orchestrating asynchronous and event-based computations
Code that deals with more than one event or asynchronous computation gets complicated quickly as it needs to build a state-machine to deal with ordering issues. Next to this, the code needs to deal with successful and failure termination of each separate computation. This leads to code that doesn’t follow normal control-flow, is hard to understand and hard to maintain.
    Rx makes these computations first-class citizens. This provides a model that allows for readable and composable APIs to deal with these asynchronous computations. */

Use Rx to deal with asynchronous sequences of data*


Best practice for designing with Rx in Mind
Consider drawing a Marble-diagram

Details can be found here https://rxmarbles.com/



Types of observables

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
