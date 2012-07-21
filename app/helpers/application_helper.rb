module ApplicationHelper
  def pages
    if logged_in?
      [
        { title: "Application", url: "/", icon: "&#xe03a;" },
        { title: "About", url: "/about", icon: "&#x0060;" },
        { title: "Settings", url: "/settings", icon: "&#x0042;" },
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
