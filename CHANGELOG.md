## 2.1

Changes since 2.0:

### Features

  * Added support for submitting errors and deployments over https.
  * All optional Toadhopper host settings are now exposed for Capistrano
    deployments, including `:airbrake_secure`, `:airbrake_notify_host`,
    `:airbrake_error_url`, and `:airbrake_deploy_url`.

### Bugs

  * API Errors returned from a failed deploy notification were not being captured.
  * Capistrano: the [deprecated] api key setting was not being read.

### Miscellaneous

  * toadhopper is now tested in a continuous integration environment, thanks to [travis-ci.org](http://travis-ci.org/).
    The build is currently
    [![Build Status](https://secure.travis-ci.org/toolmantim/toadhopper.png)](http://travis-ci.org/toolmantim/toadhopper)