module("Basic Tests");


test("truthy", function() {
    ok(true, "true is truthy");
    equal(1, true, "1 is truthy");
    notEqual(0, true, "0 is NOT truthy");
});

asyncTest("an asynchonous test example", function() {
    expect(1);
    require(["/js/adder.js"], function(adder_mod){
        equal(adder_mod.adder(5,5), 10);
        start();
    });
});
