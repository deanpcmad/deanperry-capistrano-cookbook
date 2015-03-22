# Capistrano::Cookbook

A collection of Capistrano 3 Compatible tasks to make deploying Rails and Sinatra based applications easier.

## Gemfile

    gem "capistrano"
    gem "capistrano-cookbook", github: "deanperry/capistrano-cookbook", require: false
    gem "capistrano-bundler", require: false
    gem "capistrano-rails", require: false

## Usage

### Including Tasks

To include all tasks from the gem, add the following to your `Capfile`:

```ruby
require 'capistrano/cookbook'
```

Otherwise you can include tasks individually:

```ruby
require 'capistrano/cookbook/check_revision'
require 'capistrano/cookbook/compile_assets_locally'
require 'capistrano/cookbook/logs'
require 'capistrano/cookbook/rails'
require 'capistrano/cookbook/monit'
require 'capistrano/cookbook/nginx'
require 'capistrano/cookbook/restart'
require 'capistrano/cookbook/run_tests'
require 'capistrano/cookbook/setup_config'
```

### The Tasks

#### Check Revision

Checks that the remote branch the selected stage deploys from, matches the current local version, if it doesn't the deploy will be halted with an error. 

Add the following to `deploy.rb`

```ruby
before :deploy, 'deploy:check_revision'
```

#### Rails Console

Connects to the server and opens `bin/rails console`.

```bash
cap STAGE rails:c
```

#### Compile Assets Locally

Compiles local assets and then rsyncs them to the production server. Avoids the need for a javascript runtime on the target machine and saves a significant amount of time when deploying to multiple web frontends.

Add the following to `deploy.rb`

``` ruby
 after 'deploy:symlink:shared', 'deploy:compile_assets_locally'
 ```

#### Logs

Allows remote log files (anything in `APP_PATH/shared/log`) to be tailed locally with Capistrano rather than SSHing in.

To tail the log file `APP_PATH/shared/log/production.log` on the `production` stage:

``` bash
cap production 'logs:tail[production]'
```

To tail the log file `APP_PATH/shared/log/unicorn.log`

``` bash
cap production 'logs:tail[unicorn]'
```

#### Monit

Provides convenience tasks for restarting the Monit service.

Available actions are `start`, `stop` and `restart`.

Usage:

```bash
cap STAGE monit:start
cap STAGE monit:stop
cap STAGE monit:restart
```

#### Nginx

Provides convenience tasks for interacting with Nginx using its `init.d` script as well as an additional task to remove the `default` virtualhost from `/etc/nginx/sites-enabled`

Available actions are `start`, `stop`, `restart`, `reload`, `remove_default_vhost`.

`reload` will reload the nginx virtualhosts without restarting the server.

Usage:

```bash
cap STAGE nginx:start
cap STAGE nginx:stop
cap STAGE nginx:restart
cap STAGE nginx:remove_default_vhost
```

#### Restart

Provides Commands for interacting with the Unicorn app server via an `init.d` script.

Usage:

``` bash
cap STAGE deploy:start
cap STAGE deploy:stop
cap STAGE deploy:force-stop
cap STAGE deploy:restart
cap STAGE deploy:upgrade
```

#### Run Tests

Allows a test suite to be automatically run with `rspec`, if the tests pass the deploy will continue, if they fail, the deploy will halt and the test output will be displayed.

Usage:

Define the tests to be run in `deploy.rb`

``` ruby
set(:tests, ['spec'])
```

and add a hook in `deploy.rb` to run them automatically:

``` ruby
before "deploy", "deploy:run_tests"
```

#### Setup Config

The `deploy:setup_config` tasks provides a simple way to automate the generation of server specific configuration files and the setting up of any required symlinks outside of the applications normal directory structure.

If no values are provided in `deploy.rb` to override the defaults then this task includes opinionated defaults to setup a server for deployment as explained in the book [Reliably Deploying Rails Applications](https://leanpub.com/deploying_rails_applications) and [this tutorial](http://www.talkingquickly.co.uk/2014/01/deploying-rails-apps-to-a-vps-with-capistrano-v3/).

Each of the `config_files` will be created in `APP_PATH/shared.config`.

The task looks in the following locations for a template file with a corresponding name with a `.erb` extension:

* `config/deploy/STAGE/FILENAME.erb`
* `config/deploy/shared/FILENAME.erb`
* `templates/FILENAME.erb` directory of this gem ([github link](https://github.com/TalkingQuickly/capistrano-cookbook/tree/master/lib/capistrano/cookbook/templates))  

For any config files included in the `source` part of an entry in the `symlinks` array, a symlink will be created to the corresponding `link` location on the target machine.

Finally any config files included in `executable_config_files` will be marked as executable.

This task will also automatically invoke the following tasks:

* `nginx:remove_default_vhost`
* `nginx:reload`
* `monit:restart`

To ensure configuration file changes are picked up correctly.

The defaults are:

Config Files:

``` ruby
set(
  :config_files,
  %w(
  nginx.conf
  database.example.yml
  log_rotation
  monit
  unicorn.rb
  unicorn_init.sh
))
```

Symlinks:

```ruby
set(
  :symlinks,
  [
    {
      source: "nginx.conf",
      link: "/etc/nginx/sites-enabled/{{full_app_name}}"
    },
    {
      source: "unicorn_init.sh",
      link: "/etc/init.d/unicorn_{{full_app_name}}"
    },
    {
      source: "log_rotation",
     link: "/etc/logrotate.d/{{full_app_name}}"
    },
    {
      source: "monit",
      link: "/etc/monit/conf.d/{{full_app_name}}.conf"
    }
  ]
)
```

Executable Config Files:

```ruby
set(
  :executable_config_files,
  w(
    unicorn_init.sh
  )
)
```