class ProjectHistory::StatusChangeEntry < ProjectHistory::Base
  attr_accessor :before, :after

  validates :before, presence: true
  validates :after, presence: true
end
