module Capstrap
  module Chef
    
    def self.load_into(configuration)
      configuration.load do
        
        namespace :chef do
          namespace :install do
            
            desc "Installs chef gem"
            task :lib do
              unless chef_installed?
                cmd = [
                  %{use #{ruby}},
                  %{gem install chef --no-rdoc --no-ri}
                ]
                rvm_run cmd.join(" && ")
              end
            end

            desc "Installs chef cookbook git repository"
            task :cookbooks do
              unless cookbooks_repo_installed?
                cmd = [
                  %{use #{ruby}},
                  %{git clone #{cookbooks_repo} #{cookbooks_path}},
                  %{cd #{cookbooks_path}},
                  update_cmd
                ]
                rvm_run cmd.join(" && ")
              end
            end

            desc "Installs chef configuration git repository"
            task :config do
              unless config_repo_installed?
                cmd = [
                  %{use #{ruby}},
                  %{git clone #{config_repo} #{config_path}},
                  %{cd #{config_path}},
                  update_cmd
                ]
                rvm_run cmd.join(" && ")
              end
            end
          end

          namespace :execute do

            desc "Executes chef solo configuration"
            task :solo do
              cmd = [
                %{use #{ruby}},
                %{chef-solo}
              ]
              rvm_run cmd.join(" && ")
            end

            desc "Updates and executes chef solo configuration"
            task :update do
              cmd = [
                %{use #{ruby}},
                %{cd #{cookbooks_path}},
                %{git pull},
                update_cmd,
                %{cd #{config_path}},
                update_cmd,
                %{cd},
                %{chef-solo}
              ]
              rvm_run cmd.join(" && ")
            end
          end
        end
      end
    end
  end
end

if Capistrano::Configuration.instance
  Capstrap::Chef.load_into(Capistrano::Configuration.instance)
end
