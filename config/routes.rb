Rails.application.routes.draw do
  resources :grats
  get 'status', to: 'grats#status', as: 'status'
  
  resources :stocks
  
  get 'quote', to: 'stocks#quote', as: 'quote'
  get 'grats_s', to: 'stocks#grats', as: 'grats_s'
  
  
  root 'stocks#index'
  
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
