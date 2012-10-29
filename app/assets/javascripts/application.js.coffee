###

     ____                    __            ____              __
    / __ \____  ____ _____ _/ /____  __   / __ \__  ______  / /_  ____
   / / / / __ \/ __ `/ __ `/ #_ / / / /  / /_/ / / / / __ \/ __ \/ __ \
  / /_/ / / / / /_/ / /_/ / ,< / /_/ /  / _, _/ /_/ / /_/ / / / / /_/ /
  \____/_/ /_/\__, /\__,_/_/|_|\__,_/  /_/ |_|\__, /\____/_/ /_/\____/
             /____/                          /____/


  Main JS file

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
  Engines = App.Classes.Engines
  People = App.Classes.People
  Models = App.Classes.Models
  Collections = App.Classes.Collections
  Views = App.Classes.Views

  # helpers
  Helpers.initialize_before()

  # objects
  App.Engines = {}
  App.Engines.Audio = new Engines.Audio
  App.Engines.Queue = new Engines.Queue

  App.People = {}
  App.People.SoundGuy = new People.SoundGuy

  App.MixingConsole = {}
  App.MixingConsole.model = new Models.MixingConsole
  App.MixingConsole.view = new Views.MixingConsole

  App.MessageCenter = {}
  App.MessageCenter.collection = new Collections.Messages
  App.MessageCenter.view = new Views.MessageCenter

  App.Visualizations = {}
  App.Visualizations.view = new Views.Visualizations

  App.Playlist = {}
  App.Playlist.Tracks = {}
  App.Playlist.Tracks.collection = new Collections.Tracks
  App.Playlist.Tracks.view = new Views.Playlist.Tracks
  App.Playlist.Favourites = {}
  App.Playlist.Favourites.collection = new Collections.Favourites
  App.Playlist.Navigation = {}
  App.Playlist.Navigation.view = new Views.Playlist.Navigation
  App.Playlist.Footer = {}
  App.Playlist.Footer.view = new Views.Playlist.Footer

  App.SourceManager = {}
  App.SourceManager.collection = new Collections.Sources
  App.SourceManager.view = new Views.SourceManager

  # send people off to work
  App.People.SoundGuy.go_to_work()

  # helpers
  Helpers.initialize_after()

  # get data
  App.SourceManager.collection.fetch({ success: App.SourceManager.collection.process_and_check_sources })
