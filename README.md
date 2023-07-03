# ManageIQ

[![Build Status](https://travis-ci.com/ManageIQ/manageiq.svg?branch=kasparov)](https://travis-ci.com/ManageIQ/manageiq)
[![Code Climate](https://codeclimate.com/github/ManageIQ/manageiq/badges/gpa.svg)](https://codeclimate.com/github/ManageIQ/manageiq)
[![Codacy](https://api.codacy.com/project/badge/grade/9ffce48ccb924020ae8f9e698048e9a4)](https://www.codacy.com/app/ManageIQ/manageiq)
[![Coverage Status](https://coveralls.io/repos/ManageIQ/manageiq/badge.svg?branch=kasparov&service=github)](https://coveralls.io/github/ManageIQ/manageiq?branch=kasparov)
[![Security](https://hakiri.io/github/ManageIQ/manageiq/kasparov.svg)](https://hakiri.io/github/ManageIQ/manageiq/kasparov)
[![Open Source Helpers](https://www.codetriage.com/manageiq/manageiq/badges/users.svg)](https://www.codetriage.com/manageiq/manageiq)

[![Chat](https://badges.gitter.im/Join%20Chat.svg)](https://gitter.im/ManageIQ/manageiq?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge&utm_content=badge)
[![Translate](https://img.shields.io/badge/translate-transifex-blue.svg)](https://www.transifex.com/manageiq/manageiq/dashboard/)
[![License](http://img.shields.io/badge/license-APACHE2-blue.svg)](https://www.apache.org/licenses/LICENSE-2.0.html)


[![Build history for master branch](https://buildstats.info/travisci/chart/ManageIQ/manageiq?branch=kasparov&includeBuildsFromPullRequest=false&buildCount=50)](https://travis-ci.org/ManageIQ/manageiq/branches)

## Discover, Optimize, and Control your Hybrid IT

### Manage containers, virtual machines, networks, and storage from a single platform

ManageIQ is an open-source Management Platform that delivers the insight, control, and
automation that enterprises need to address the challenges of managing hybrid
IT environments.  It has the following feature sets:

* **Insight**: Discovery, Monitoring, Utilization, Performance, Reporting, Analytics, Chargeback, and Trending.
* **Control**: Security, Compliance, Alerting, Policy-Based Resource and Configuration Management.
* **Automate**: IT Process, Task and Event, Provisioning, Workload Management and Orchestration.
* **Integrate**: Systems Management, Tools and Processes, Event Consoles, CMDB, RBA, and Web Services.

## Get Started

*  [**Download community builds** for your platform](http://manageiq.org/download/)
*  [**Fork the source** to contribute](https://github.com/ManageIQ/manageiq)
*  [**Learn** to use ManageIQ](https://www.youtube.com/user/ManageIQVideo)

## Prerequisites

* **OS**: Linux-based system
* **Others**:

|   Name     | Min Version | Max version |
|------------|-------------|-------------|
|Ruby        |2.6.x        | 2.7.x       |
|Rails       |5.6.x        |             |
|Bundler     |1.15.x       |             |
|NodeJS      |12.x.x       |             |
|Python      |2.7.x        |             |
|PostgreSQL  |10.x         | 12.x        |

## Installation

*  Install the header files for OpenSSL, readline and zlib

|  PM |                            Command                            |
|-----|---------------------------------------------------------------|
| apt | `sudo apt -y install libssl-dev libreadline-dev zlib1g-dev`   |
| yum | `sudo yum -y install openssl-devel readline-devel zlib-devel` |

* Libraries

|  PM |                            Command                            |
|-----|---------------------------------------------------------------|
| apt | `sudo apt -y install build-essential libffi-dev libpq-dev libxml2-dev libcurl4-openssl-dev cmake python`   |
| yum | `sudo yum -y install @development libffi-devel postgresql-devel libxml2-devel libcurl-devel cmake python` |

* Memcached

|  PM |                  Command            |
|-----|-------------------------------------|
| apt | `sudo apt -y install memcached`     |
| yum | `sudo yum -y install memcached`     |

* PostgreSQL

|  PM |                     Command                    |
|-----|------------------------------------------------|
| apt | `sudo apt -y install postgresql-11`            |
| yum | `sudo yum -y install postgresql-server`        |

* Start PostgreSQL
    - Fedora / CentOS
    
        `sudo PGSETUP_INITDB_OPTIONS='--auth trust --username root --encoding UTF-8 --locale C' postgresql-setup --initdb`

    - Debian / Ubuntu
        ```
        sudo pg_dropcluster --stop 11 main
        sudo pg_createcluster -e UTF-8 -l C 11 main -- --auth trust --username root
        sudo pg_ctlcluster 11 main start
        ```

* nvm + yarn
    ```
    nvm install 12
    nvm use 12
    
    # Set version 12 as the default for all scripts
    nvm alias default 12
    
    npm install --global yarn
    ```

* Ruby (>=2.6.0 && < 3.0.0) + Ruby version manager:
    - [rbenv](https://github.com/rbenv/rbenv)
    - [rvm](https://rvm.io/)
    
## Server installation and operations:
* Install dependencies: `bin/setup`
* Update dependencies: 
  - With assets: `bin/update`
  - Without assets: `bundle update` 
* Run server: `rake evm:start`
* **Rake tasks** for operations:
  ```
    rake about                              # List versions of all Rails frameworks and the environment
    rake app:template                       # Applies the template supplied by LOCATION=(/path/to/template) or URL
    rake app:update                         # Update configs and some other initially generated files (or use just update:configs or ...
    rake assets:clean[keep]                 # Remove old compiled assets
    rake assets:clobber                     # Remove compiled assets
    rake assets:environment                 # Load asset compile environment
    rake assets:precompile                  # Compile all the assets named in config.assets.precompile
    rake cache_digests:dependencies         # Lookup first-level dependencies for TEMPLATE (like messages/show or comments/_comment.h...
    rake cache_digests:nested_dependencies  # Lookup nested dependencies for TEMPLATE (like messages/show or comments/_comment.html)
    rake clean                              # Remove any temporary products
    rake clobber                            # Remove any generated files
    rake db:create                          # Creates the database from DATABASE_URL or config/database.yml for the current RAILS_ENV...
    rake db:drop                            # Drops the database from DATABASE_URL or config/database.yml for the current RAILS_ENV (...
    rake db:environment:set                 # Set the environment value for the database
    rake db:fixtures:load                   # Loads fixtures into the current environment's database
    rake db:migrate                         # Migrate the database (options: VERSION=x, VERBOSE=false, SCOPE=blog)
    rake db:migrate:status                  # Display status of migrations
    rake db:rollback                        # Rolls the schema back to the previous version (specify steps w/ STEP=n)
    rake db:schema:cache:clear              # Clears a db/schema_cache.dump file
    rake db:schema:cache:dump               # Creates a db/schema_cache.dump file
    rake db:schema:dump                     # Creates a db/schema.rb file that is portable against any DB supported by Active Record
    rake db:schema:load                     # Loads a schema.rb file into the database
    rake db:seed                            # Loads the seed data from db/seeds.rb
    rake db:sessions:clear                  # Clear the sessions table
    rake db:sessions:create                 # Creates a sessions migration for use with ActiveRecord::SessionStore
    rake db:sessions:trim                   # Trim old sessions from the table (default: > 30 days)
    rake db:setup                           # Creates the database, loads the schema, and initializes with the seed data (use db:rese...
    rake db:size                            # Print data size for entire database
    rake db:structure:dump                  # Dumps the database structure to db/structure.sql
    rake db:structure:load                  # Recreates the databases from the structure.sql file
    rake db:tables:size                     # Print data size for all tables
    rake db:version                         # Retrieves the current schema version number
    rake dev:cache                          # Toggle development mode caching on/off
    rake dialogs:export[filename]           # Exports all dialogs to a yml file
    rake dialogs:import[filename]           # Imports dialogs from a yml file
    rake evm:assets:compile                 # Compile assets (clobber and precompile)
    rake evm:automate:backup                # Backup all automate domains to a zip file or backup folder
    rake evm:automate:clear                 # Deletes ALL automate model information for ALL domains
    rake evm:automate:convert               # Convert the legacy automation model to new format  ENV options FILE,DOMAIN,EXPORT_DIR|Z...
    rake evm:automate:export                # Export automate model information to a folder or zip file
    rake evm:automate:extract_methods       # Extract automate methods
    rake evm:automate:import                # Import automate model information from an export folder or zip file
    rake evm:automate:list_class            # Lists automate classes
    rake evm:automate:reset                 # Reset the default automate domain(s) (ManageIQ and others)
    rake evm:automate:restore               # Restore automate domains from a backup zip file or folder
    rake evm:automate:simulate              # Method simulation
    rake evm:automate:usage                 # Usage information regarding available tasks
    rake evm:compile_sti_loader             # Compile STI inheritance relationship cache
    rake evm:db:backup:local                # Backup the local ManageIQ EVM Database (VMDB) to a local file
    rake evm:db:backup:remote               # Backup the local ManageIQ EVM Database (VMDB) to a remote file
    rake evm:db:check_schema                # Check the current schema against the schema.yml file for inconsistencies
    rake evm:db:destroy                     # Destroys the ManageIQ EVM Database (VMDB) of all tables, views and indices
    rake evm:db:gc                          # clean up database
    rake evm:db:region                      # Set the region of the current ManageIQ EVM Database (VMDB)
    rake evm:db:reset                       # Resets the ManageIQ EVM Database (VMDB) of all tables, views and indices
    rake evm:db:restore:local               # Restore the local ManageIQ EVM Database (VMDB) from a local backup file
    rake evm:db:restore:remote              # Restore the local ManageIQ EVM Database (VMDB) from a remote backup file
    rake evm:db:seed                        # Seed the ManageIQ EVM Database (VMDB) with defaults
    rake evm:db:start                       # Start the local ManageIQ EVM Database (VMDB)
    rake evm:db:stop                        # Stop the local ManageIQ EVM Database (VMDB)
    rake evm:db:write_schema                # Write the current schema to the schema.yml file
    rake evm:dbsync:destroy_local_region    # Remove remote region data from local database
    rake evm:dbsync:resync_excludes         # Resync excluded tables
    rake evm:join_region                    # Write a remote region id to this server's REGION file
    rake evm:kill                           # Kill the ManageIQ EVM Application
    rake evm:raise_server_event             # Raise evm event
    rake evm:restart                        # Restart the ManageIQ EVM Application
    rake evm:start                          # Start the ManageIQ EVM Application
    rake evm:status                         # Report Status of the ManageIQ EVM Application
    rake evm:status_full                    # Report Status of the ManageIQ EVM Application
    rake evm:stop                           # Stop the ManageIQ EVM Application
    rake evm:update_start                   # Start updating the appliance
    rake evm:update_stop                    # Stop updating the appliance
    rake gettext:add_language[language]     # add a new language
    rake gettext:find                       # Update pot/po files
    rake gettext:pack                       # Create mo-files
    rake gettext:po_to_json                 # Convert PO files to JS files
    rake gettext:store_model_attributes     # write the model attributes to <locale_path>/model_attributes.rb
    rake initializers                       # Print out all defined initializers in the order they are invoked by Rails
    rake locale:extract_locale_names        # Extract human locale names from translation catalogs and store them in a yaml file
    rake locale:extract_yaml_strings        # Extract strings from various yaml files and store them in a ruby file for gettext:find
    rake locale:plugin:find[engine]         # Extract plugin strings - execute as: rake locale:plugin:find[plugin_name]
    rake locale:po_to_json                  # Convert PO files from all plugins to JS files
    rake locale:run_store_model_attributes  # Run store_model_attributes task in i18n environment
    rake locale:store_dictionary_strings    # Extract strings from en.yml and store them in a ruby file for gettext:find
    rake locale:store_model_attributes      # Extract model attribute names and virtual column names
    rake locale:update                      # Update ManageIQ gettext catalogs
    rake log:clear                          # Truncates all/specified *.log files in log/ to zero bytes (specify which logs with LOGS...
    rake middleware                         # Prints out your Rack middleware stack
    rake notes                              # Enumerate all annotations (use notes:optimize, :fixme, :todo for focus)
    rake notes:custom                       # Enumerate a custom annotation, specify with ANNOTATION=CUSTOM
    rake release                            # Release a new project version
    rake restart                            # Restart app by touching tmp/restart.txt
    rake routes                             # Print out all defined routes in match order, with names
    rake secret                             # Generate a cryptographically secure secret key (this is typically used to generate a se...
    rake stats                              # Report code statistics (KLOCs, etc) from the application or engine
    rake test                               # Runs all tests in test folder
    rake test:brakeman                      # Run Brakeman
    rake test:db                            # Run tests quickly, but also reset db
    rake time:zones[country_or_offset]      # List all time zones, list by two-letter country code (`rails time:zones[US]`), or list ...
    rake tmp:clear                          # Clear cache and socket files from tmp/ (narrow w/ tmp:cache:clear, tmp:sockets:clear)
    rake tmp:create                         # Creates tmp directories for cache, sockets, and pids
  ```

## Learn more

*  [**Read** developer guides](https://github.com/ManageiQ/guides)
*  [**Chat** with contributors on Gitter](https://gitter.im/ManageIQ/manageiq)
*  [**File or view bug reports and feature requests** using Issues on Github](https://github.com/ManageIQ/manageiq/issues?state=open)
*  [**Ask** questions of ManageIQ experts](http://talk.manageiq.org/)
*  [**Discuss** ManageIQ with developers and power users](http://talk.manageiq.org/)

We respectfully ask that you do not directly email any manageiq committers with
questions or problems. The community is best served when discussions are held in
public.

## Licensing

See [LICENSE.txt](LICENSE.txt).

Except where otherwise noted, all ManageIQ source files are covered by
the following copyright and license notice:

Copyright 2014-2020 ManageIQ Authors.

## Export Notice

By downloading ManageIQ software, you acknowledge that you understand all of the
following: ManageIQ software and technical information may be subject to the
U.S. Export Administration Regulations (the "EAR") and other U.S. and foreign
laws and may not be exported, re-exported or transferred (a) to any country
listed in Country Group E:1 in Supplement No. 1 to part 740 of the EAR
(currently, Cuba, Iran, North Korea, Sudan & Syria); (b) to any prohibited
destination or to any end user who has been prohibited from participating in
U.S. export transactions by any federal agency of the U.S. government; or (c)
for use in connection with the design, development or production of nuclear,
chemical or biological weapons, or rocket systems, space launch vehicles, or
sounding rockets, or unmanned air vehicle systems. You may not download ManageIQ
software or technical information if you are located in one of these countries
or otherwise subject to these restrictions. You may not provide ManageIQ
software or technical information to individuals or entities located in one of
these countries or otherwise subject to these restrictions. You are also
responsible for compliance with foreign law requirements applicable to the
import, export and use of ManageIQ software and technical information.


Commit Load Balancer: https://github.com/ManageIQ/manageiq-ui-classic/commit/79e4310255d79c0a4fc1a6b6a7bdb5bad05cb344
https://github.com/ManageIQ/manageiq/commit/84142da66ba49512c9642f93926928f9719e8961
