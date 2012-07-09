require 'toadhopper'


Capistrano::Configuration.instance(:must_exist).load do
  after 'deploy',            'deploy:notify_airbrake'
  after 'deploy:migrations', 'deploy:notify_airbrake'

  namespace :deploy do
    desc 'Notify Airbrake of the deployment'
    task :notify_airbrake, :except => {:no_release => true} do
      framework_env = fetch(:rails_env, fetch(:airbrake_env, 'production'))
      api_key = fetch(:hoptoad_api_key, nil) || fetch(:airbrake_api_key)
      host_options = {
        :notify_host  => fetch(:airbrake_notify_host, nil),
        :error_url    => fetch(:airbrake_error_url, nil),
        :deploy_url   => fetch(:airbrake_deploy_url, nil),
        :transport    => fetch(:airbrake_transport, nil),
      }
      puts 'Notifying Airbrake of deploy'
      deploy_options = {:framework_env => framework_env, :scm_revision => current_revision, :scm_repository => repository}
      Toadhopper.new(api_key, host_options).deploy!(deploy_options)
      puts 'Airbrake notification complete'
    end
  end
end
