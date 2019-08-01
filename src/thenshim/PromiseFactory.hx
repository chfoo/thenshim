package thenshim;

import thenshim.Promise;

/**
 * Callback function for wrapping implementations to new promises.
 *
 * The callback provides two functions:
 *
 * - `resolve` (`T->Void`) is to be called with a value of type `T` when the operation has
 *   completed successfully.
 * - `reject` (`Any->Void`) is to be called with a reason when the operation has failed.
 */
typedef PromiseExecutor<T> = (resolve:T->Void, reject:Any->Void)->Void;

/**
 * Abstract class that unifies with values, `Thenable`, and `Promise`.
 */
abstract ValueOrPromiseLike<T>(Dynamic)
    from T
    from Thenable<T>
    from Promise<T>
    to T
    to Thenable<T>
    to Promise<T>
{}

/**
 * Creates promises.
 *
 * This interface is intended for providing fallback implementations when
 * the target does not provide JavaScript-style promises.
 *
 * @see `Promise` for method documentation.
 */
interface PromiseFactory {
    public function make<T>(executor:PromiseExecutor<T>):UnderlyingPromise<T>;
    public function asResolved<T>(object:ValueOrPromiseLike<T>):UnderlyingPromise<T>;
    public function asRejected<T>(reason:Any):UnderlyingPromise<T>;
}
