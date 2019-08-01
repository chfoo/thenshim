package thenshim.test.fallback;

import utest.Assert;
import utest.Test;
import thenshim.fallback.FallbackPromise;
import thenshim.fallback.FallbackPromiseFactory;

class TestPAPCompliance extends Test {
    @Ignored("Use node_modules/promises-aplus-tests/lib/cli.js out/js/test_adapter.js")
    @:timeout(300000)
    public function test(async:utest.Async) {
        var promisesAplusTests = js.Lib.require("promises-aplus-tests");

        promisesAplusTests(PAPTestAdapter.adapter, err -> {
            Assert.equals(0, err);
            async.done();
        });
    }
}
