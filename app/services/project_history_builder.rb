module ProjectHistoryBuilder
  extend self

  def for(project)
    # The project conversation history is a reverse chronologically ordered list consisting of:
    # - comments made on the project
    # - changes to the project status

    # Implementation note: this is a naive implementation that will not scale well. See notes in the README for details and future considerations. We use hard limits as a temporary measure.

    comments = project
      .comments
      .includes(:user)
      .limit(100)

    project_changes = project
      .audits
      .updates
      .limit(100)

    # Only use the changes made to project status
    project_status_changes = project_changes.select do |change|
      change.audited_changes.keys.include?("status")
    end

    comment_entries = comments.map(&method(:convert_comment_to_entry))
    project_status_change_entries = project_status_changes.map(&method(:convert_project_status_change_to_entry))

    history = (comment_entries + project_status_change_entries).sort_by(&:timestamp).reverse

    history
  end

  def convert_comment_to_entry(comment)
    entry = ProjectHistory::CommentEntry.new(
      timestamp: comment.created_at,
      user: comment.user,
      comment: comment
    )

    # For now, let's fail fast.
    # Better error handling would be needed in the real thing.
    entry.validate!

    entry
  end

  def convert_project_status_change_to_entry(audit)
    entry = ProjectHistory::StatusChangeEntry.new(
      timestamp: audit.created_at,
      user: audit.user,
      before: audit.audited_changes["status"][0],
      after: audit.audited_changes["status"][1]
    )

    # For now, let's fail fast.
    # Better error handling would be needed in the real thing.
    entry.validate!

    entry
  end
end
