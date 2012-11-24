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
        { title: "Application", url: "/" },
        { title: "Settings", url: "/settings" },
        { title: "Tools", url: "/tools" },
        { title: "Account", url: "/account"},
        { title: "Sign out", url: "/sign-out" }
      ]
    else
      [
        { title: "About", url: "/about" },
        { title: "Tools", url: "/tools" },
        { title: "FAQ", url:"/faq" },
        { title: "Sign in", url: "/sign-in" },
        { title: "Sign up", url: "/sign-up" }
      ]
    end
  end

end
