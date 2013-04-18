RedmineApp::Application.routes.draw do
  mount Rich::Engine => '/rich', :as => 'rich'
end
