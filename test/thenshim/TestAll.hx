package thenshim;

import utest.Runner;
import utest.ui.Report;

class TestAll {
    public static function main() {
        var runner = new Runner();
        #if (promises_aplus_tests)
            runner.addCase(new thenshim.test.fallback.TestPAPCompliance());
        #end
        runner.addCase(new thenshim.test.TestPromise());
        Report.create(runner);
        runner.run();
    }
}
