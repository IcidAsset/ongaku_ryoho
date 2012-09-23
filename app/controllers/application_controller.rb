class ApplicationController < ActionController::Base
  protect_from_forgery
  before_filter :set_pages

  def not_authenticated
    redirect_to sign_in_url, :alert => "First login to access this page."
  end

private

  def set_pages
    @pages = pages
    @page = @pages.find { |p| p[:url] == request.path }
  end

  def pages
    if logged_in?
      [
        { title: "Application", url: "/", icon: "&#xe03a;" },
        { title: "Settings", url: "/settings", icon: "&#x0042;" },
        { title: "Tools", url: "/tools", icon: "&#x0043;" },
        { title: "Account", url: "/account", icon: "&#x002b;" },
        { title: "Sign out", url: "/sign-out", icon: "&#x0024;" }
      ]
    else
      [
        { title: "About", url: "/about", icon: "&#x0060;" },
        { title: "Sign in", url: "/sign-in", icon: "&#x002b;" },
        { title: "Sign up", url: "/sign-up", icon: "&#x002d;" }
      ]
    end
  end

end
