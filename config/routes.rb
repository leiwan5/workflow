Workflow::Application.routes.draw do
  resources :deployments
  resources :process_definitions do
    resources :instances, :controller => :process_instances
    member do
      get :properties
      get :diagram
    end
  end
  resources :process_instances do
    resources :tasks
    member do
      get :diagram
    end
  end
  resources :tasks do
    member do
      post :claim
      post :unclaim
      post :complete
      get :properties
    end
  end
end
