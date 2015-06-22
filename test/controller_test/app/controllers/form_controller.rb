class FormController < ApplicationController
  def index
  end

  def other
  end

  def post_button
    respond_to do |format|
      format.html
      format.json { 
        render json: { 
          mvcoffee_version: '1.0.0',
          flash: { message: 'Post button pushed' }
        }
      }
    end  
  end

  def post_button_with_redirect
    respond_to do |format|
      format.html {
        redirect_to form_other_path, message: 'Post button pushed and redirected'
      }
      format.json { 
        render json: { 
          mvcoffee_version: '1.0.0',
          redirect: form_other_path,
          flash: { message: 'Post button pushed and redirected' }
        }
      }
    end  
  end

  def delete
    respond_to do |format|
      format.html
      format.json { 
        render json: { 
          mvcoffee_version: '1.0.0',
          flash: { message: 'Delete link clicked' }
        }
      }
    end  
  end
  
  def post_link
    respond_to do |format|
      format.html
      format.json { 
        render json: { 
          mvcoffee_version: '1.0.0',
          flash: { message: 'Post link clicked' }
        }
      }
    end  
  end

  def post_form
    @name = params[:name]
    respond_to do |format|
      format.html
      format.json { 
        render json: { 
          mvcoffee_version: '1.0.0',
          flash: { message: "Form posted with value #{@name}" }
        }
      }
    end  
  end
end
