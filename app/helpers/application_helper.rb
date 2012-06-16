module ApplicationHelper
  
  def custom_background?
    "background-image: url('#{@settings[:custom_background]}')" if @settings and @settings[:custom_background]
  end
end
