# My solution for the Homey technical test (Feb 2025)

## Running this locally

1. Clone the repo
1. Run `bundle install`
1. Run `rails db:migrate`
1. Run `bin/dev`
1. Visit `http://localhost:3000`

## Original task description

```markdown
# Task

Use Ruby on Rails to build a project conversation history. A user should be able to:

- leave a comment
- change the status of the project

The project conversation history should list comments and changes in status.

Please don’t spend any more than 3 hours on this task.

# Brief

Treat this as if this was the only information given to you by a team member, and take the approach you would normally take in order to build the right product for the company.

To this extent:

- Please write down the questions you would have asked your colleagues
- Include answers that you might expect from them
- Then build a project conversation based on the answers to the questions you raised.
```

## Product decisions

With the information provided, I would have asked the following granular questions, and have made the following assumptions/decisions:

> [!NOTE]
>
> Usually, I would only ask these granular questions after a high-level business, strategy and product discussion, establishing _what_ and _why_ we're building. But for the sake of this exercise, I'm assuming that the high-level discussions have already taken place.

1. Q: Do we need to support multiple projects?
   - A: Yes
1. Q: Do we need to support multiple users?
   - A: Yes
1. Q: Can anyone create a new project?
   - A: Yes
1. Q: Can anyone see and modify a project? (Including commenting)
   - A: Yes, just for this exercise. In the future projects will be locked down (thus the following clarifying questions).
1. Q: Can multiple users be assigned to see or modify a project?
   - A: Not yet, but one for the future.
1. Q: Do we need to support team structures?
   - A: Not yet, but one for the future.
1. Q: Do we need to support different roles?
   - A: Not yet, but one for the future.
1. Q: Does the list of statuses for a project need to be configurable?
   - A: Not yet, but one for the future.
   - Assumption: the list of project statuses (and ordering) is fixed for nod and does not need to be changed at runtime.
1. Q: Do we need to support rich text in comments?
   - A: Yes, with some basic rich text formatting — nothing fancy for now.
1. Q: Do we need to support attachments in comments?
   - A: No, and don't assume we ever will.
1. Q: Beyond listing comments and changes in status, should the project conversation history display when comments were updated or deleted?
   - A: No, and don't assume we ever will.
1. Q: Should the project conversation history display the initial project status (on project creation)?
   - A: No, and don't assume we ever will.
1. Q: Should users be able to edit comments?
   - A: Not yet, but one for the future.
1. Q: Should users be able to delete comments?
   - A: Not yet, but one for the future.

## Tech stack decisions

- Using the latest Rails v8 (v8.0.1 at the time) with defaults
  - Generated with: `rails new homey-test --css=tailwind`
- Using the latest Ruby v3 (v3.3.6 at the time)
- Using SQLite for the database (for convenience)
  - For the real thing I would most likely use PostgreSQL
- Using Tailwind CSS for styling
- Using the authentication system provided by Rails v8
  - Generated with: `bin/rails generate authentication`
- Using [Action Text](https://guides.rubyonrails.org/action_text_overview.html) for rich text support, but without attachments (for now).
- Hosting the solution, temporarily, on a DigitalOcean droplet, using Kamal to deploy.

## Implementation details

- A very simple authentication system is in place, using the Rails v8 authentication system.
- I've gone for a very CRUD-focused UI based on the default scaffold generation provided by Rails. This is not the most ideal UI, and for the real thing I would look to make most of the interactions occur on the project page itself (e.g. changing the project status, adding comments, etc.), using Hotwire and Stimulus to make the interactions more dynamic.
- For now, the possible project statuses are hard coded in the `Project` model (and I've come up with some arbitrary statuses for this exercise).
  - See note below on how I would improve this.
- I've chosen to use the [`audited` gem](https://github.com/collectiveidea/audited) to store an audit trail of changes to projects, to then use as a source for building up a project conversation history.
  - Note: I _haven't_ used this to track changes to comments as the current assumption is changes to a comment aren't needed — just the presence of the comment itself is needed for the conversation history.
- Comments are a nested resource of Projects.
- I've used Action Text for the rich text comments, but without attachments.
- I've abstracted out the conversation history building into a service (`ProjectHistoryBuilder`), which is used in the `ProjectsController` to build up the conversation history for a project. This uses different model classes to represent the two kinds of history entries, with dedicated UI partials to render them.

## Future considerations and improvements

- Important: since this is a coding exercise that (should) only require a few hours of work, I've left in a lot of the cruft generated by the initial Rails app generator + Rails scaffold generators (e.g. unneeded comments in files, unused views, JSON builders, etc.). I also haven't removed the broken tests (which means a broken CI at the moment). In a real-world scenario, I would clean this up as I go and wouldn't even commit them in a pull request (i.e. I would have a much cleaner implementation).
- Speaking of tests, I have chosen to ignore tests for now, but in a real-world project I would figure out a test strategy that works best given the product, business, tech and time constraints.
- I would have a better commit history, with incremental features split up in to separate pull requests, and with more descriptive commit messages. I would likely use feature flags to hide features that were in progress and/or not yet ready for a broader audience.
- I would lock down _intended_ versions of all gems in the `Gemfile`.
- As mentioned, the UI and UX experience isn't the best, and for the real thing I would look to make most of the interactions occur on the project page itself (e.g. changing the project status, adding comments, etc.), using Hotwire and Stimulus to make the interactions more dynamic.
- Depending on the auth requirements and flows needed, I would consider a more robust authentication system (e.g. hooking it up to an external Identity Provider, or integrating with a managed authentication service, or using something more advanced like Devise).
- I would consider supporting a friendly ID / slug capability for projects (e.g. `marketing-dev` instead of `1`) for better URLs, and better cross-linking to projects.
- I would use a more robust database like PostgreSQL for the real thing, on the assumption that SQLite would not be enough for this product.
- For project statuses, if they are intended to be fixed (or very rarely changed), and thus not needing to be updated at runtime, then I would use PostgreSQL enums, instead of storing them as strings.
  - However, if any more dynamism is needed then I would create a `ProjectStatus` model and store the statuses in the database.
- The current implementation of the _fetching_ and _building_ of the project conversation history is basic and likely inefficient. For a real product, I would consider:
  - How to denormalise/cache descriptors like names of things (e.g. project and user names) so building up an activity feed is more efficient.
  - Resiliency and performance of the audit log system — making sure it doesn't bring everything down if it fails. And how to recover from such failures, depending on how mission critical the audit logs are (e.g. for compliance reasons).
  - I would use background processing to do the actual persisting of audit logs.
  - Paginating the conversation history.
  - Solving the n+1 problem, either by retrieving dependent records in bulk, or by caching descriptors of the dependent objects, or by caching the conversation history as a whole, to reduce load on the database (depending on what real-world needs and benchmarks show).
- I would use a proper roles / policy system for managing access to projects, and for managing what users can do with projects.
- I would consider using UUIDs for the primary keys of all models, instead of integers, for better security and privacy. Though this would need a little bit of cost/benefit analysis to make sure the added performance hit wouldn't be a problem in the long run (and will depend on real-world needs).
