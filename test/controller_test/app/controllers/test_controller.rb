class TestController < ApplicationController
  layout 'test'

  def index
    render layout: 'application'
  end

  def default_timer
  end

  def override_timer
  end

  def no_timer
  end

  def no_refresh
  end
  
  def plurals
    render layout: 'application'
  end
end
