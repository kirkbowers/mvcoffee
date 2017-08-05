class FormController < ApplicationController
  before_action :prepare_mvcoffee_object

  def index
    if @cache_age.nil? or @cache_age.empty?
      @mvcoffee[:session] =  {
        cache_age: 'very old!'
      }
      @mvcoffee[:flash][:message] = 'Doing pretend database query and sending to client'
    else
      @mvcoffee[:flash][:message] = 'Not doing pretend database query'
    end    

    respond_to do |format|
      format.html
      format.json { 
        render json: @mvcoffee
      }
    end  
  end

  def other
    # @mvcoffee[:flash][:message] = 'Arrived by get, nothing special happening here'
  end

  def post_button
    @mvcoffee[:flash][:message] = 'Post button pushed'
    respond_to do |format|
      format.html
      format.json { 
        render json: @mvcoffee
      }
    end  
  end

  def post_button_with_redirect
    @mvcoffee[:flash][:message] = 'Post button pushed and redirected'
    @mvcoffee[:redirect] = form_other_path
    respond_to do |format|
      format.html {
        redirect_to form_other_path, message: 'Post button pushed and redirected'
      }
      format.json { 
        render json: @mvcoffee
      }
    end  
  end

  def delete
    @mvcoffee[:flash][:message] = 'Delete link clicked'
    respond_to do |format|
      format.html
      format.json { 
        render json: @mvcoffee
      }
    end  
  end
  
  def post_link
    @mvcoffee[:flash][:message] = 'Post link clicked'
    respond_to do |format|
      format.html
      format.json { 
        render json: @mvcoffee
      }
    end  
  end

  def post_form
    @name = params[:name]
    @mvcoffee[:flash][:message] = "Form posted with value #{@name}"
    respond_to do |format|
      format.html
      format.json { 
        render json: @mvcoffee
      }
    end  
  end

  def get_form
    @name = params[:name]
    @mvcoffee[:flash][:message] = "Form submitted over GET with value #{@name}"
    
    @extra = params[:extra]
    if @extra
      @mvcoffee[:flash][:message] += ", plus with extra: #{@extra}"
    end
    
    respond_to do |format|
      format.html
      format.json { 
        render json: @mvcoffee
      }
    end  
  end
  
  def post_multiple_buttons
    @name = params[:name]
    if params[:alpha]
      @button = 'Alpha'
    elsif params[:beta]
      @button = 'Beta'
    end
    @mvcoffee[:flash][:message] = "Form posted with value #{@name} and button #{@button}"
    @mvcoffee[:redirect] = form_other_path
    respond_to do |format|
      format.html {
        redirect_to form_other_path, "Form posted with value #{@name} and button #{@button}"
      }
      format.json { 
        render json: @mvcoffee
      }
    end  
  end

private
  def prepare_mvcoffee_object
    session = cookies[:mvcoffee_session]
    @mvcoffee_session_from_client = {}
    if session
      @mvcoffee_session_from_client = CGI.parse(session)
    end
    puts "Client session = #{@mvcoffee_session_from_client}"
    
    @mvcoffee = {
      mvcoffee_version: '1.0.0',
      flash: {}
    }

    @cache_age = @mvcoffee_session_from_client["cache_age"]

    if @cache_age.nil? or @cache_age.empty?
      @mvcoffee[:flash][:cache_status] = "Client cache was stale."
    else
      @mvcoffee[:flash][:cache_status] = "Client cache is up to date."
    end
        
  end
end
