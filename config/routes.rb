Rails.application.routes.draw do
  devise_for :users, controllers: {
    sessions: "users/sessions",
    registrations: "users/registrations"
  }

  post "stripe/webhook", to: "checkouts#webhook"

  scope ":language",
    constraints: { language: Regexp.new(User.instructional_languages.keys.join("|")) } do

    get "/", to: "home#index", as: :language_root
    resources :checkouts, only: [ :create ]
    get "checkouts/success", to: "checkouts#success", as: :checkout_success
    get "checkouts/cancel", to: "checkouts#cancel", as: :checkout_cancel

    resources :lessons, only: [:new, :create] do
      collection do
        get "calendar"
        get "slots"
      end
    end

    scope "instructors/:instructor_id" do
      get "calendar", to: "lessons#calendar", as: :instructor_calendar_lessons
      get "slots", to: "lessons#slots", as: :instructor_slots_lessons
      get "new", to: "lessons#new", as: :instructor_new_lesson
    end

    scope "students/:student_id" do
      get "lessons", to: "lessons#index", as: :student_lessons
    end
  end

  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  # Defines the root path route ("/")
  # root "posts#index"
end
