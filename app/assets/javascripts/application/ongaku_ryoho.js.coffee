#= require_self
#= require_tree './machinery'
#= require_tree './models'
#= require_tree './collections'
#= require_tree './views'
#= require_tree './people'

window.OngakuRyoho =

  Classes:
    Models: {}
    Collections: {}
    Views: {}
    People: {}

  Instances: {}
  Machinery: {}

  EventAlligator: _.extend({}, Backbone.Events)



window.颪 = window.OngakuRyoho.Instances
