namespace :redmine_ckeditor do
  namespace :assets do
    desc "Compile and copy all assets"
    task :precompile do
      ENV['RAILS_ENV'] ||= "production"
      ENV['RAILS_GROUP'] ||= "assets"
      Rails.configuration.assets.enabled = true
      Rails.configuration.assets.paths <<
        File.expand_path("../../../app/assets/javascripts", __FILE__)
      Rails.configuration.assets.precompile << "ckeditor-releases/ckeditor"
      Rake::Task["assets:precompile:all"].invoke
      Rake::Task["rich:assetize_ckeditor"].invoke

      ckeditor = RedmineCkeditor.root.join("assets/ckeditor")
      mkdir_p ckeditor
      cp_r RedmineCkeditor.root.join("app/assets/javascripts/ckeditor-releases/."), ckeditor

      ckeditor_contrib = RedmineCkeditor.root.join("assets/ckeditor-contrib")
      mkdir_p ckeditor_contrib
      cp_r Rails.root.join("public/assets/ckeditor-contrib/."), ckeditor_contrib

      javascripts = RedmineCkeditor.root.join("assets/javascripts")
      stylesheets = RedmineCkeditor.root.join("assets/stylesheets")
      images = RedmineCkeditor.root.join("assets/images")
      mkdir_p [javascripts, stylesheets, images]
      cp Rails.root.join("public/assets/application.js"), javascripts
      cp Dir.glob(Rails.root.join("public/assets/rich/*.css")), stylesheets
      cp Dir.glob(Rails.root.join("public/assets/rich/*.png")), images

      rm_rf Rails.root.join(".sass-cache")
      Rake::Task["assets:clean:all"].invoke
    end
  end
end
