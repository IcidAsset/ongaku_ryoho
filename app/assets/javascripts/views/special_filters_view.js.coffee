class OngakuRyoho.Views.SpecialFilters extends Backbone.View
  
  #
  #  Events
  #
  events:
    "click #favourites a" : "favourites_switch_click"



  #
  #  Initialize
  #
  initialize: () =>
    this.$favourites = this.$el.children("#favourite")



  #
  #  Favourites switch click
  #
  favourites_switch_click: (e) =>
    $t = $(e.currentTarget)
    
    # switch
    if Tracks.favourites
      $t.removeClass("on")
      Tracks.favourites = off
      
    else
      $t.addClass("on")
      Tracks.favourites = on
    
    
    # fetch tracks
    Tracks.fetch()
    
    # prevent default
    e.preventDefault()
    return false
