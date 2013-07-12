#
#  Connect group and view,
#  when super() is called in the initialize method
#
Backbone.View::initialize = () ->
  group_name = this.constructor.toString().match(/^function (\w+)/)[1]
  group = OngakuRyoho[group_name]

  _.each(["RecordBox", "SourceManager"], (cat) ->
    if OngakuRyoho[cat]
      group ?= OngakuRyoho[cat][group_name]
  )

  return unless group

  # view
  this.group = group
  this.group.view = this

  # machine
  Machine = OngakuRyoho.Classes.Machinery[group_name]

  _.each(["RecordBox", "SourceManager"], (cat) ->
    if OngakuRyoho.Classes.Machinery[cat]
      Machine ?= OngakuRyoho.Classes.Machinery[cat][group_name]
  )

  if Machine
    this.group.machine = new Machine
    this.group.machine.group = this.group
