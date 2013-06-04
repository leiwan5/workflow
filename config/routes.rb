Workflow::Application.routes.draw do
  resources :deployments
  resources :process_definitions do
    member do
      get :properties
      get :diagram
    end
  end
  resources :tasks
end
