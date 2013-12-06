(function($) {
  Backbone.original_sync = Backbone.sync;

  Backbone.sync = function(method, model, options) {
    options = options || {};

    if (!options.noCSRF) {
      var token = $('meta[name="csrf-token"]').attr('content');
      if (token) options.headers = { 'X-CSRF-Token' : token };
    }

    Backbone.original_sync(method, model, options);
  };
})(Zepto);
