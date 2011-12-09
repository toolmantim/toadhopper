require 'toadhopper'


Capistrano::Configuration.instance(:must_exist).load do
  after 'deploy',            'deploy:notify_airbrake'
  after 'deploy:migrations', 'deploy:notify_airbrake'

  namespace :deploy do
    desc 'Notify Airbrake of the deployment'
    task :notify_airbrake, :except => {:no_release => true} do
      framework_env = fetch(:rails_env, fetch(:airbrake_env, 'production'))
      api_key = fetch(:hoptoad_api_key, nil) || fetch(:airbrake_api_key)
      puts 'Notifying Airbrake of deploy'
      options = {:framework_env => framework_env, :scm_revision => current_revision, :scm_repository => repository}
      Toadhopper(api_key).deploy!(options)
      puts 'Airbrake notification complete'
    end
  end
end
