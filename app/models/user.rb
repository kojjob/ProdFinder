# frozen_string_literal: true

class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :registerable, :confirmable,
         :rememberable, :validatable
  has_many :product_makers
  has_many :products, through: :product_makers
end
