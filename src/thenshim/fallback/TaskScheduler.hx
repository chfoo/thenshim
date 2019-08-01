package thenshim.fallback;

/**
 * Schedules tasks on an event loop.
 */
class TaskScheduler {
    #if js
    final setImmediateFunc:Dynamic;
    #end

    public function new() {
        #if js
        if (js.Syntax.typeof(js.Lib.global.setImmediate) == 'function') {
            setImmediateFunc = js.Lib.global.setImmediate;
        } else {
            setImmediateFunc = js.Browser.window.setTimeout.bind(_, 0);
        }
        #end
    }

    /**
     * Schedule a task to be run on the next event loop cycle.
     *
     * Overwrite this function with an implementation that integrates
     * with your event loop to ensure the promise is Promise/A+ compliant.
     *
     * On JS, this uses `setIntermediate` or `setTimeout` for testing purposes.
     */
    public dynamic function addNext(task:Void->Void) {
        #if js
        setImmediateFunc(task);
        #else
        task();
        #end
    }
}
