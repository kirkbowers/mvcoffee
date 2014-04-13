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
          redirect: form_other_path,
          flash: { message: 'Post button pushed' }
        }
      }
    end  
  end

  def post_form
    name = params[:name]
    respond_to do |format|
      format.html
      format.json { 
        render json: { 
          redirect: form_other_path,
          flash: { message: "Form posted with value #{name}" }
        }
      }
    end  
  end

  def delete
    respond_to do |format|
      format.html
      format.json { 
        render json: { 
          redirect: form_other_path,
          flash: { message: 'Delete link clicked' }
        }
      }
    end  
  end
end
