class OngakuRyoho.Classes.Views.Visualizations extends Backbone.View

  #
  #  Initialize
  #
  initialize: () =>
    this.$peak_data = this.$el.children(".peak-data")
    @peak_data_canvas = this.$peak_data.children("canvas:first-child")[0]
    @peak_data_context = @peak_data_canvas.getContext("2d")

    # prepare
    @peak_data_canvas.width = 293
    @peak_data_canvas.height = 51



  #
  #  Visualize
  #
  visualize: (type, data) =>
    this[type](data)



  peak_data: (data) =>
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
    linear_gradient.addColorStop(0, "#BCF865")
    linear_gradient.addColorStop(0.6, "BCF865")
    linear_gradient.addColorStop(1, "#FF0000")

    c.fillStyle = linear_gradient

    # draw colors
    c.fillRect(0, 0, data[0], 21)
    c.fillRect(0, 30, data[1], 21)
