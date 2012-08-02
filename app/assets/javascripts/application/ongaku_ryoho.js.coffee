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
    Machinery: {}

  Instances: {}



window.ℰ = window.OngakuRyoho.Instances
window.ℳ = (instance) -> instance.machine
