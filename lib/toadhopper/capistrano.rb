require 'toadhopper'


Capistrano::Configuration.instance(:must_exist).load do
  after 'deploy',            'deploy:notify_hoptoad'
  after 'deploy:migrations', 'deploy:notify_hoptoad'

  namespace :deploy do
    desc 'Notify Hoptoad of the deployment'
    task :notify_hoptoad, :except => {:no_release => true} do
      framework_env = fetch(:rails_env, fetch(:hoptoad_env, 'production'))
      api_key = fetch(:hoptoad_api_key)
      puts 'Notifying Hoptoad of deploy'
      options = {:framework_env => framework_env, :scm_revision => current_revision, :scm_repository => repository}
      Toadhopper(api_key).deploy!(options)
      puts 'Hoptoad notification complete'
    end
  end
end
