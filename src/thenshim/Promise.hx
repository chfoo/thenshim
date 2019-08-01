package thenshim;

import thenshim.PromiseFactory;
import thenshim.Thenable;

#if (!thenshim_always_fallback && js)
    import thenshim.js.JSPromiseFactory;

    typedef UnderlyingPromise<T> = js.lib.Promise<T>;
    private typedef _Factory = JSPromiseFactory;
#else
    import thenshim.fallback.FallbackPromiseFactory;

    typedef UnderlyingPromise<T> = Thenable<T>;
    private typedef _Factory = FallbackPromiseFactory;
#end

/**
 * Abstract over the target's promise implementation.
 *
 * - On JS, the underlying promise is `js.lib.Promise`.
 * - Otherwise, the underlying promise is `FallbackPromise`.
 */
abstract Promise<T>(UnderlyingPromise<T>)
from UnderlyingPromise<T> to UnderlyingPromise<T> {
    /**
     * Factory that calls the methods to create promises on the current target.
     *
     * - On JS, it is `JSPromiseFactory`
     * - Otherwise, it is `FallbackPromiseFactory`
     */
    public static var factory:PromiseFactory = new _Factory();

    /**
     * Wrap an implementation as a JavaScript-style promise.
     * @param executor Callback function with resolve and reject functions.
     */
    public function new(executor:PromiseExecutor<T>) {
        this = factory.make(executor);
    }

    /**
     * Returns a settled promise or flattened promise.
     *
     * - When given a value, it returns a settled promise that is fulfilled
     *   with the given value (as a convenience function).
     * - When given a `Promise`, it returns the promise itself.
     * - When given a `Thenable`, it returns a new promise that reflects
     *   the `Thenable`'s state.
     */
    public static function resolve<T>(object:ValueOrPromiseLike<T>):Promise<T> {
        return factory.asResolved(object);
    }

    /**
     * Returns a settled promise that is rejected with the given reason.
     */
    public static function reject<T>(reason:Any):Promise<T> {
        return factory.asRejected(reason);
    }

    /**
     * Calls the given callbacks when this promise is settled.
     *
     * @see `Thenable.then` for callback descriptions.
     */
    public function then<R>(
            onFulfilled:ThenableCallback<T,R>,
            ?onRejected:ThenableCallback<Any,R>):
            Promise<R> {
        @:nullSafety(Off)
        // cast under dox due to bug in Thenable
        return this.then(#if doc_gen cast #end onFulfilled,
            #if doc_gen cast #end onRejected);
    }
}
