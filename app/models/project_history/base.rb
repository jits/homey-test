class ProjectHistory::Base
  include ActiveModel::Model

  attr_accessor :timestamp, :user

  validates :timestamp, presence: true
end
