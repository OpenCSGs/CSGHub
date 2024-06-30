Rails.application.routes.draw do
  # admin
  namespace :admin do
    resources :system_configs
    resources :users do
      get :export, on: :collection
    end
    resources :comments
    resources :discussions
    resources :system_api_keys
    resources :tags
    resources :organizations
    resources :error_logs
    resources :models, except: [:new, :create] do
      collection do
        get '/:model_id/sync', to: 'models#sync'
      end
    end
    resources :datasets, except: [:new, :create] do
      collection do
        get '/:dataset_id/sync', to: 'datasets#sync'
      end
    end
    resources :codes, except: [:new, :create] do
      collection do
        get '/:code_id/sync', to: 'codes#sync'
      end
    end
    resources :mirrors

    root to: "users#index"
  end

  # internal api
  namespace :internal_api do
    namespace :admin do
      resources :users, only: [:index, :show]
    end

    resources :organizations, only: [:create, :update] do
      collection do
        post '/new-members', to: 'organizations#new_members'
      end
      member do
        get '/members', to: 'organizations#members'
        delete '/members/:user_id', to: 'organizations#remove_member', user_id: /[^\/]+/
        put '/members/:user_id', to: 'organizations#update_member', user_id: /[^\/]+/
      end
    end
    resources :comments, only: [:create, :destroy, :index]
    resources :users, only: [:index, :update] do
      collection do
        put 'jwt_token', to: 'users/jwt_token'
      end
    end
    get '/organizations/:namespace/models', to: 'organizations#models', namespace: /[^\/]+/
    get '/organizations/:namespace/datasets', to: 'organizations#datasets', namespace: /[^\/]+/
    get '/organizations/:namespace/codes', to: 'organizations#codes', namespace: /[^\/]+/
    get '/organizations/:namespace/spaces', to: 'organizations#spaces', namespace: /[^\/]+/

    resources :models, only: [:index, :create]
    get '/models/:namespace/(*model_name)/readme', to: 'models#readme', namespace: /[^\/]+/
    get '/models/:namespace/(*model_name)/files', to: 'models#files', namespace: /[^\/]+/
    post '/models/:namespace/(*model_name)/files/:branch/upload_file', to: 'models#upload_file', namespace: /[^\/]+/
    delete '/models/:namespace/(*model_name)', to: 'models#destroy', format: false, defaults: {format: 'html'}, namespace: /[^\/]+/
    put '/models/:namespace/(*model_name)', to: 'models#update', format: false, defaults: {format: 'html'}, namespace: /[^\/]+/
    post '/models/:namespace/(*model_name)/predict', to: 'models#predict', namespace: /[^\/]+/
    get '/models/:namespace/(*model_name)/related_repos', to: 'models#related_repos', namespace: /[^\/]+/

    resources :datasets, only: [:index, :create]
    get '/datasets/:namespace/(*dataset_name)/readme', to: 'datasets#readme', namespace: /[^\/]+/
    get '/datasets/:namespace/(*dataset_name)/files', to: 'datasets#files', namespace: /[^\/]+/
    get '/datasets/:namespace/(*dataset_name)/preview', to: 'datasets#preview_parquet', namespace: /[^\/]+/
    post '/datasets/:namespace/(*dataset_name)/files/:branch/upload_file', to: 'datasets#upload_file', namespace: /[^\/]+/
    delete '/datasets/:namespace/(*dataset_name)', to: 'datasets#destroy', format: false, defaults: {format: 'html'}, namespace: /[^\/]+/
    put '/datasets/:namespace/(*dataset_name)', to: 'datasets#update', format: false, defaults: {format: 'html'}, namespace: /[^\/]+/
    get '/datasets/:namespace/(*dataset_name)/related_repos', to: 'datasets#related_repos', namespace: /[^\/]+/

    resources :codes, only: [:index, :create]
    get '/codes/:namespace/(*code_name)/readme', to: 'codes#readme', namespace: /[^\/]+/
    get '/codes/:namespace/(*code_name)/files', to: 'codes#files', namespace: /[^\/]+/
    post '/codes/:namespace/(*code_name)/files/:branch/upload_file', to: 'codes#upload_file', namespace: /[^\/]+/
    delete '/codes/:namespace/(*code_name)', to: 'codes#destroy', format: false, defaults: {format: 'html'}, namespace: /[^\/]+/
    put '/codes/:namespace/(*code_name)', to: 'codes#update', format: false, defaults: {format: 'html'}, namespace: /[^\/]+/
    get '/codes/:namespace/(*code_name)/related_repos', to: 'codes#related_repos', namespace: /[^\/]+/

    resources :spaces, controller: 'application_spaces', only: [:index, :create]
    get '/spaces/:namespace/(*application_space_name)/readme', to: 'application_spaces#readme', namespace: /[^\/]+/
    get '/spaces/:namespace/(*application_space_name)/files', to: 'application_spaces#files', namespace: /[^\/]+/
    post '/spaces/:namespace/(*application_space_name)/files/:branch/upload_file', to: 'application_spaces#upload_file', namespace: /[^\/]+/
    delete '/spaces/:namespace/(*application_space_name)', to: 'application_spaces#destroy', format: false, defaults: {format: 'html'}, namespace: /[^\/]+/
    put '/spaces/:namespace/(*application_space_name)', to: 'application_spaces#update', format: false, defaults: {format: 'html'}, namespace: /[^\/]+/

    resources :endpoints, only: [:create]
    put '/endpoints/:namespace/(*endpoint_name)/:endpoint_id', to: 'endpoints#update', format: false, defaults: {format: 'html'}, namespace: /[^\/]+/
    delete '/endpoints/:namespace/(*endpoint_name)/:endpoint_id', to: 'endpoints#destroy', format: false, defaults: {format: 'html'}, namespace: /[^\/]+/

    resources :tags, only: [] do
      collection do
        get 'task-tags', to: 'tags#task_tags'
        get 'framework-tags', to: 'tags#framework_tags'
        get 'language-tags', to: 'tags#language_tags'
      end
    end
    # resources :discussions, only: :create
    resources :discussions, only: [:create, :index, :update]
    resources :upload, only: [:create]
  end

  # application
  scope "(:locale)", :locale => /en|zh/ do
    root "models#index"

    # New Admin Pannel routes
    get '/new_admin/(*path)', to: 'new_admin#index'

    resources :settings, only: [] do
      collection do
        get 'profile'
        get 'access-token'
        get 'starship-access-token'
        get 'ssh-keys'
        get 'locale'
      end
    end

    resources :models, only: [:index, :new]
    resources :datasets, only: [:index, :new]
    resources :codes, only: [:index, :new]
    resources :spaces, controller: 'application_spaces', only: [:index, :new]
    resources :endpoints, only: [:index, :new]
    resources :finetune, only: [:index, :new]
    resources :organizations, only: [:new, :show, :edit] do
      member do
        get 'members'
      end
    end
    get '/models/:namespace/(*model_name)/:branch/new', to: 'models#new_file', namespace: /[^\/]+/
    get '/models/:namespace/(*model_name)/edit/:branch/(*path)', to: 'models#edit_file', format: false, defaults: {format: 'html'}, namespace: /[^\/]+/
    get '/models/:namespace/(*model_name)/:branch/upload', to: 'models#upload_file', namespace: /[^\/]+/
    get '/models/:namespace/(*model_name)/blob/:branch/(*path)', to: 'models#blob', format: false, defaults: {format: 'html'}, namespace: /[^\/]+/
    get '/models/:namespace/(*model_name)/files/:branch(/*path)', to: 'models#files', defaults: { path: nil }, namespace: /[^\/]+/
    get '/models/:namespace/(*model_name)/resolve/:branch/(*path)', to: 'models#resolve', defaults: {format: 'txt'}, namespace: /[^\/]+/
    get '/models/:namespace/(*model_name)/community', to: 'models#community', namespace: /[^\/]+/
    get '/models/:namespace/(*model_name)/settings', to: 'models#settings', namespace: /[^\/]+/
    get '/models/:namespace/(*model_name)/commits', to: 'models#commits', namespace: /[^\/]+/
    get '/models/:namespace/(*model_name)/commit/:commit_id', to: 'models#commit', namespace: /[^\/]+/
    get '/models/:namespace/(*model_name)', to: 'models#show', format: false, defaults: {format: 'html'}, namespace: /[^\/]+/

    get '/endpoints/:namespace/(*endpoint_name)/:endpoint_id/logs', to: 'endpoints#logs', namespace: /[^\/]+/
    get '/endpoints/:namespace/(*endpoint_name)/:endpoint_id/settings', to: 'endpoints#settings', namespace: /[^\/]+/
    get '/endpoints/:namespace/(*endpoint_name)/:endpoint_id', to: 'endpoints#show', namespace: /[^\/]+/

    get '/finetune/:namespace/:name/(*finetune_name)/:finetune_id', to: 'finetune#show', namespace: /[^\/]+/

    get '/datasets/:namespace/(*dataset_name)/:branch/new', to: 'datasets#new_file', namespace: /[^\/]+/
    get '/datasets/:namespace/(*dataset_name)/edit/:branch/(*path)', to: 'datasets#edit_file', format: false, defaults: {format: 'html'}, namespace: /[^\/]+/
    get '/datasets/:namespace/(*dataset_name)/:branch/upload', to: 'datasets#upload_file', namespace: /[^\/]+/
    get '/datasets/:namespace/(*dataset_name)/blob/:branch/(*path)', to: 'datasets#blob', format: false, defaults: {format: 'html'}, namespace: /[^\/]+/
    get '/datasets/:namespace/(*dataset_name)/files/:branch(/*path)', to: 'datasets#files', defaults: { path: nil }, namespace: /[^\/]+/
    get '/datasets/:namespace/(*dataset_name)/resolve/:branch/(*path)', to: 'datasets#resolve', defaults: {format: 'txt'}, namespace: /[^\/]+/
    get '/datasets/:namespace/(*dataset_name)/community', to: 'datasets#community', namespace: /[^\/]+/
    get '/datasets/:namespace/(*dataset_name)/settings', to: 'datasets#settings', namespace: /[^\/]+/
    get '/datasets/:namespace/(*dataset_name)/commits', to: 'datasets#commits', namespace: /[^\/]+/
    get '/datasets/:namespace/(*dataset_name)/commit/:commit_id', to: 'datasets#commit', namespace: /[^\/]+/
    get '/datasets/:namespace/(*dataset_name)', to: 'datasets#show', format: false, defaults: {format: 'html'}, namespace: /[^\/]+/

    get '/codes/:namespace/(*code_name)/:branch/new', to: 'codes#new_file', namespace: /[^\/]+/
    get '/codes/:namespace/(*code_name)/edit/:branch/(*path)', to: 'codes#edit_file', format: false, defaults: {format: 'html'}, namespace: /[^\/]+/
    get '/codes/:namespace/(*code_name)/:branch/upload', to: 'codes#upload_file', namespace: /[^\/]+/
    get '/codes/:namespace/(*code_name)/blob/:branch/(*path)', to: 'codes#blob', format: false, defaults: {format: 'html'}, namespace: /[^\/]+/
    get '/codes/:namespace/(*code_name)/files/:branch(/*path)', to: 'codes#files', defaults: { path: nil }, namespace: /[^\/]+/
    get '/codes/:namespace/(*code_name)/resolve/:branch/(*path)', to: 'codes#resolve', defaults: {format: 'txt'}, namespace: /[^\/]+/
    get '/codes/:namespace/(*code_name)/community', to: 'codes#community', namespace: /[^\/]+/
    get '/codes/:namespace/(*code_name)/settings', to: 'codes#settings', namespace: /[^\/]+/
    get '/codes/:namespace/(*code_name)/commits', to: 'codes#commits', namespace: /[^\/]+/
    get '/codes/:namespace/(*code_name)/commit/:commit_id', to: 'codes#commit', namespace: /[^\/]+/
    get '/codes/:namespace/(*code_name)', to: 'codes#show', format: false, defaults: {format: 'html'}, namespace: /[^\/]+/

    get '/spaces/:namespace/(*application_space_name)/:branch/new', to: 'application_spaces#new_file', namespace: /[^\/]+/
    get '/spaces/:namespace/(*application_space_name)/edit/:branch/(*path)', to: 'application_spaces#edit_file', format: false, defaults: {format: 'html'}, namespace: /[^\/]+/
    get '/spaces/:namespace/(*application_space_name)/:branch/upload', to: 'application_spaces#upload_file', namespace: /[^\/]+/
    get '/spaces/:namespace/(*application_space_name)/blob/:branch/(*path)', to: 'application_spaces#blob', format: false, defaults: {format: 'html'}, namespace: /[^\/]+/
    get '/spaces/:namespace/(*application_space_name)/files/:branch(/*path)', to: 'application_spaces#files', defaults: { path: nil }, namespace: /[^\/]+/
    get '/spaces/:namespace/(*application_space_name)/resolve/:branch/(*path)', to: 'application_spaces#resolve', defaults: {format: 'txt'}, namespace: /[^\/]+/
    get '/spaces/:namespace/(*application_space_name)/community', to: 'application_spaces#community', namespace: /[^\/]+/
    get '/spaces/:namespace/(*application_space_name)/settings', to: 'application_spaces#settings', namespace: /[^\/]+/
    get '/spaces/:namespace/(*application_space_name)/commits', to: 'application_spaces#commits', namespace: /[^\/]+/
    get '/spaces/:namespace/(*application_space_name)/commit/:commit_id', to: 'application_spaces#commit', namespace: /[^\/]+/
    get '/spaces/:namespace/(*application_space_name)', to: 'application_spaces#show', format: false, defaults: {format: 'html'}, namespace: /[^\/]+/

    get '/profile/:user_id', to: 'profile#index', user_id: /[^\/]+/
    get '/profile/likes/:user_id', to: 'profile#likes', user_id: /[^\/]+/
    get    '/signup', to: 'sessions#signup'
    get    '/login', to: 'sessions#new'
    get    '/oidc/callback', to: 'sessions#oidc'
    post   '/login',   to: 'sessions#create'
    post   '/signup',   to: 'sessions#registration'
    delete '/logout',  to: 'sessions#destroy'
    get    '/logout',  to: 'sessions#destroy'

    # errors
    get '/errors/not-found', to: 'errors#not_found'
    get '/errors/unauthorized', to: 'errors#unauthorized'
  end
end
