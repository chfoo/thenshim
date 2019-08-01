package thenshim;

/**
 * Common signature for this library to specify objects that provide a `then`
 * method.
 */
interface Thenable<T> {
    /**
     * Calls the given callbacks when this promise is settled.
     *
     * Note that unlike the JavaScript `then`, the return type parameter
     * is only `R` where as JavaScript `then` has possible parameter types of
     * `T`, `R1`, and `R2`.
     *
     * @param onFulfilled A callback that will be called with the value `T`
     *     when the promise is fulfilled. The callback returns a promise
     *     or value.
     * @param onRejected A callback that will be called with the reason `Any`
     *     when the promise is rejected. The callback returns a promise
     *     or value.
     */
    public function then<R>(
        onFulfilled:ThenableCallback<T,R>,
        ?onRejected:ThenableCallback<Any,R>):
        Thenable<R>;
}

/**
 * Abstract that accepts callback functions to the `then` method.
 *
 * Valid callbacks are:
 *
 * - `T->R`: Function that returns a value of type `R`.
 * - `T->Thenable<R>`: Function that returns a thenable `Thenable` with value
 *    type `R`.
 * - `T->Promise<R>`: Function that returns a promise `Promise` with value
 *    type `R`.
 *
 * On JS, this unifies to `js.lib.Promise.PromiseHandler`.
 */
abstract ThenableCallback<T,R>(T->Dynamic)
    from T->R
    from T->Thenable<R>
    from T->Promise<R> {
// Exclude cast from dox due to haxe bug #7829
#if (js && !doc_gen)
    // Any/Dynamic don't unify properly yet, so we have to use cast for now
    @:to
    inline function toJSPromiseHandler():js.lib.Promise.PromiseHandler<T,R> {
        return cast this;
    }
#end
}
