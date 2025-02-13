class Project < ApplicationRecord
  audited

  validates :name,
    presence: true,
    length: { minimum: 3, maximum: 255 }

  # We want human readable strings stored in the db, not numbers.
  # In future: use PostgreSQL enum type.
  enum :status,
    {
      "not_started": "Not Started",
      "in_progress": "In Progress",
      "maintenance": "Maintenance",
      "archived": "Archived"
    },
    validate: true

  belongs_to :user

  has_many :comments, dependent: :destroy
end
