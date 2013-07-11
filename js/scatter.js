// Generated by CoffeeScript 1.4.0
(function() {
  var Collections, Rand, scatter_demo, zip;

  Collections = require("./base").Collections;

  Rand = require('../common/random').Rand;

  zip = function() {
    var arr, i, length, lengthArray, _i, _results;
    lengthArray = (function() {
      var _i, _len, _results;
      _results = [];
      for (_i = 0, _len = arguments.length; _i < _len; _i++) {
        arr = arguments[_i];
        _results.push(arr.length);
      }
      return _results;
    }).apply(this, arguments);
    length = Math.min.apply(Math, lengthArray);
    _results = [];
    for (i = _i = 0; 0 <= length ? _i < length : _i > length; i = 0 <= length ? ++_i : --_i) {
      _results.push((function() {
        var _j, _len, _results1;
        _results1 = [];
        for (_j = 0, _len = arguments.length; _j < _len; _j++) {
          arr = arguments[_j];
          _results1.push(arr[i]);
        }
        return _results1;
      }).apply(this, arguments));
    }
    return _results;
  };

  scatter_demo = function(div_id) {
    var colors, i, r, radii, scatter, source, val, x, xdr, y, ydr;
    r = new Rand(123456789);
    x = (function() {
      var _i, _len, _ref, _results;
      _ref = _.range(4000);
      _results = [];
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        i = _ref[_i];
        _results.push(r.randf() * 100);
      }
      return _results;
    })();
    y = (function() {
      var _i, _len, _ref, _results;
      _ref = _.range(4000);
      _results = [];
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        i = _ref[_i];
        _results.push(r.randf() * 100);
      }
      return _results;
    })();
    radii = (function() {
      var _i, _len, _ref, _results;
      _ref = _.range(4000);
      _results = [];
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        i = _ref[_i];
        _results.push(r.randf() + 0.3);
      }
      return _results;
    })();
    colors = (function() {
      var _i, _len, _ref, _results;
      _ref = zip(x, y);
      _results = [];
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        val = _ref[_i];
        _results.push("rgb(" + (Math.floor(50 + 2 * val[0])) + ", " + (Math.floor(30 + 2 * val[1])) + ", 150)");
      }
      return _results;
    })();
    source = Collections('ColumnDataSource').create({
      data: {
        x: x,
        y: y,
        radius: radii,
        fill: colors
      }
    });
    xdr = Collections('Range1d').create({
      start: 0,
      end: 100
    });
    ydr = Collections('Range1d').create({
      start: 0,
      end: 100
    });
    scatter = {
      x: 'x',
      y: 'y',
      radius: 'radius',
      radius_units: 'data',
      fill: 'fill',
      fill_alpha: 0.6,
      type: 'circle',
      line_color: null
    };
    return this.make_plot(div_id, source, {}, [scatter], xdr, ydr, {
      dims: [600, 600],
      plot_title: "",
      legend: false
    });
  };

  this.scatter_demo = scatter_demo;

}).call(this);
