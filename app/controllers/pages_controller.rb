class PagesController < ApplicationController
  before_filter :set_page
  
  # GET 'settings'
  def settings
  end
  
  # GET 'source-manager'
  def source_manager
  end

private

  def pages
    [
      { title: "Source Manager", subtitle: "Connections", url: "/source-manager", icon: "&#x0053;" },
      { title: "Settings", subtitle: "Application", url: "/settings", icon: "&#x0042;" },
      { title: "Account", subtitle: "Preferences", url: "/account", icon: "&#x002b;" }
    ]
  end

  def set_page
    @page = (@pages ||= pages).find { |p| p[:url] == request.path }
  end
end
