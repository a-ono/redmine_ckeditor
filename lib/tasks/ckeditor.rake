namespace :redmine_ckeditor do
  namespace :assets do
    desc "Compile and copy all assets"
    task :precompile do
      ENV['RAILS_ENV'] ||= "production"
      ENV['RAILS_GROUP'] ||= "assets"
      Rails.configuration.assets.enabled = true
      Rake::Task["assets:precompile:all"].invoke
    end
  end
end
