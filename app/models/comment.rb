class Comment < ApplicationRecord
  belongs_to :user
  belongs_to :project
  has_rich_text :content
end
