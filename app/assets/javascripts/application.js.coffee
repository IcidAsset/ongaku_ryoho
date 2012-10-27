###

     ____                    __            ____              __
    / __ \____  ____ _____ _/ /____  __   / __ \__  ______  / /_  ____
   / / / / __ \/ __ `/ __ `/ #_ / / / /  / /_/ / / / / __ \/ __ \/ __ \
  / /_/ / / / / /_/ / /_/ / ,< / /_/ /  / _, _/ /_/ / /_/ / / / / /_/ /
  \____/_/ /_/\__, /\__,_/_/|_|\__,_/  /_/ |_|\__, /\____/_/ /_/\____/
             /____/                          /____/


  Main JS file with a touch of sprockets (.*)

###

#= require "zepto"
#= require "underscore"
#= require "backbone"
#= require "backbone_rails_sync"
#= require "handlebars"
#= require "jsdeferred"
#= require "spin"

#= require "./application/backbone_extensions"
#= require "./application/helpers"
#= require "./application/ongaku_ryoho"



Zepto ->
  App = OngakuRyoho

  # elements
  $mixing_console   = $("#mixing-console")
  $message_center   = $("#message-center")
  $visualizations   = $("#visualizations")
  $playlist         = $("#playlist")
  $source_manager   = $("#source-manager")

  # helpers
  Helpers.initialize_before()

  # objects
  App.Engines = {}
  App.Engines.Audio = new App.Classes.Engines.Audio

  App.People = {}
  App.People.SoundGuy = new App.Classes.People.SoundGuy

  App.MixingConsole = {}
  App.MixingConsole.model = new App.Classes.Models.MixingConsole
  App.MixingConsole.view = new App.Classes.Views.MixingConsole({ el: $mixing_console })

  App.MessageCenter = {}
  App.MessageCenter.collection = new App.Classes.Collections.Messages
  App.MessageCenter.view = new App.Classes.Views.MessageCenter({ el: $message_center })

  App.Visualizations = {}
  App.Visualizations.view = new App.Classes.Views.Visualizations({ el: $visualizations })

  App.Playlist = {}
  App.Playlist.Tracks = {}
  App.Playlist.Tracks.collection = new App.Classes.Collections.Tracks
  App.Playlist.Tracks.view = new App.Classes.Views.Playlist.Tracks({ el: $playlist.find(".tracks-wrapper") })
  App.Playlist.Favourites = {}
  App.Playlist.Favourites.collection = new App.Classes.Collections.Favourites
  App.Playlist.Navigation = {}
  App.Playlist.Navigation.view = new App.Classes.Views.Playlist.Navigation({ el: $playlist.children(".navigation") })
  App.Playlist.Footer = {}
  App.Playlist.Footer.view = new App.Classes.Views.Playlist.Footer({ el: $playlist.children("footer") })

  App.SourceManager = {}
  App.SourceManager.collection = new App.Classes.Collections.Sources
  App.SourceManager.view = new App.Classes.Views.SourceManager({ el: $source_manager })

  # send people off to work
  App.People.SoundGuy.go_to_work()

  # helpers
  Helpers.initialize_after()

  # get data
  App.SourceManager.collection.fetch({ success: App.SourceManager.collection.process_and_check_sources })
