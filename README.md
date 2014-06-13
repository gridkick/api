# GridKick

Treat your application services like first class citizens


### development setup

- Git clone adventure_api

- Git clone deploy. See deploy README for setup of the "local" env.

- Make sure you added `local.gridkick.com` to your `/etc/hosts` file.
    
    ```file
    ### gridkick
    #
    # IP matches 'adventure_api' Vagrantfile IP
    # local-api.gridkick.com  matches cap local deploy URL
    #
    <_IP_specified_in_deploy_>  local-api.gridkick.com
    <_IP_specified_in_deploy_>  local.gridkick.com
    ```
- Plug in the MongoDB IP and port to the mongoid.yml file

- Plug in the Redi IP, port, username, and password to the env file, 
  `config/deploy/local.env`.
  
- `cap local deploy:setup`

- `cap local deploy`
