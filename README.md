# Thenshim

Thenshim is an adapter/shim for cross-target JavaScript-style ("thenable") promises for Haxe. On the JS target, it uses the native Promise object. On other targets, a fallback implementation is used. The fallback implementation is [Promises/A+](https://promisesaplus.com/) compliant.

Thenshim is intended for applications or libraries that want to use JavaScript-style promises across targets. For more feature-rich asynchronous functionality, such as cancellation, consider using a different library. (You can search on [Haxelib](https://lib.haxe.org/) to find various libraries that best suit your project.)

## Getting started

Requires:

* Haxe 4.0

The library can be installed using haxelib:

    haxelib install thenshim

Or the latest from the GitHub repository:

    haxelib git thenshim https://github.com/chfoo/thenshim

### Concepts

If you never used a JavaScript promise or something similar, it is highly recommended to read an introduction such as [this one on MDN](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Guide/Using_promises).

The `Promise` abstract is an abstract over `js.lib.Promise` on JS and `FallbackPromise` on other targets.

The `FallbackPromise` class implements the `Thenable` interface. The `Thenable` interface can be used to specify an alternative implementation if needed.

The `then` method is slightly more restrictive than the JS method. It has two parameters with the following signatures:

* onFulfilled: `T->Promise<R>`, `T->Thenable<R>`, or `T->R`
* onRejected (optional): `Any->Promise<R>`, `T->Thenable<R>`, or `T->R`

Unlike JS-style promises which can return parameter types `T`, `R1`, or `R2`, this library's `then` method only allows `R` for straightforward parameter typing.

### Using promises

To use a promise, pass a callback function to the `then` method. The `onFulfilled` callback is called with a value of type `T` when the operation successfully completes. The `onRejected` callback is called with a reason `Any` when there is an exception or error. Both callbacks returns a new promise or value of type `R`.

Example of using `then`:

```haxe
// Schedule and execute an asynchronous operation
var promise:Promise<String> = someAsyncOperation();

promise.then((result:String) -> {
    // Once the asynchronous operation completes, print the result
    trace(result);

    // Return a value as demo for chaining
    return result.length;
}).then((result:Int) -> {
    trace(result);

    // To end the promise chain, return a dummy value
    return true;
});
```

### Creating promises

#### New Promise

A promise can be created to wrap an operation into a JavaScript-style promise:

```haxe
var promise = new Promise((resolve, reject) -> {
    // Do something

    // If it was successful:
    resolve("abc");

    // Otherwise, reject with an error:
    reject("error");
});
```

#### resolve()

`Promise.resolve()` is a special method:

* When given a value, it returns a settled promise that is fulfilled with the given value (as a convenience function).
* When given a `Promise`, it returns the promise itself.
* When given a `Thenable`, it returns a new promise that reflects the `Thenable`'s state.

#### reject()

`Promise.reject()` is a convenience method returns a settled promise that is already rejected with the given reason.

### Task scheduler

Callbacks, in practice, are called asynchronously as required by specifications. The task scheduler function for the fallback promise implementation can be changed like so:

```haxe
var promiseFactory = cast(Promise.factory, FallbackPromiseFactory);
promiseFactory.scheduler.addNext = myScheduleCallbackToEventLoopFunction;
```

By default, the task is called synchronously. You will need to implement and integrate the functionality into your event loop.

On the JS target, `setImmediate` or `setTimeout` will be used for task scheduling. This implementation is intended for testing, as native promises should be used instead.

### Additional methods

Additional JavaScript-style promise methods are provided in `PromiseTools`. It is a static method extension class that can be used with the `using` keyword.

### Further reading

API docs: https://chfoo.github.io/thenshim/api/

## Contributing

If there is a bug or improvement, please file an issue or pull request on the GitHub repository.

## Copyright

Copyright 2019 Christopher Foo. Licensed under MIT.
