Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  
  root 'user#home'
  get '/signup', to: 'user#new', as: 'signup'
  post '/signup', to: 'user#create'
  get '/login', to: 'sessions#new'
  post '/login', to: 'sessions#create'
  get '/add_dagr', to: 'dagr#new', as: 'add_dagr'
  post '/add_dagr_file', to: 'dagr#create_file', as: 'create_dagr_file'
  post '/add_dagr_url', to: 'dagr#create_url', as: 'create_dagr_url'
  
end
