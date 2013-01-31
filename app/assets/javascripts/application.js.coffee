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
#= require "rsvp"
#= require "hammer"
#= require "spin"
#= require "browser"
#= require "modernizr_custom"

#= require "./application/backbone_extensions"
#= require "./application/ongaku_ryoho"
#= require "./application/helpers"
#= require "./application/legacy"



Zepto ->
  App = OngakuRyoho
  Engines = App.Classes.Engines
  People = App.Classes.People
  Models = App.Classes.Models
  Collections = App.Classes.Collections
  Views = App.Classes.Views
  Routers = App.Classes.Routers

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

  App.DropZones = {}
  App.DropZones.view = new Views.DropZones

  App.RecordBox = {}
  App.RecordBox.Tracks = {}
  App.RecordBox.Tracks.collection = new Collections.Tracks
  App.RecordBox.Tracks.view = new Views.RecordBox.Tracks
  App.RecordBox.Favourites = {}
  App.RecordBox.Favourites.collection = new Collections.Favourites
  App.RecordBox.Navigation = {}
  App.RecordBox.Navigation.view = new Views.RecordBox.Navigation
  App.RecordBox.Footer = {}
  App.RecordBox.Footer.view = new Views.RecordBox.Footer

  App.SourceManager = {}
  App.SourceManager.collection = new Collections.Sources
  App.SourceManager.view = new Views.SourceManager

  App.UserMenu = {}
  App.UserMenu.view = new Views.UserMenu

  # send people off to work
  App.People.SoundGuy.go_to_work()

  # get data
  Helpers.promise_fetch(App.RecordBox.Favourites.collection)
    .then -> Helpers.promise_fetch(App.RecordBox.Tracks.collection)
    .then -> Helpers.promise_fetch(App.SourceManager.collection)
    .then -> App.SourceManager.collection.process_and_check_sources()
    .then ->
      console.log("done")
      App.Router = new Routers.Default

  # check for legacy stuff
  window.Legacy.check()
