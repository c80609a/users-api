class ApplicationController < ActionController::API
  include Response
  include ExceptionHandler

  before_action :dfa

  private

  def dfa
    unless request.xhr?
      head :no_content
    end
  end

  end
