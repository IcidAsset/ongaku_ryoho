#
#  Connect machine and view,
#  when super() is called
#
Backbone.View.prototype.initialize = () ->
  machine_name = this.constructor.toString().match(/^function (\w+)/)[1]
  machine = OngakuRyoho.Machinery[machine_name]

  this.machine = machine
  this.machine.view = this
