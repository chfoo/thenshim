#!/bin/bash

set -e

echo Install Haxe libraries
haxelib setup /home/ubuntu/haxelib/
yes | haxelib install hxcpp
yes | haxelib install hashlink
yes | haxelib install test.hxml

echo Install JS libraries
npm install promises-aplus-tests

echo Build project
haxe hxml/test.cpp.hxml
haxe hxml/test.hl.hxml
haxe hxml/test.js.hxml -D thenshim_js_fallback_allSettled -D thenshim_js_fallback_finally
haxe hxml/test_adapter.js.hxml

echo Run tests
./out/cpp/TestAll-debug
hl out/hl/test.hl
nodejs out/js/test.js
nodejs node_modules/promises-aplus-tests/lib/cli.js out/js/test_adapter.js
