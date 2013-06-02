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
#= require "backbone-rails-sync"
#= require "modernizr-custom"
#= require "handlebars"
#= require "rsvp"
#= require "mousetrap"
#= require "hammer"
#= require "spin"
#= require "browser"
#= require "bare-tooltip"

#= require "./application/backbone_extensions"
#= require "./application/ongaku_ryoho"
#= require "./application/helpers"
#= require "./application/legacy"
#= require "./application/bsc"



initialize = ->
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
  App.People.ViewStateManager = new People.ViewStateManager
  App.People.KeyMaster = new People.KeyMaster

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
  App.RecordBox.Navigation = {}
  App.RecordBox.Navigation.view = new Views.RecordBox.Navigation
  App.RecordBox.Footer = {}
  App.RecordBox.Footer.view = new Views.RecordBox.Footer
  App.RecordBox.UserMenu = {}
  App.RecordBox.UserMenu.view = new Views.RecordBox.UserMenu
  App.RecordBox.Filter = {}
  App.RecordBox.Filter.model = new Models.Filter
  App.RecordBox.Filter.view = new Views.RecordBox.Filter

  App.RecordBox.Tracks = {}
  App.RecordBox.Tracks.collection = new Collections.Tracks
  App.RecordBox.Tracks.view = new Views.RecordBox.Tracks
  App.RecordBox.Favourites = {}
  App.RecordBox.Favourites.collection = new Collections.Favourites
  App.RecordBox.Playlists = {}
  App.RecordBox.Playlists.collection = new Collections.Playlists

  App.SourceManager = {}
  App.SourceManager.collection = new Collections.Sources
  App.SourceManager.view = new Views.SourceManager.Modal

  # send people off to work
  App.People.SoundGuy.go_to_work()
  App.People.ViewStateManager.go_to_work()
  App.People.KeyMaster.go_to_work()

  # check for legacy stuff
  window.Legacy.check()



Zepto ->
  supported = BSC.check()

  if supported
    initialize()
  else
    BSC.show_not_supported_message()
