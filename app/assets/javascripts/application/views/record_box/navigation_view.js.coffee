class OngakuRyoho.Classes.Views.RecordBox.Navigation extends Backbone.View

  #
  #  Events
  #
  events: () ->
    "click .toggle-queue" : @group.machine.toggle_queue



  #
  #  Initialize
  #
  initialize: () ->
    super

    # this element
    this.setElement($("#record-box").children(".navigation")[0])

    # track list header
    this.$track_list_header = this.$el.next(".list").children("header")
    this.$track_list_header.on("click", "[data-sort-key]", @group.machine.sort_key_column_click_handler)
