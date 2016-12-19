Rails.application.routes.draw do
  root 'home#index'
  get 'new' => 'home#new', as: :start_new_application
  get 'reset' => 'home#reset', as: :reset
  get 'sign_out' => 'home#sign_out', as: :sign_out
 
  # this is handled by rack case, but this just allows us to have a URL helper
  get 'logout' => 'home#sign_out', as: :logout

  resources :users

  resources :prospects
  get 'prospects/:id/resume' => 'prospects#resume', as: :prospect_resume
  get 'prospects/:id/thank_you' => 'prospects#thank_you', as: :thank_you
  
  resources :resumes

  get 'configuration' => 'configuration#show', as: :configuration
  post 'configuration' => 'configuration#update', as: :update_configuration

end
