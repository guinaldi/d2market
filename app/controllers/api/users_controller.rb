require "securerandom"

class Api::UsersController < ApplicationController
  skip_before_action :authenticate_request!, only: [:create, :reset_password, :update_password]

  # POST /register
  def create
    @user = User.new(user_params)
    if @user.save
      message = "User created successfully"
      response = { message: message, validation_code: @user.validation_code }
      render json: response, status: :created
    else
      render json: @user.errors, status: :unprocessable_entity
    end
  end

  def reset_password
    @user = User.find_by_email_and_username!(params[:user][:email], params[:user][:username])

    if @user.request_password_reset
      message = 'Password reset successfully requested'
      render json: { message: message }, status: :ok
    else
      raise ServerError, 'Something went wrong. Please try again later.'
    end
  end

  def update_password
    @user = User.find_by_email_and_reset_password_token!(params[:user][:email], params[:user][:reset_password_token])

    if Time.current > @user.reset_password_within
      raise ExpiredSignature, 'Token expired'
    end

    if @user.update(user_params)
      response = { message: "Password successfully updated" }
      render json: response, status: :ok
    else
      raise ServerError, 'Something went wrong. Please try again later.'
    end
  end

  private

  def user_params
    params.require(:user).permit(:email, :username, :password, :password_confirmation)
  end
end
