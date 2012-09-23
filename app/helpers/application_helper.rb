module ApplicationHelper

  def body_class
    @page[:title].parameterize
  end

end
