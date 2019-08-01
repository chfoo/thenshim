package thenshim.js;

import thenshim.PromiseFactory;

/**
 * Factory that calls `js.lib.Promise`
 */
class JSPromiseFactory implements PromiseFactory {
    public function new() {
    }

    public function make<T>(executor:PromiseExecutor<T>) {
        return new js.lib.Promise(executor);
    }

    public function asResolved<T>(object:ValueOrPromiseLike<T>) {
        return js.lib.Promise.resolve(object);
    }

    public function asRejected<T>(reason:Any) {
        return js.lib.Promise.reject(reason);
    }
}
