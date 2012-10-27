#
#  Connect group and view,
#  when super() is called in the initialize method
#
Backbone.View::initialize = () ->
  group_name = this.constructor.toString().match(/^function (\w+)/)[1]
  group = OngakuRyoho[group_name]
  Machine = OngakuRyoho.Classes.Machinery[group_name]
  group.machine = new Machine if group and Machine
  group.view = this if group
  this.group = group
