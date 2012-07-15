class DefaultController < ApplicationController
  before_filter :require_login
end