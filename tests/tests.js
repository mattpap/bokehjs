module("Basic Tests");


test("truthy", function() {
    require(["/js/adder.js"], function(adder_mod){
            alert(adder_mod.adder(5,5));
    });
    ok(true, "true is truthy");
    equal(1, true, "1 is truthy");
    notEqual(0, true, "0 is NOT truthy");
});
