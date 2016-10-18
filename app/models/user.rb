class User < ApplicationRecord

  attr_accessor :password
  before_save :encrypt_password
  before_create { generate_token(:auth_token) }
  attr_accessor :update_mode

  validates_confirmation_of :password
  validates_presence_of :password, length: {minimum: 8, maximum: 255}, on: :update unless update_mode = 'skip_password_validation'
  validates_presence_of :password, length: {minimum: 8, maximum: 255}, on: :create
  validates_presence_of :email, format: { with: /\A.+@[^.].*[a-zA-Z]\z/, message: ' invalid format' }
  validates_uniqueness_of :email

  def self.authenticate(email, password)
    user = find_by_email(email)
    if user && user.password_hash == BCrypt::Engine.hash_secret(password, user.password_salt)
      user
    else
      nil
    end
  end

  def encrypt_password
    if password.present?
      self.password_salt = BCrypt::Engine.generate_salt
      self.password_hash = BCrypt::Engine.hash_secret(password, password_salt)
    end
  end

  def send_password_reset
    update_mode = 'skip_password_validation'
    generate_token(:password_reset_token)
    self.password_reset_sent_at = Time.zone.now
    save!
    UserMailer.password_reset(self).deliver
  end

  def generate_token(column)
    begin
      self[column] = SecureRandom.urlsafe_base64
    end while User.exists?(column => self[column])
  end
end
