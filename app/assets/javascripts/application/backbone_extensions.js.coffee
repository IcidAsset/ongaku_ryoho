#
#  Connect group and view,
#  when super() is called in the initialize method
#
Backbone.View::initialize = () ->
  group_name = this.constructor.toString().match(/^function (\w+)/)[1]
  group = OngakuRyoho[group_name]
  this.group = group

  # this view
  group.view = this if group

  # machine
  Machine = OngakuRyoho.Classes.Machinery[group_name]

  if group and Machine
    group.machine = new Machine
    group.machine.group = group
