class OngakuRyoho.Classes.Views.RecordBox.Footer extends Backbone.View

  #
  #  Events
  #
  events: () ->
    "click .page-nav .previous:not(.disabled)"    : @group.machine.previous_page_button_click_handler
    "click .page-nav .next:not(.disabled)"        : @group.machine.next_page_button_click_handler



  #
  #  Initialize
  #
  initialize: () ->
    super

    # this element
    Helpers.set_view_element(this, "#record-box footer")



  #
  #  Set contents
  #
  set_contents: (html) ->
    this.$el.find(".intestines").html(html)
