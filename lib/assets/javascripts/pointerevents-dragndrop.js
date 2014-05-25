/*

  Pointerevents - Drag n' Drop
  v0.2.0

*/

(function($) {

  "use strict";

  var __bind = function(fn, me) {
    return function() { return fn.apply(me, arguments); };
  };



  //
  //  Default settings
  //
  DD.prototype.settings = {
    delegate_selector: false,
    drag_icon_classname: "drag-icon",
    time_until_drag: 400
  };



  //
  //  Constructor
  //
  function DD(element, settings) {
    this.$el = (function() {
      if (element instanceof $) {
        return element;
      } else if ($.isArray(element)) {
        return element;
      } else {
        return $(element);
      }
    })();

    // settings
    this.settings = {};
    $.extend(this.settings, DD.prototype.settings, settings || {});

    // bind to self
    this.bind_to_self([
      "pointer_down_handler",
      "pointer_move_handler",
      "pointer_up_handler",
      "touch_start_handler",
      "prevent_default",
      "document_pointerout_handler"
    ]);

    // setup
    this.set_initial_state_object();
    this.bind_events();
  }



  //
  //  State
  //
  DD.prototype.set_initial_state_object = function() {
    this.state = {
      dragging: false,
      dragging_timestamp: false,
      dragging_origin: false,
      start_coordinates: false,
      last_toElement: false,
      pointers: {},
      amount_of_touches: 0,
      timeouts: []
    };
  };


  DD.prototype.reset_state = function() {
    if (this.state.touch_action_map) {
      for (var i=0, j=this.state.touch_action_map.length; i<j; ++i) {
        var obj = this.state.touch_action_map[i];
        obj.el.setAttribute("touch-action", obj.original);
      }
    }

    this.state.dragging = false;
    this.state.dragging_timestamp = false;
    this.state.dragging_origin = false;
    this.state.last_toElement = false;
    this.state.amount_of_touches = 0;
    this.state.touch_action_map = null;

    this.clear_timeouts();
  };


  DD.prototype.clear_timeouts = function() {
    if (!this.state.timeouts.length) return;

    var timeouts = this.state.timeouts.splice(
      0, this.state.timeouts.length
    );

    for (var i=0,j=timeouts.length; i<j; ++i) {
      clearTimeout(timeouts[i]);
    }
  };


  DD.prototype.start_drag = function(pointer_event) {
    this.state.dragging = true;
    this.show_drag_icon(pointer_event.pageX, pointer_event.pageY);

    if (this.state.touch_action_map) {
      for (var i=0, j=this.state.touch_action_map.length; i<j; ++i) {
        this.state.touch_action_map[i].el.setAttribute("touch-action", "none");
      }
    }

    $(this.state.dragging_origin).trigger("pointerdragstart");
    $(document.body).addClass("dragging");
  };


  DD.prototype.stop_drag = function(pointer_event) {
    this.unbind_move_and_up_handler();

    $(document.body).removeClass("dragging");
    $(this.state.dragging_origin).trigger("pointerdragend");

    this.hide_drag_icon();
    this.reset_state();
  };



  //
  //  Events / General
  //
  DD.prototype.bind_events = function() {
    var events = [], i, j;

    events.push(["pointerdown", this.pointer_down_handler]);
    events.push(["touchstart", this.touch_start_handler]);

    events.push(["dragstart", this.prevent_default]);
    events.push(["drop", this.prevent_default]);
    events.push(["mousedown", this.prevent_default]);

    // the end
    j = events.length;

    // delegate?
    if (this.settings.delegate_selector) {
      for (i=0; i<j; ++i) {
        events[i].splice(1, 0, this.settings.delegate_selector);
      }
    }

    // bind
    for (i=0; i<j; ++i) {
      this.$el.on.apply(this.$el, events[i]);
    }

    // special events
    $(document).on("pointerout", this.document_pointerout_handler);
  };


  DD.prototype.unbind_move_and_up_handler = function() {
    var $doc = $(document);
    $doc.off("pointermove", this.pointer_move_handler);
    $doc.off("pointerup", this.pointer_up_handler);
  };



  //
  //  Events / Pointer events
  //
  DD.prototype.pointer_down_handler = function(e) {
    var $doc = $(document);
    var touch_action_map;
    var eo;

    // dismiss clicks from right or middle mouse buttons
    var btn = (e.originalEvent || e).button;
    if (btn && (btn !== 0 && btn !== 1)) return;

    // touch action map
    touch_action_map = this.collect_parent_nodes(e.currentTarget).reverse();
    touch_action_map = $(touch_action_map).filter("[touch-action]");
    touch_action_map = touch_action_map.map(function(idx, el) {
      return {
        original: el.getAttribute("touch-action"),
        scroll_top: el.scrollTop,
        el: el,
        idx: idx
      };
    }).get();

    // state
    this.state.dragging_timestamp = new Date().getTime();
    this.state.dragging_origin = e.currentTarget;
    this.state.touch_action_map = touch_action_map;

    // e.preventDefault();
    eo = e.originalEvent || e;

    // trigger pointer move
    this.state.timeouts.push(setTimeout(__bind(function() {
      this.pointer_move_handler(e, true);
    }, this), this.settings.time_until_drag));

    // state
    this.state.start_coordinates = {
      x: eo.pageX,
      y: eo.pageY
    };

    this.state.pointers[eo.pointerId.toString()] = {
      pointerType: eo.pointerType,
      pointerId: eo.pointerId
    };

    // document -> pointermove
    $doc.on("pointermove", this.pointer_move_handler);

    // stop everything on pointerup
    $doc.one("pointerup", this.pointer_up_handler);
  };


  DD.prototype.pointer_move_handler = function(e, via_pointer_start) {
    var eo, start_time, now_time, diff_time, start_pos, now_pos, diff_pos,
        diff_scroll;

    eo = e.originalEvent || e;

    if (this.state.dragging) {
      e.preventDefault();

      this.move_drag_icon(eo.pageX, eo.pageY);
      this.trigger_additional_drag_events(eo);

    } else {
      // time difference
      start_time = this.state.dragging_timestamp;
      now_time = new Date().getTime();
      diff_time = now_time - start_time;

      // "cursor" position difference
      start_pos = this.state.start_coordinates;
      now_pos = { x: eo.pageX, y: eo.pageY };

      diff_pos = Math.sqrt(
        Math.pow(now_pos.x - start_pos.x, 2) +
        Math.pow(now_pos.y - start_pos.y, 2)
      );

      // scroll position difference
      diff_scroll = 0;

      $.each(this.state.touch_action_map, function(idx, t) {
        diff_scroll = diff_scroll + Math.abs(
          t.scroll_top - t.el.scrollTop
        );
      });

      // start drag or do something else
      if (diff_pos <= 15 && diff_scroll === 0 && this.state.amount_of_touches < 2) {
        e.preventDefault();

        if (via_pointer_start) {
          this.start_drag(eo);
        } else if (diff_time >= this.settings.time_until_drag) {
          this.clear_timeouts();
          this.start_drag(eo);
        }
      } else if (diff_scroll === 0) {
        this.pointer_up_handler(e);
      } else {
        this.clear_timeouts();
      }

    }
  };


  DD.prototype.pointer_up_handler = function(e) {
    var eo;

    e.preventDefault();
    eo = e.originalEvent || e;

    delete this.state.pointers[e.pointerId.toString()];

    // trigger drop event
    // and stop dragging if needed
    if (this.state.dragging) {
      $(eo.target).trigger("pointerdrop");
      this.stop_drag(eo);

    // otherwise,
    // do a reset
    } else {
      this.unbind_move_and_up_handler();
      this.reset_state();

    }
  };



  //
  //  Events / Touch events
  //
  DD.prototype.touch_start_handler = function(e) {
    e = e.originalEvent || e;
    this.state.amount_of_touches = e.touches.length;
  };



  //
  //  Events / Other
  //
  DD.prototype.prevent_default = function(e) {
    e.preventDefault();
  };


  DD.prototype.trigger_additional_drag_events = function(e) {
    var last_toElement_is_node = (
      this.state.last_toElement &&
      this.state.last_toElement.nodeType
    );

    if (last_toElement_is_node && (this.state.last_toElement !== e.toElement)) {
      $(this.state.last_toElement).trigger("pointerdragleave");
      $(e.target).trigger("pointerdragenter");

    } else if (last_toElement_is_node && (this.state.last_toElement === e.toElement)) {
      $(this.state.last_toElement).trigger("pointerdragover");

    } else {
      $(e.target).trigger("pointerdragenter");

    }

    this.state.last_toElement = e.target;
  };


  DD.prototype.document_pointerout_handler = function(e) {
    e = e.originalEvent || e;

    if (e.relatedTarget === null || e.relatedTarget.tagName.toLowerCase() === "html") {
      if (e.pageY < 0 || e.pageY > document.body.scrollHeight) this.stop_drag();
      else if (e.pageX < 0 || e.pageX > document.body.scrollWidth) this.stop_drag();
    }
  };



  //
  //  Drag icon
  //
  DD.prototype.show_drag_icon = function(x, y) {
    var element;

    if (!this.state.drag_icon_element) {
      element = document.createElement("div");
      element.className = this.settings.drag_icon_classname;
      element.innerHTML = "";
      $(element).css("position", "absolute");
      document.body.appendChild(element);
      this.state.drag_icon_element = element;
    } else {
      element = this.state.drag_icon_element;
    }

    $(element).show(0);
    this.move_drag_icon(x, y);
  };


  DD.prototype.hide_drag_icon = function() {
    $(this.state.drag_icon_element).hide(0);
  };


  DD.prototype.move_drag_icon = function(x, y) {
    var $el = $(this.state.drag_icon_element);
    var offset = $el.offset();
    var scroll_left = document.body.scrollLeft;
    var scroll_top = document.body.scrollTop;

    $el.css({
      left: x - ($el.width() / 2),
      top: y - ($el.height() / 2)
    });
  };



  //
  //  Utilities
  //
  DD.prototype.bind_to_self = function(methods) {
    for (var i=0,j=methods.length; i<j; ++i) {
      this[methods[i]] = __bind(this[methods[i]], this);
    }
  };


  DD.prototype.collect_parent_nodes = function(element) {
    var el = element;
    var nodes = [];

    while (el) {
      nodes.unshift(el);
      el = el.parentNode;
    }

    return nodes;
  };



  //
  //  Export
  //
  window.PointerEventsDragnDrop = DD;


})(window.jQuery || window.Zepto);
