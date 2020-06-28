Rails.application.routes.draw do
  resources :stocks
  
  get 'quote', to: 'stocks#quote', as: 'quote'
  
  
  root 'stocks#index'
  
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
