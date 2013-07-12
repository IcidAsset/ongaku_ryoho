#
#  Connect group and view,
#  when super() is called in the initialize method
#
Backbone.View::initialize = (group_name) ->
  group = OngakuRyoho[group_name]
  group ?= OngakuRyoho.RecordBox[group_name] if OngakuRyoho.RecordBox
  return unless group

  # view
  this.group = group
  this.group.view = this

  # machine
  Machine = OngakuRyoho.Classes.Machinery[group_name]
  Machine ?= OngakuRyoho.Classes.Machinery.RecordBox[group_name] if OngakuRyoho.RecordBox

  if Machine
    this.group.machine = new Machine
    this.group.machine.group = this.group
