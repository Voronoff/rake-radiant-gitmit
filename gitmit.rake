require 'find'

db_current_path = "./db/db_current_ver/"
db_archive_path = "./db/db_archive/"
db_current = "./db/db_current_ver/current_ver.sql"
db_archive_name = (db_archive_path + Time.now.strftime("%Y-%m-%d_%H-%M-%S"))
namespace :radiant do
  desc "Create blank directories db_current_ver and db_archive in project if they don't already exist"
  task :create_db_directories => [:environment] do
    # The folders I need to create
    db_folders = [db_current_path,db_archive_path]
    for folder in db_folders
      # Check to see if it exists, make it if it doesn't
      if !File.exists?(folder)
        Dir.mkdir "#{folder}"
      end
    end
  end

  desc "Moves current version from db_current_ver to db_archive and renames it by date."
  task :move_current_version => :create_db_directories do
    if File.exists?(db_current)
      mv(db_current, db_archive_name)
    end
  end
  
  desc "Backup the database to a file." 
  task :db_dump => :move_current_version  do
    db_config = ActiveRecord::Base.configurations[RAILS_ENV]
    sh "mysqldump -u #{db_config['username']} -p#{db_config['password']} #{db_config['database']} > #{db_current}"
  end
  
  desc "Commit the project to git."
  task :gitmit => :db_dump do
    #Check to see if git repository exists, make it if it doesn't
    if !File.exists?("./.git")
      sh "git init"
    end
    sh "git add ."
    puts "Enter your commit message:"
    commit_message = $stdin.gets.chomp
    sh "git commit -m \"#{commit_message}\""
  end
end