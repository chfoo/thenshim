package thenshim.test;

import utest.Assert;
import utest.Test;

class MyException {
    public function new() {
    }
}

class MyClass {
    public function new() {}
}

class TestPromise extends Test {
    function newPromise<T>():{promise:Promise<T>, resolve:T->Void, reject:Any->Void} {
        var resolve;
        var reject;

        var promise = new Promise((_resolve, _reject) -> {
            resolve = _resolve;
            reject = _reject;
        });

        return {
            promise: promise,
            resolve: resolve,
            reject: reject
        };
    }

    public function testResolve(asyncTest:utest.Async) {
        var promiseMeta = newPromise();

        promiseMeta.promise.then((value:Int) -> {
            Assert.equals(123, value);
            return Promise.resolve(456);
        }).then((value:Int) -> {
            Assert.equals(456, value);
            return Promise.resolve("abc");
        }).then((value:String) -> {
            Assert.equals("abc", value);
            return new MyClass();
        }).then((value:MyClass) -> {
            Assert.isOfType(value, MyClass);
            return true;
        });

        promiseMeta.resolve(123);

        promiseMeta.promise.then(value -> {
            Assert.equals(123, value);
            return "def";
        }).then(value -> {
            Assert.equals("def", value);
            return new MyClass();
        }).then(value -> {
            Assert.isOfType(value, MyClass);
            asyncTest.done();
            return true;
        });
    }

    public function testReject(asyncTest:utest.Async) {
        var promiseMeta = newPromise();

        promiseMeta.promise.then(
            value -> { Assert.fail(); throw "fail"; },
            reason -> throw reason
        ).then(
            value -> { Assert.fail(); throw "fail"; },
            reason -> {
                try {
                    throw reason;
                } catch(exception:Any) {
                    Assert.isOfType(exception, MyException);
                }
                return true;
            }
        );

        promiseMeta.reject(new MyException());

        promiseMeta.promise.then(
            value -> { Assert.fail(); throw "fail"; },
            reason -> {
                try {
                    throw reason;
                } catch(exception:Any) {
                    Assert.isOfType(exception, MyException);
                }
                asyncTest.done();
                return true;
            }
        );
    }

    public function testResolveException(asyncTest:utest.Async) {
        var promiseMeta = newPromise();

        promiseMeta.promise.then(value -> {
            throw new MyException();
        }).then(
            value -> { Assert.fail(); throw "fail"; },
            reason -> {
                try {
                    throw reason;
                } catch(exception:Any) {
                    Assert.isOfType(exception, MyException);
                }
                asyncTest.done();
                return true;
            }
        );

        promiseMeta.resolve(123);
    }
}
