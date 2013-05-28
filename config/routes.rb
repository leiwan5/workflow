Workflow::Application.routes.draw do
  resources :deployments
  resources :process_definitions do
    member do
      get :properties
    end
  end
  resources :tasks
  
  root to: 'deployments#index'
end
