class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable, :confirmable

  has_many :accounts

  has_many :items, through: :accounts

  def available_size
    accounts.sum(:available_size)
  end

  def total_size
    accounts.sum(:total_size)
  end
end
