/**
 * This example demonstrates incorrect parameter types to the promise interface.
 */
class IncorrectTypeExample {
    static function main() {
        var promise:js.Promise<Int> = js.Promise.resolve(123);

        promise.then(null, function (reason:Dynamic):js.Promise<String> {
            trace('reason: $reason');
            return js.Promise.resolve("abc");
        }).then(function (value:String) {
          	trace('value: $value');
            trace('type: ${Type.typeof(value)} (should be TClass)');
            trace('Std.is: ${Std.is(value, String)} (should be true)');
        });
    }
}
