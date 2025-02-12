Rails.application.routes.draw do
  resource :session
  resources :passwords, param: :token

  resources :projects do
    resources :comments, only: %i[new create destroy]
  end

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  root to: redirect("/projects")
end
