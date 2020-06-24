package thenshim.fallback;

import haxe.Constraints.Function;

/**
 * Session for a `FallbackPromise` attached callback.
 */
class HandlerSession {
    public final promise:FallbackPromise<Any>;
    final scheduler:TaskScheduler;
    final fulfilledCallback:Null<Function>;
    final rejectedCallback:Null<Function>;

    public function new(scheduler:TaskScheduler,
            fulfilledCallback:Null<Function>, rejectedCallback:Null<Function>) {
        this.scheduler = scheduler;
        this.fulfilledCallback = fulfilledCallback;
        this.rejectedCallback = rejectedCallback;
        promise = new FallbackPromise(scheduler);
    }

    public function resolve(value:Any) {
        if (fulfilledCallback != null) {
            scheduler.addNext(resolveImpl.bind(value));
        } else {
            promise.resolve(value);
        }
    }

    inline function nullThis():Null<Any> {
        #if js
        return js.Lib.undefined;
        #else
        return null;
        #end
    }

    function resolveImpl(value:Any) {
        var handlerValue;

        try {
            @:nullSafety(Off)
            handlerValue = Reflect.callMethod(
                nullThis(), fulfilledCallback, [value]);
        } catch (exception:Any) {
            promise.reject(exception);
            return;
        }

        resolvePromise(promise, handlerValue);
    }

    public function reject(reason:Any) {
        if (rejectedCallback != null) {
            scheduler.addNext(rejectImpl.bind(reason));
        } else {
            promise.reject(reason);
        }
    }

    function rejectImpl(reason:Any) {
        var handlerValue;

        try {
            @:nullSafety(Off)
            handlerValue = Reflect.callMethod(
                nullThis(), rejectedCallback, [reason]);
        } catch (exception:Any) {
            promise.reject(exception);
            return;
        }

        resolvePromise(promise, handlerValue);
    }

    static function resolvePromise(promise:FallbackPromise<Any>, value:Any) {
        if (rejectIfSame(promise, value)) {
            return;
        }

        if (Std.is(value, Thenable)) {
            resolvePromiseThenable(promise, value);
        } else if (!Std.is(value, String)
                && (Reflect.isObject(value) || Reflect.isFunction(value))) {
            resolvePromiseObject(promise, value);
        } else {
            promise.resolve(value);
        }
    }

    static function rejectIfSame(promise:FallbackPromise<Any>, value:Any):Bool {
        if (promise == value) {
            var errorMsg = "promise and result is same object";
            #if js
            var reason = new js.lib.Error.TypeError(errorMsg);
            #else
            var reason = errorMsg;
            #end
            promise.reject(reason);
            return true;
        } else {
            return false;
        }
    }

    static function resolvePromiseThenable(promise:FallbackPromise<Any>,
            thenable:Thenable<Any>) {

        var fulfilled = false;

        function _resolve(value:Any) {
            if (!fulfilled) {
                fulfilled = true;
                resolvePromise(promise, value);
            }
        }

        function _reject(reason:Any) {
            if (!fulfilled) {
                fulfilled = true;
                promise.reject(reason);
            }
        }

        try {
            thenable.then(_resolve, _reject);
        } catch (exception:Any) {
            if (!fulfilled) {
                fulfilled = true;
                promise.reject(exception);
            }
        }
    }

    static function resolvePromiseObject(promise:FallbackPromise<Any>, object:Any) {
        var then;
        try {
            then = Reflect.getProperty(object, "then");
        } catch (exception:Any) {
            promise.reject(exception);
            return;
        }

        if (!Reflect.isFunction(then)) {
            promise.resolve(object);
            return;
        }

        var fulfilled = false;

        function _resolve(value:Any) {
            if (!fulfilled) {
                fulfilled = true;
                resolvePromise(promise, value);
            }
        }

        function _reject(reason:Any) {
            if (!fulfilled) {
                fulfilled = true;
                promise.reject(reason);
            }
        }

        try {
            Reflect.callMethod(object, then, [_resolve, _reject]);
        } catch (exception:Any) {
            if (!fulfilled) {
                fulfilled = true;
                promise.reject(exception);
            }
        }
    }
}
