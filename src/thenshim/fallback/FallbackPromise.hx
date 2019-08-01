package thenshim.fallback;

import thenshim.Thenable;

/**
 * Promise/A+ implementation for providing a fallback/shim for targets
 * without promise support.
 */
class FallbackPromise<T> implements Thenable<T> {
    final scheduler:TaskScheduler;
    var state:PromiseState = PromiseState.Pending;
    var value:Null<T>;
    var reason:Null<Any>;
    final sessions:Array<HandlerSession>;

    public function new(scheduler:TaskScheduler) {
        this.scheduler = scheduler;
        sessions = [];
    }

    public function then<R>(
            onFulfilled:ThenableCallback<T,R>,
            ?onRejected:ThenableCallback<Any,R>):
            Thenable<R> {
        @:nullSafety(Off)
        return cast thenImpl(onFulfilled, onRejected);
    }

    function thenImpl(onFulfilled:Null<Any>, onRejected:Null<Any>):FallbackPromise<Any> {
        @:nullSafety(Off)
        var session = new HandlerSession(
            scheduler,
            Reflect.isFunction(onFulfilled) ? onFulfilled : null,
            Reflect.isFunction(onRejected) ? onRejected : null
        );

        switch state {
            case Pending:
                sessions.push(session);
            case Fulfilled:
                @:nullSafety(Off)
                session.resolve(value);
            case Rejected:
                @:nullSafety(Off)
                session.reject(reason);
        }

        return session.promise;
    }

    public function resolve(value:T) {
        if (state != Pending) {
            return;
        }

        state = Fulfilled;
        this.value = value;

        for (session in sessions) {
            session.resolve(value);
        }
        sessions.resize(0);
    }

    public function reject(reason:Any) {
        if (state != Pending) {
            return;
        }

        state = Rejected;
        this.reason = reason;
        for (session in sessions) {
            session.reject(reason);
        }
        sessions.resize(0);
    }
}
