###

     ____                    __            ____              __
    / __ \____  ____ _____ _/ /____  __   / __ \__  ______  / /_  ____
   / / / / __ \/ __ `/ __ `/ #_ / / / /  / /_/ / / / / __ \/ __ \/ __ \
  / /_/ / / / / /_/ / /_/ / ,< / /_/ /  / _, _/ /_/ / /_/ / / / / /_/ /
  \____/_/ /_/\__, /\__,_/_/|_|\__,_/  /_/ |_|\__, /\____/_/ /_/\____/
             /____/                          /____/


  Main JS file with a touch of sprockets (.*)

###

#= require 'jquery'
#= require 'underscore'
#= require 'backbone'
#= require 'backbone_rails_sync'
#= require 'backbone_datalink'
#= require 'spin'
#= require 'jquery-cookie'
#= require 'soundmanager2/soundmanager2'
#= provide 'soundmanager2/dependencies'

#= require 'helpers'
#= require 'ongaku_ryoho'



$(document).ready ->
  
  # elements
  $controller       = $('#controller')
  $playlist         = $('#playlist')
  $source_manager   = $('#source-manager')
  $message_center   = $('#message-center')
  $visualizations   = $('#visualizations')
  $special_filters  = $('#special-filters')

  # helpers
  helpers.initialize_before()

  # backbone models
  window.Controller           = new OngakuRyoho.Models.Controller

  # backbone collections
  window.Tracks               = new OngakuRyoho.Collections.Tracks
  window.Sources              = new OngakuRyoho.Collections.Sources
  window.Messages             = new OngakuRyoho.Collections.Messages
  window.Favourites           = new OngakuRyoho.Collections.Favourites

  # backbone views
  window.MessageCenterView    = new OngakuRyoho.Views.MessageCenter({ el: $message_center })
  window.VisualizationsView   = new OngakuRyoho.Views.Visualizations({ el: $visualizations })
  window.SpecialFiltersView   = new OngakuRyoho.Views.SpecialFilters({ el: $special_filters })

  window.ControllerView       = new OngakuRyoho.Views.Controller({ el: $controller })
  window.PlaylistView         = new OngakuRyoho.Views.Playlist({ el: $playlist })
  window.SourceManagerView    = new OngakuRyoho.Views.SourceManager({ el: $source_manager })

  # helpers
  helpers.initialize_after()
