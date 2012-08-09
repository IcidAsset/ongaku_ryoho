###

     ____                    __            ____              __
    / __ \____  ____ _____ _/ /____  __   / __ \__  ______  / /_  ____
   / / / / __ \/ __ `/ __ `/ #_ / / / /  / /_/ / / / / __ \/ __ \/ __ \
  / /_/ / / / / /_/ / /_/ / ,< / /_/ /  / _, _/ /_/ / /_/ / / / / /_/ /
  \____/_/ /_/\__, /\__,_/_/|_|\__,_/  /_/ |_|\__, /\____/_/ /_/\____/
             /____/                          /____/


  Main JS file with a touch of sprockets (.*)

###

#= require 'zepto'
#= require 'underscore'
#= require 'backbone'
#= require 'backbone_rails_sync'
#= require 'handlebars'
#= require 'jsdeferred'
#= require 'spin'

#= require './application/backbone_extensions'
#= require './application/helpers'
#= require './application/ongaku_ryoho'



Zepto ->

  # elements
  $controller       = $('#controller')
  $playlist         = $('#playlist')
  $source_manager   = $('#source-manager')
  $message_center   = $('#message-center')
  $visualizations   = $('#visualizations')
  $special_filters  = $('#special-filters')

  # helpers
  Helpers.initialize_before()

  # create new people
  OngakuRyoho.SoundGuy             = new OngakuRyoho.Classes.People.SoundGuy

  # backbone models
  OngakuRyoho.Controller           = new OngakuRyoho.Classes.Models.Controller

  # backbone collections
  OngakuRyoho.Tracks               = new OngakuRyoho.Classes.Collections.Tracks
  OngakuRyoho.Sources              = new OngakuRyoho.Classes.Collections.Sources
  OngakuRyoho.Messages             = new OngakuRyoho.Classes.Collections.Messages
  OngakuRyoho.Favourites           = new OngakuRyoho.Classes.Collections.Favourites

  # backbone views
  OngakuRyoho.MessageCenterView    = new OngakuRyoho.Classes.Views.MessageCenter({ el: $message_center })
  OngakuRyoho.VisualizationsView   = new OngakuRyoho.Classes.Views.Visualizations({ el: $visualizations })

  OngakuRyoho.ControllerView       = new OngakuRyoho.Classes.Views.Controller({ el: $controller })
  OngakuRyoho.PlaylistView         = new OngakuRyoho.Classes.Views.Playlist({ el: $playlist })
  OngakuRyoho.SourceManagerView    = new OngakuRyoho.Classes.Views.SourceManager({ el: $source_manager })

  # send people off to work
  OngakuRyoho.SoundGuy.go_to_work()

  # helpers
  Helpers.initialize_after()
