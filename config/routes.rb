Workflow::Application.routes.draw do
  resources :deployments
  resources :process_definitions do
    resources :instances, :controller => :process_instances
    member do
      get :properties
      get :diagram
      get :bpmn_model
    end
  end
  resources :process_instances do
    resources :tasks
    resources :variables
    member do
      get :diagram
    end
  end
  resources :tasks do
    member do
      post :claim
      post :unclaim
      post :complete
      get :form_properties
    end
  end
end
