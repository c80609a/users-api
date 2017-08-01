class UserAdsController < ApplicationController

  before_action :set_user, only: [:show, :update, :destroy]

  # GET /todos/:todo_id/items/:id
  def show
    json_response(@user)
  end

  # def new
  #
  # end

  # POST /todos/:todo_id/items
  def create
    @user = UserAd.create!(user_params)
    json_response(@user, :created)
  end

  # PUT /todos/:todo_id/items/:id
  def update
    @user.update(user_params)
    head :no_content
  end

  def destroy
    @user.destroy
    head :no_content
  end

  private

  def user_params
    params.permit(:title, :phone, :email, :org, :pos)
  end

  def set_user
    @user = UserAd.find_by!(id: params[:id])
  end

end