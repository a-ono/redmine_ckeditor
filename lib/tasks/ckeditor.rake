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
      Rails.configuration.assets.precompile << "browser.js"
      Rake::Task["assets:precompile:all"].invoke
      Rake::Task["rich:assetize_ckeditor"].invoke

      ckeditor = RedmineCkeditor.root.join("assets/ckeditor")
      rm_rf ckeditor
      cp_r RedmineCkeditor.root.join("app/assets/javascripts/ckeditor-releases"), ckeditor
      rm ckeditor.join(".git")

      #ckeditor_contrib = RedmineCkeditor.root.join("assets/ckeditor-contrib")
      #mkdir_p ckeditor_contrib
      #cp_r Rails.root.join("public/assets/ckeditor-contrib/."), ckeditor_contrib

      javascripts = RedmineCkeditor.root.join("assets/javascripts")
      stylesheets = RedmineCkeditor.root.join("assets/stylesheets")
      images = RedmineCkeditor.root.join("assets/images")
      mkdir_p [javascripts, stylesheets, images]
      cp Rails.root.join("public/assets/application.js"), javascripts
      cp Rails.root.join("public/assets/browser.js"), javascripts
      cp Dir.glob(Rails.root.join("public/assets/rich/*.css")), stylesheets
      cp Dir.glob(Rails.root.join("public/assets/rich/*.png")), images

      rm_rf Rails.root.join(".sass-cache")
      Rake::Task["assets:clean:all"].invoke
    end
  end

  class Migration
    def initialize(projects, format)
      @formatter = Redmine::WikiFormatting.formatter_for(format)
      @messages = [
        "*** WARNING ***",
        "All formattable texts are migrated to HTML and cannot be rollback.",
        "It is strongly recommended to backup your database.",
        "***************"
      ]

      if projects.empty?
        @projects = Project.all
        @messages << "projects: ALL"
      else
        @projects = Project.where(:identifier => projects)
        @messages << "projects: #{@projects.pluck(:identifier).join(",")}"
      end
      @messages << "migration: #{format} to HTML"
    end

    def start
      @messages.each {|message| puts message}
      print "Do you want to continue? (type 'y' to continue): "
      unless STDIN.gets.chomp == 'y'
        puts "Cancelled"
        return
      end

      @projects.each do |project|
        puts "project #{project.name}"
        project.description = format(project.description)
        project.save!
        migrate(:issues, project.issues, :description)
        migrate(:journals, Journal.where(:journalized_type => "Issue",
          :journalized_id => project.issues), :notes)
        migrate(:documents, project.documents, :description)
        migrate(:messages, Message.where(:board_id => project.boards), :content)
        migrate(:news, project.news, :description)
        migrate(:comments, Comment.where(:commented_type => "News",
          :commented_id => project.news), :comments)
        migrate(:wiki, WikiContent.where(:page_id => project.wiki.pages), :text) if project.wiki
      end
    end

    def migrate(type, records, column)
      n = records.count
      return if n == 0
      records.each_with_index do |record, i|
        print "\rMigrating #{type} ... (#{i}/#{n})"
        record.send("#{column.to_s}=", format(record.send(column)))
        record.save!
      end
      puts "\rMigrating #{type} ... done             "
    end

    def format(text)
      text && @formatter.new(text).to_html
    end
  end

  desc "Migrate text to html"
  task :migrate => :environment do
    projects = ENV['PROJECT'].to_s.split(",")
    format = ENV['FORMAT'] || Setting.text_formatting
    Migration.new(projects, format).start
  end
end
