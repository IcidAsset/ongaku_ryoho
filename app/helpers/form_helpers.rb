module FormHelpers

  def settings_checkbox(s, obj, field)
    s.check_box field, { checked: obj.settings[field.to_s] === "1" }
  end

end
