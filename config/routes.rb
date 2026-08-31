Rails.application.routes.draw do
  match "mcp", to: "mcp#handle", via: %i[ get post delete ]
  post "telegram/webhook", to: "telegram_webhooks#create"

  resources :dosis
  resources :ordenes_fumigacion do
    collection do
      get :pendiente_factura
    end
    member do
      patch :terminar
      get :pdf
    end
  end
  resources :productos
  resources :lotes do
    member do
      get :adjuntos
    end
    resources :adjuntos, only: %i[ create destroy ]
  end
  resources :adjuntos, only: %i[ index ]
  resources :estancias
  resources :cultivos
  resources :maquinistas
  resources :facturas, only: %i[ create update ]
  resources :facturas_pago, only: %i[ index ]
  resources :estadisticas, only: %i[ index ]
  get :informe_orden, to: "informes_orden#show"
  post "refresh", to: "users/refresh_tokens#create"
  devise_for :users,
             path: "",
             path_names: {
               sign_in: "login",
               sign_out: "logout"
             },
             controllers: {
               sessions: "users/sessions"
             }
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Defines the root path route ("/")
  # root "posts#index"
end
