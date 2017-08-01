module ExceptionHandler
  extend ActiveSupport::Concern

  included do

    # define custom handlers
    rescue_from ActiveRecord::RecordInvalid, with: :four_twenty_two
    rescue_from ActiveRecord::RecordNotFound do |e|
      json_response({message: e.message}, :not_found)
    end

  end

  private

  # JSON ответ со статус-кодом 422 - unprocessable_entity
  def four_twenty_two(e)
    json_response({message: e.message}, :unprocessable_entity)
  end

end