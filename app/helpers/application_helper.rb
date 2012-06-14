module ApplicationHelper
  
  def custom_background?
    "background-image: url('#{@settings[:custom_background]}')" if @settings and @settings[:custom_background]
  end
  
  def pages
    [
      { title: "Settings", url: "/settings", icon: "&#x0042;" },
      { title: "Source Manager", url: "/source-manager", icon: "&#x0053;" }
    ]
  end
end
