namespace :redmine_ckeditor do
  namespace :assets do
    desc "copy assets"
    task :copy => :environment do
      env = Sprockets::Environment.new(RedmineCkeditor.root)
      Rails.application.config.assets.paths.each do |path|
        env.append_path(path)
      end
      env.append_path("app/assets/javascripts")
      %w(application.js browser.js).each do |asset|
        assets = env.find_asset(asset)
        assets.write_to(RedmineCkeditor.root.join("assets/javascripts", asset))
      end

      ckeditor = RedmineCkeditor.root.join("assets/ckeditor")
      rm_rf ckeditor
      cp_r RedmineCkeditor.root.join("app/assets/javascripts/ckeditor-releases"), ckeditor
      rm ckeditor.join(".git")
    end
  end

  class Migration
    FORMATS = %w[textile markdown html]

    def initialize(projects, from, to)
      @from = from
      @to = to
      @projects = projects
    end

    def start
      [@from, @to].each do |format|
        next if FORMATS.include?(format)
        puts "#{format} format is not supported."
        puts "Available formats: #{FORMATS.join(", ")}"
        return
      end

      messages = [
        "*** WARNING ***",
        "It is strongly recommended to backup your database before migration, because it cannot be rolled back completely.",
        "***************"
      ]

      if @projects.empty?
        @projects = Project.all
        messages << "projects: ALL"
      else
        messages << "projects: #{@projects.pluck(:identifier).join(",")}"
      end
      messages << "migration: #{@from} to #{@to}"

      messages.each {|message| puts message}
      print "Do you want to continue? (type 'y' to continue): "
      unless STDIN.gets.chomp == 'y'
        puts "Cancelled"
        return
      end

      ActiveRecord::Base.transaction do
        @projects.each do |project|
          puts "project #{project.name}"
          project.update_column(:description, convert(project.description))
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
    end

    def migrate(type, records, column)
      n = records.count
      return if n == 0
      records.each_with_index do |record, i|
        print "\rMigrating #{type} ... (#{i}/#{n})"
        record.update_column(column, convert(record.send(column)))
      end
      puts "\rMigrating #{type} ... done             "
    end

    def convert(text)
      text && PandocRuby.convert(text, from: @from, to: @to)
    end
  end

  desc "Migrate text to html"
  task :migrate => :environment do
    projects = Project.where(:identifier => ENV['PROJECT'].to_s.split(","))
    from = ENV['FROM'] || Setting.text_formatting
    from = "html" if from == "CKEditor"
    to = ENV['TO'] || "html"
    Migration.new(projects, from, to).start
  end
end
