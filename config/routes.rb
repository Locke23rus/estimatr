Estimatr::Application.routes.draw do
  root :to => 'pages#welcome'

  match '/auth/twitter/callback' => 'sessions#create'
  match '/sign_out' => 'sessions#destroy'
end
