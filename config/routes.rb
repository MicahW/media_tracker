Rails.application.routes.draw do

  get '/category/index', to: 'category#index', as: 'categories'

  get '/category/show/:id', to: 'category#show', as: 'category'
  post '/category/add_child/:id', to: 'category#add_child', as: 'category_add_child'
  post '/category/add_existing_child/:id', to: 'category#add_existing_child', as: 'category_add_existing_child'
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  
 
  root 'user#home'
  post '/dagr/update/:guid', to: 'dagr#update', as: 'dagr_update'
  delete '/category/:id', to: 'category#destroy', as: 'destroy_category'
  get '/signup', to: 'user#new', as: 'signup'
  post '/signup', to: 'user#create'
  get '/login', to: 'sessions#new'
  post '/login', to: 'sessions#create'
  get '/add_dagr', to: 'dagr#new', as: 'add_dagr'
  post '/add_dagr_file', to: 'dagr#create_file', as: 'create_dagr_file'
  post '/add_dagr_url', to: 'dagr#create_url', as: 'create_dagr_url'
  get '/all_dagrs', to: 'dagr#index', as: 'all_dagrs'
  get '/dagr/:guid', to: 'dagr#show', as: 'dagr'
  post '/add_category', to: 'category#create', as: 'add_category'
  post '/dagr/alter', to: 'dagr#alter', as: 'alter_dagr'  
  get '/query', to: 'query#new', as: 'query_page'
  post '/query', to: 'query#generate', as: 'generate'
  post '/logout', to: 'sessions#destroy', as: 'logout'
end
