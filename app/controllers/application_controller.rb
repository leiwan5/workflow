class ApplicationController < ActionController::Base
  # protect_from_forgery

  def string_fix(s)
    #s.encode("utf-8", :undef => :replace, :replace => "?", :invalid => :replace) rescue ''
    s
  end
end
