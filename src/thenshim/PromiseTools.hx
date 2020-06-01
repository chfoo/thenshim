package thenshim;

import thenshim.Promise;
import thenshim.Thenable;

using Lambda;

/**
 * Static extension class for additional JavaScript-style methods.
 *
 * The class is intended to be used using the `using` keyword.
 */
class PromiseTools {
    /**
     * Returns a promise that is fulfilled when all the given promises are
     * fulfilled or rejected with a reason of the first promise that is
     * rejected.
     */
    public static function all<T>(promises:Iterable<Promise<T>>):
            Promise<Array<T>> {
        #if js
        // cast required because the parameter type is Dynamic instead of T
        return cast js.lib.Promise.all(promises.array());
        #else
        var aggregatePromise = new Promise((resolve, reject) -> {
            var promises_ = promises.array();
            var values = new Array<T>();
            values.resize(promises_.length);
            var remaining = promises_.length;

            for (index in 0...promises_.length) {
                var promise = promises_[index];

                promise.then(value -> {
                    values[index] = value;
                    remaining -= 1;

                    if (remaining == 0) {
                        resolve(values);
                    }
                }, reason -> {
                    reject(reason);
                });
            }

            if (promises_.length == 0) {
                resolve(values);
            }
        });

        return aggregatePromise;
        #end
    }

    /**
     * Returns a promise that will be fulfilled with an array of outcome objects
     * when all of the given promises are settled.
     *
     * The object will have fields:
     *
     * - `status` (`String`) either "fulfilled" or "rejected"
     * - `value` (`T`) when `status` is "fulfilled"
     * - `reason` when `status` is "rejected"
     *
     * If the method is not implemented on the JS target, use
     * `-D thenshim_js_fallback_allSettled` to enable a fallback implementation.
     * Objects are either `FulfilledOutcome` or `RejectedOutcome`, but using
     * reflection (`Reflect`) instead of casting is recommended for
     * cross-target compatibility.
     */
    public static function allSettled<T>(promises:Iterable<Promise<T>>):
            Promise<Array<SettledOutcome<T>>> {
        #if (js && !thenshim_js_fallback_allSettled)
        //return cast js.lib.Promise.allSettled(promises.array());
        return js.Syntax.code("Promise.allSettled({0})", promises.array());
        #else
        var aggregatePromise = new Promise((resolve, reject) -> {
            var promises_ = promises.array();
            var outcomes = new Array<SettledOutcome<T>>();
            outcomes.resize(promises_.length);
            var remaining = promises_.length;

            function countRemaining() {
                remaining -= 1;

                if (remaining == 0) {
                    resolve(outcomes);
                }
            }

            for (index in 0...promises_.length) {
                var promise = promises_[index];

                promise.then(value -> {
                    outcomes[index] = ({
                        status: "fulfilled",
                        value: value
                    }:FulfilledOutcome<T>);
                    countRemaining();
                }, reason -> {
                    outcomes[index] = ({
                        status: "rejected",
                        reason: reason
                    }:RejectedOutcome<T>);
                    countRemaining();
                });

            }

            if (promises_.length == 0) {
                resolve(outcomes);
            }
        });

        return aggregatePromise;
        #end
    }

    /**
     * Returns a promise that will be settled with the value or reason of
     * the first promise to fullfil or reject.
     */
    public static function race<T>(promises:Iterable<Promise<T>>):Promise<T> {
        #if js
        return cast js.lib.Promise.race(promises.array());
        #else
        return new Promise((resolve, reject) -> {
            for (promise in promises) {
                promise.then(resolve, reject);
            }
        });
        #end
    }

    /**
     * Calls `then` with the `onRejected` callback.
     */
    public static function catch_<T,R>(promise:Promise<T>,
            onRejected:ThenableCallback<Any,Null<R>>):Promise<Null<R>> {
        #if js
        // cast due to bug in Thenable
        return (promise:js.lib.Promise<T>).catchError(#if doc_gen cast #end onRejected);
        #else
        @:nullSafety(Off)
        return promise.then(value -> (null:Null<R>), onRejected);
        #end
    }

    /**
     * Calls `then` with the `onRejected` callback.
     *
     * This is an alias for `PromiseTools.catch_`.
     */
    public static inline function catchError<T,R>(promise:Promise<T>,
            onRejected:ThenableCallback<Any,Null<R>>):Promise<Null<R>> {
        return catch_(promise, onRejected);
    }

    /**
     * Calls a callback when the given promise settles.
     *
     * If the method is not implemented on the JS target, use
     * `-D thenshim_js_fallback_finally` to enable a fallback implementation.
     */
    public static function finally<T>(promise:Promise<T>,
            onFinally:Void->Void):Promise<T> {
        #if (js && !thenshim_js_fallback_finally)
        // return (promise:js.lib.Promise<T>).onFinally(onFinally);
        return js.Syntax.code("{0}.finally({1})", promise, onFinally);
        #else
        return promise.then(value -> {
            onFinally();
            return value;
        }, reason -> {
            onFinally();
            return Promise.reject(reason);
        });
        #end
    }
}

typedef SettledOutcome<T> = {
    status:String
};

typedef FulfilledOutcome<T> = {
    > SettledOutcome<T>,
    value:T
}

typedef RejectedOutcome<T> = {
    > SettledOutcome<T>,
    reason:Any
}
