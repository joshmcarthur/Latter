
class PagesController < ApplicationController

  rescue_from ActionView::MissingTemplate, :with => proc { |exp| render :text => "Page not found", :status => :not_found }

  # GET /pages/1
  def show
    render :template => "pages/#{params[:slug]}"
  end
end
