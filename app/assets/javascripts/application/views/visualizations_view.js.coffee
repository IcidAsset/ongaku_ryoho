class OngakuRyoho.Classes.Views.Visualizations extends Backbone.View

  #
  #  Initialize
  #
  initialize: () ->
    Helpers.set_view_element(this, ".mod-visualizations")

    # peak data
    peak_data_canvas = this.$el.find(".peak-data canvas:first-child")[0]
    peak_data_canvas.width = 293
    peak_data_canvas.height = 51

    @peak_data_context = peak_data_canvas.getContext("2d")



  #
  #  Visualize
  #
  visualize: (type, data) ->
    this[type](data)



  peak_data: (data) ->
    c = @peak_data_context

    # clear canvas
    c.clearRect(0, 0, c.canvas.width, c.canvas.height)

    # begin path
    c.beginPath()

    # loop
    for i in [0...c.canvas.width] by 3
      c.moveTo(i, 0)
      c.lineTo(i, 51)
      c.lineTo(i + 1, 51)
      c.lineTo(i + 1, 0)

    # clip
    c.clip()

    # colors
    linear_gradient = c.createLinearGradient(0, 51, c.canvas.width, 51)
    linear_gradient.addColorStop(0, "rgba(0, 0, 0, .2)")
    linear_gradient.addColorStop(0.6, "rgba(0, 0, 0, .3)")
    linear_gradient.addColorStop(1, "#FF0000")

    c.fillStyle = linear_gradient

    # draw colors
    c.fillRect(0, 0, data[0], 21)
    c.fillRect(0, 30, data[1], 21)

    # nullify
    c = null
