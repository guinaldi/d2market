require 'securerandom'

class User < ApplicationRecord
  include EmailValidatable

  has_secure_password

  validates :email, presence: true,
                    uniqueness: { case_sensitive: false },
                    email: true
  validates :username, presence: true,
                       uniqueness: { case_sensitive: false },
                       length: { in: 1..25 }
  validates :password_confirmation, presence: true,
                                    if: Proc.new { |u| u.new_record? }

  before_create :generate_validation_code

  enum status: {
    created: 0,
    validated: 1,
    blocked: 2
  }

  enum role: {
    admin: 0,
    manager: 1,
    user: 2
  }

  def request_password_reset
    update(reset_password_token: SecureRandom.urlsafe_base64(6))
    update(reset_password_within: Time.current + 48.hours)
  end

  private

  def generate_validation_code
    begin
      self.validation_code = SecureRandom.urlsafe_base64(8)
    end while User.exists?(validation_code: validation_code)
  end
end
