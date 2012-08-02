#
#  Connect machine and view,
#  when super() is called in the initialize method
#
Backbone.View.prototype.initialize = () ->
  machine_name = this.constructor.toString().match(/^function (\w+)/)[1]
  Machine = OngakuRyoho.Classes.Machinery[machine_name]

  if Machine
    this.machine = new Machine
    this.machine.view = this
