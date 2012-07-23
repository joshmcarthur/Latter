
class PagesController < ApplicationController

  rescue_from ActionView::MissingTemplate, :with => proc do |exp| 
  	render :text => I18n.t('page.not_found'), :status => :not_found 
  end

  # GET /pages/1
  def show
    render :template => "pages/#{params[:slug]}"
  end
end
