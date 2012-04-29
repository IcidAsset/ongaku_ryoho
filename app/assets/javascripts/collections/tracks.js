OngakuRyoho.Collections.Tracks = Backbone.Collection.extend({
  
  model: OngakuRyoho.Models.Track,
  url: '/tracks/',


  initialize : function() {
    _.bindAll(this,
      'parse', 'page_info',
      'previous_page', 'next_page'
    );
    
    this.page = 1;
    this.per_page = 250;
    this.filter = '';
  },
 

  fetch : function(options) {
    var self, success, filter;

    // set
    self = this;
    options = options || {};
    success = options.success;

    // show message
    message = new OngakuRyoho.Models.Message({
      text: 'Loading tracks',
      loading: true
    });
    
    Messages.add(message);

    // trigger event
    this.trigger('fetching');

    // pagination and filter
    options.data = options.data || {};
    $.extend(options.data, {
      page: this.page,
      per_page: this.per_page,
      filter: this.filter
    });

    // success
    options.success = function(response) {
      if (success) { success(self, response); }
      self.trigger('fetched');
      Messages.remove(message);
    };

    // call
    return Backbone.Collection.prototype.fetch.call(this, options);
  },


  parse : function(response) {
    this.page = response.page;
    this.per_page = response.per_page;
    this.total = response.total;
    return response.models;
  },


  page_info : function() {
    var info, max;

    info = {
      total: this.total,
      page: this.page,
      per_page: this.per_page,
      pages: Math.ceil(this.total / this.per_page),
      prev: false,
      next: false
    };

    max = Math.min(this.total, this.page * this.per_page);

    if (this.total == this.pages * this.per_page) {
      max = this.total;
    }

    info.range = [(this.page - 1) * this.per_page + 1, max];

    if (this.page > 1) {
      info.prev = this.page - 1;
    }

    if (this.page < info.pages) {
      info.next = this.page + 1;
    }

    return info;
  },


  previous_page : function() {
    if (!this.page_info().prev) { return false; }

    this.page = this.page - 1;
    return this.fetch();
  },


  next_page : function() {
    if (!this.page_info().next) { return false; }
    
    this.page = this.page + 1;
    return this.fetch();
  }
  
});
