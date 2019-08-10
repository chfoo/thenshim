package thenshim.test;

import utest.Assert;
import utest.Async;
import utest.Test;
import thenshim.Promise;

using thenshim.PromiseTools;

class TestPromiseTools extends Test {
    public function testAll(asyncTest:Async) {
        var promises = [Promise.resolve(1), Promise.resolve(2), Promise.resolve(3)];
        var aggregatePromise = promises.all();

        aggregatePromise.then(
            value -> {
                Assert.same([1, 2, 3], value);
                asyncTest.done();
            },
            reason -> {
                Assert.fail(reason);
                asyncTest.done();
            }
        );
    }

    public function testAllReject(asyncTest:Async) {
        var promises = [Promise.resolve(1), Promise.reject(2), Promise.resolve(3)];
        var aggregatePromise = promises.all();

        aggregatePromise.then(
            value -> {
                Assert.fail();
                asyncTest.done();
            },
            reason -> {
                Assert.equals(2, reason);
                asyncTest.done();
            }
        );
    }

    public function testAllEmpty(asyncTest:Async) {
        var promises = [];

        var aggregatePromise = promises.all();

        aggregatePromise.then(
            value -> {
                Assert.equals(0, value.length);
                asyncTest.done();
            },
            reason -> {
                Assert.fail(reason);
                asyncTest.done();
            }
        );
    }

    public function testAllSettled(asyncTest:Async) {
        var promises = [Promise.resolve(1), Promise.reject(2), Promise.resolve(3)];
        var aggregatePromise = promises.allSettled();

        aggregatePromise.then(
            value -> {
                Assert.equals("fulfilled", value[0].status);
                Assert.equals("rejected", value[1].status);
                Assert.equals("fulfilled", value[2].status);
                Assert.equals(1, (cast value[0]:FulfilledOutcome<Int>).value);
                Assert.equals(2, (cast value[1]:RejectedOutcome<Int>).reason);
                Assert.equals(3, (cast value[2]:FulfilledOutcome<Int>).value);
                asyncTest.done();
            },
            reason -> {
                Assert.fail(reason);
                asyncTest.done();
            }
        );
    }

    public function testAllSettledEmpty(asyncTest:Async) {
        var promises = [];
        var aggregatePromise = promises.allSettled();

        aggregatePromise.then(
            value -> {
                Assert.equals(0, value.length);
                asyncTest.done();
            },
            reason -> {
                Assert.fail(reason);
                asyncTest.done();
            }
        );
    }

    public function testRace(asyncTest:Async) {
        var promises = [Promise.resolve(1), Promise.reject(2)];

        var aggregatePromise = promises.race();

        aggregatePromise.then(
            value -> {
                Assert.equals(1, value);
                asyncTest.done();
            },
            reason -> {
                Assert.fail(reason);
                asyncTest.done();
            }
        );
    }

    public function testRace2(asyncTest:Async) {
        var promises = [new Promise((resolve, reject) -> {}), Promise.reject(2)];

        var aggregatePromise = promises.race();

        aggregatePromise.then(
            value -> {
                Assert.fail();
                asyncTest.done();
            },
            reason -> {
                Assert.equals(2, reason);
                asyncTest.done();
            }
        );
    }

    public function testCatch(asyncTest:Async) {
        var promise = Promise.resolve(1);

        promise.catch_(reason -> {
            Assert.fail();
            return 1;
        }).then(value -> { throw 2; })
        .catch_(reason -> {
            try {
                throw reason;
            } catch (exception:Any) {
                Assert.equals(2, exception);
            }
            asyncTest.done();
        });
    }

    public function testFinally(asyncTest:Async) {
        var promise = Promise.resolve(1);
        var flags = [];

        promise.finally(() -> {
            flags.push(1);
        }).then(value -> {
            Assert.equals(1, value);
            return Promise.reject(2);
        }).finally(() -> {
            flags.push(2);
        }).then(value -> {
            Assert.fail();
        }, reason -> {
            Assert.equals(2, reason);
            asyncTest.done();
        });
    }
}
