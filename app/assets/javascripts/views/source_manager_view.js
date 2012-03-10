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
    
    _.bindAll(this, 'setup_add_section', 'show', 'hide');
    
    // set elements
    $source_list_view = this.$el.find('.window.main section');
    $add_section      = this.$el.find('.window.add section');
    
    // main section
    this.source_list_view = new OngakuRyoho.Views.SourceListView({ el: $source_list_view  });
    
    // add section
    this.setup_add_section($add_section);
    
    // get content
    Sources.fetch();
  },
  
  
  /**************************************
   *  Setup add form
   */
  setup_add_section : function($add_section) {
    var $select,
        $forms;
    
    // set elements
    $select = $add_section.find('.select-wrapper select');
    $forms  = $add_section.find('.forms-wrapper form');
    
    // activate chosen plugin on 'source select'
    $select.chosen();
    
    // when the 'source selection' has changed
    $select.bind('change', function() {
      var $t    = $(this),
          klass = '.' + $t.val();
      
      $forms.not(klass).hide(0);
      $forms.filter(klass).show(0);
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
