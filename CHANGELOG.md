## 2.1

Changes since 2.0:

### Features

  * Added support for submitting errors and deployments over https by providing a :notify_host with 'https://domain.com'.
  * Allow advanced http transport settings via the :transport option
  * All optional Toadhopper host settings are now exposed for Capistrano
    deployments, including `:airbrake_notify_host`, `:airbrake_error_url`
    `:airbrake_deploy_url`, and `:airbrake_transport`.

### Bugs

  * API Errors returned from a failed deploy notification were not being captured.
  * Capistrano: the [deprecated] api key setting was not being read.

### Miscellaneous

  * Changed default notification domain to airbrake.io.  Note: The official domain is api.airbrake.io, but has been touch-and-go.
  * toadhopper is now tested in a continuous integration environment, thanks to [travis-ci.org](http://travis-ci.org/).
    The build is currently
    [![Build Status](https://secure.travis-ci.org/toolmantim/toadhopper.png)](http://travis-ci.org/toolmantim/toadhopper)