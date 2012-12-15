class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :encryptable, :confirmable, :lockable,  and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable,
         :token_authenticatable, :timeoutable

  attr_accessible :email, :password, :password_confirmation, :remember_me

  before_save :ensure_authentication_token

  has_many :executed_action,
           :class_name => "ActionEvent",
           :foreign_key => :user_id,
           :readonly => true,
           :order => "time DESC"

  # custom names, maybe later
  has_many :action_types_users
  has_many :action_types, :through => :action_types_users

  has_many :memos

  has_many :overseers

  has_many :home_archives

  has_many :user_tasks
end
