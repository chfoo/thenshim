package thenshim;

import thenshim.fallback.FallbackPromise;
import thenshim.fallback.FallbackPromiseFactory;

@:keep
@:expose
class PAPTestAdapter {
    static final factory = new FallbackPromiseFactory();
    public static final adapter:Dynamic = {
        resolved: value -> return factory.asResolved(value),
        rejected: reason -> return factory.asRejected(reason),
        deferred: () -> {
            var promise = new FallbackPromise(factory.scheduler);

            return {
                promise: promise,
                resolve: promise.resolve,
                reject: promise.reject
            };
        }
    };

    public static final resolved:Dynamic = adapter.resolved;
    public static final rejected:Dynamic = adapter.rejected;
    public static final deferred:Dynamic = adapter.deferred;

    static final dummy = {
        js.Syntax.code("$hx_exports['resolved'] = {0}", resolved);
        js.Syntax.code("$hx_exports['rejected'] = {0}", rejected);
        js.Syntax.code("$hx_exports['deferred'] = {0}", deferred);
    };
}
