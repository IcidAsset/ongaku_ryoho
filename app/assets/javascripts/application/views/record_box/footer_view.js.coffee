class OngakuRyoho.Classes.Views.RecordBox.Footer extends Backbone.View

  #
  #  Events
  #
  events: () ->
    "click .page-nav .previous:not(.disabled)"    : @group.machine.previous_page_button_click_handler
    "click .page-nav .next:not(.disabled)"        : @group.machine.next_page_button_click_handler
    "dblclick .intestines > span"                 : @group.machine.intestines_span_dbl_click_handler



  #
  #  Initialize
  #
  initialize: () ->
    super("Footer")

    # this element
    Helpers.set_view_element(this, ".mod-record-box footer")

    # machine
    @group.machine.setup_tls_menu()



  #
  #  Set contents
  #
  set_contents: (html) ->
    this.el.querySelector(".intestines > span").innerHTML = html
