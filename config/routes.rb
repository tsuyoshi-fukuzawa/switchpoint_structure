Rails.application.routes.draw do
  root to: "home#index"

  resources :animals, only: [] do
    collection do
      get  :index
    end
  end

  resources :dogs, only: [] do
    collection do
      get  :index
    end
  end

  resources :cats, only: [] do
    collection do
      get  :index
    end
  end

  resources :dog_parents do
  end

  resources :dog_children, only: [] do
    member do
      get   :children
      get   :child_new
      post  :child_create
      get   :child_show
      get   :child_edit
      patch :child_update
    end
  end

  resources :cat_parents do
  end

  resources :cat_children, only: [] do
    member do
      get   :children
      get   :child_new
      post  :child_create
      get   :child_show
      get   :child_edit
      patch :child_update
    end
  end

end
