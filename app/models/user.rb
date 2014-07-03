class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable, :confirmable

  has_many :accounts

  has_many :items, through: :accounts

  def account_for(file) 
    Rails.logger.debug file.size
    accounts.where("available_size >= ?", file.size).sample
  end
end
