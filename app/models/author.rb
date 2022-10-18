class Author < ApplicationRecord
  has_many :book_authors, foreign_key: "author_id", dependent: :destroy
  has_many :books, through: :book_authors
  has_one_attached :avatar

  validates :description, :avatar, presence: true
  validates :first_name, :last_name, presence: true, length: { maximum: 100 }
end