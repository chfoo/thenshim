package thenshim.fallback;

import thenshim.PromiseFactory;

/**
 * Factory that creates `FallbackPromise`.
 */
class FallbackPromiseFactory implements PromiseFactory {
    /**
     * Scheduler that is used for the promises created by this factory.
     */
    public final scheduler:TaskScheduler;

    public function new() {
        scheduler = new TaskScheduler();
    }

    public function make<T>(executor:PromiseExecutor<T>):Thenable<T> {
        var promise = new FallbackPromise(scheduler);
        executor(promise.resolve, promise.reject);
        return promise;
    }

    public function asResolved<T>(object:ValueOrPromiseLike<T>):Thenable<T> {
        if (Std.is(object, FallbackPromise)) {
            return object;
        } else if (Std.is(object, Thenable)) {
            return asResolvedThenable(object);
        }

        var promise = asResolvedThenProperty(object);

        if (promise != null) {
            return promise;
        }

        var promise = new FallbackPromise(scheduler);
        promise.resolve(object);
        return promise;
    }

    function asResolvedThenable<T>(thenable:Thenable<T>):Thenable<T> {
        var promise = new FallbackPromise(scheduler);

        try {
            thenable.then(promise.resolve, promise.reject);
        } catch (exception:Any) {
            promise.reject(exception);
        }

        return promise;
    }

    function asResolvedThenProperty<T>(object:Dynamic):Null<Thenable<T>> {
        var then;

        try {
            then = Reflect.getProperty(object, "then");
        } catch (exception:Any) {
            return asRejected(exception);
        }

        if (then != null) {
            var promise = new FallbackPromise(scheduler);

            try {
                @:nullSafety(Off)
                Reflect.callMethod(null, then, [promise.resolve, promise.reject]);
            } catch (exception:Any) {
                promise.reject(exception);
            }

            return promise;
        } else {
            return null;
        }
    }

    public function asRejected<T>(reason:Any):Thenable<T> {
        var promise = new FallbackPromise(scheduler);
        promise.reject(reason);
        return promise;
    }
}
