class ProjectHistory::CommentEntry < ProjectHistory::Base
  attr_accessor :comment

  validates :comment, presence: true
end
