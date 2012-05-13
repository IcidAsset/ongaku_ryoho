OngakuRyoho.Views.SourceManager = Backbone.View.extend({

  events : {
    'click .background' : 'hide'
  },


  /**************************************
   *  Initialize
   */
  initialize : function() {
    var $source_list_view,
        $add_section;

    _.bindAll(this,
      'check_sources', 'find_sources_to_process', 'find_sources_to_check',
      'setup_add_section', 'show', 'hide'
    );

    // set elements
    $source_list_view = this.$el.find('.window.main section');
    $add_section      = this.$el.find('.window.add section');

    // main section
    this.source_list_view = new OngakuRyoho.Views.SourceList({ el: $source_list_view  });

    // add section
    this.setup_add_section($add_section);
  },


  /**************************************
   *  Check sources
   */
  check_sources : function() {
    this.find_sources_to_process();
  },


  find_sources_to_process : function() {
    var unprocessed_sources, unprocessing, unprocessing_message;

    // find
    unprocessed_sources = _.filter(Sources.models, function(source) {
      return source.get('status').indexOf('unprocessed') != -1
    });

    // exec
    if (unprocessed_sources.length > 0) {
      unprocessing = _.map(unprocessed_sources, function(unprocessed_source, idx) {
                       return SourceManagerView.process_source(unprocessed_source);
                     });

      unprocessing_message = new OngakuRyoho.Models.Message({
        text: 'Processing sources',
        loading: true
      });

      Messages.add(unprocessing_message);

      $.when.apply(null, unprocessing)
       .then(function() {
         SourceManagerView.requires_reload = true;
         SourceManagerView.find_sources_to_check(unprocessed_sources);

         Messages.remove(unprocessing_message);
       });

    } else {
      this.find_sources_to_check();

    }
  },


  find_sources_to_check : function(unprocessed_sources) {
    var sources_to_check, checking, checking_message, after, changes;

    // check
    unprocessed_sources = unprocessed_sources || [];

    // after
    after = function() {
      Tracks.fetch();
      Sources.fetch();

      SourceManagerView.requires_reload = false;
    };

    // find
    sources_to_check = _.difference(Sources.models, unprocessed_sources);

    // exec
    if (sources_to_check.length > 0) {
      checking = _.map(sources_to_check, function(source_to_check, idx) {
                   return SourceManagerView.check_source(source_to_check);
                 });

      checking_message = new OngakuRyoho.Models.Message({
        text: 'Checking out sources',
        loading: true
      });

      Messages.add(checking_message);

      $.when.apply(null, checking)
       .then(function() {
         if (_.has(arguments[0], 'changed')) {
           changes = _.pluck(arguments, 'changed');
         } else {
           changes = _.map(arguments, function(x) { return x[0].changed; });
         }

         changes = _.include(changes, true);

         if (changes || SourceManagerView.requires_reload) {
           after();
         }

         Messages.remove(checking_message);
       });

    } else {
      if (this.requires_reload) { after(); }

    }
  },


  process_source : function(source) {
    return $.get('/sources/' + source.get('_id') + '/process');
  },


  check_source : function(source) {
    return $.get('/sources/' + source.get('_id') + '/check');
  },


  /**************************************
   *  Setup add forms
   */
  setup_add_section : function($add_section) {
    var $select,
        $forms_wrapper,
        $forms;

    // set elements
    $select = $add_section.find('.select-wrapper select');
    $forms_wrapper = $add_section.find('.forms-wrapper');

    // activate chosen plugin on 'source select'
    $select.chosen();

    // when the 'source selection' has changed
    $select.on('change', function() {
      var $t    = $(this),
          klass = '.' + $t.val();

      $forms.not(klass).hide(0);
      $forms.filter(klass).show(0);
    });

    // load forms
    $.when(
      $.get('/servers/new')

    ).then(function(servers_form) {
      $forms_wrapper.append( servers_form );

      $forms = $forms_wrapper.children('form');
      $forms.find('input').labelify();

    });
  },


  /**************************************
   *  Show & Hide
   */
  show : function() {
    this.$el.stop(true, true).fadeIn(0);
  },

  hide : function() {
    this.$el.stop(true, true).fadeOut(0);
  }


});
