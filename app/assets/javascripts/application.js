
/*

     ____                    __            ____              __
    / __ \____  ____ _____ _/ /____  __   / __ \__  ______  / /_  ____
   / / / / __ \/ __ `/ __ `/ //_/ / / /  / /_/ / / / / __ \/ __ \/ __ \
  / /_/ / / / / /_/ / /_/ / ,< / /_/ /  / _, _/ /_/ / /_/ / / / / /_/ /
  \____/_/ /_/\__, /\__,_/_/|_|\__,_/  /_/ |_|\__, /\____/_/ /_/\____/
             /____/                          /____/


  Main JS file with a touch of sprockets (.*)

*/

//= require 'jquery'
//= require 'underscore'
//= require 'backbone'
//= require 'backbone_rails_sync'
//= require 'backbone_datalink'
//= require 'mousewheel'
//= require 'scroll'
//= require 'chosen'
//= require 'noisy'
//= require 'labelify'
//= require 'spin'
//= require 'soundmanager2/soundmanager2'
//= provide 'soundmanager2/dependencies'

//= require '_helpers'
//= require 'ongaku_ryoho'

var _dom_init;



_dom_init = function() {
  var $controller     = $('#controller'),
      $playlist       = $('#playlist'),
      $source_manager = $('#source-manager'),
      $message_center = $('#message-center');

  // Backbone models
  window.Controller          = new OngakuRyoho.Models.Controller;

  // Backbone collections
  window.Tracks              = new OngakuRyoho.Collections.Tracks;
  window.Sources             = new OngakuRyoho.Collections.Sources;
  window.Messages            = new OngakuRyoho.Collections.Messages;

  // Backbone views
  window.ControllerView      = new OngakuRyoho.Views.Controller({ el: $controller });
  window.PlaylistView        = new OngakuRyoho.Views.Playlist({ el: $playlist });
  window.SourceManagerView   = new OngakuRyoho.Views.SourceManager({ el: $source_manager });
  window.MessageCenterView   = new OngakuRyoho.Views.MessageCenter({ el: $message_center });

  // Background
  $('body').noisy({
    intensity: 0.9,
    opacity: 0.125
  });
};



$(_dom_init);
