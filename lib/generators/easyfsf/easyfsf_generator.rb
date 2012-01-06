require 'rails/generators'
require 'rails/generators/rails/app/app_generator'
require 'rails/version'

module Easyfsf
  class EasyfsfGenerator < Rails::Generators::Base
    source_root File.expand_path("../templates", __FILE__)
    def copy_temeplate_files
      
      directory 'app'
      directory 'public'

    end
  end
end