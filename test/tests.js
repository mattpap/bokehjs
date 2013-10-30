define(["/js/adder.js"], function(adder){
    module("Basic Tests");
    test("truthy", function() {
        ok(true, "true is truthy");
        equal(1, true, "1 is truthy");
        notEqual(0, true, "0 is NOT truthy");
    });

    test("synch normal test example", function() {
            equal(adder.adder(5,5), 10);
    });
});
