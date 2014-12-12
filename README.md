```
 /$$   /$$           /$$                              
| $$$ | $$          |__/                              
| $$$$| $$  /$$$$$$  /$$ /$$$$$$$  /$$   /$$          
| $$ $$ $$ /$$__  $$| $$| $$__  $$|  $$ /$$/          
| $$  $$$$| $$  \ $$| $$| $$  \ $$ \  $$$$/           
| $$\  $$$| $$  | $$| $$| $$  | $$  >$$  $$           
| $$ \  $$|  $$$$$$$| $$| $$  | $$ /$$/\  $$          
|__/  \__/ \____  $$|__/|__/  |__/|__/  \__/          
           /$$  \ $$                                  
          |  $$$$$$/                                  
           \______/                                   
 /$$$$$$$                      /$$                    
| $$__  $$                    |__/                    
| $$  \ $$  /$$$$$$   /$$$$$$$ /$$  /$$$$$$   /$$$$$$ 
| $$$$$$$/ /$$__  $$ /$$_____/| $$ /$$__  $$ /$$__  $$
| $$__  $$| $$$$$$$$| $$      | $$| $$  \ $$| $$$$$$$$
| $$  \ $$| $$_____/| $$      | $$| $$  | $$| $$_____/
| $$  | $$|  $$$$$$$|  $$$$$$$| $$| $$$$$$$/|  $$$$$$$
|__/  |__/ \_______/ \_______/|__/| $$____/  \_______/
                                  | $$                
                                  | $$                
                                  |__/                
```

# touchbistro-nginx-loadbalancer-cookbook

A recipe which setups up a nginx load balancer server on ubuntu 14.04.

## Requirements
* ruby 2.1.1
* [rbenv](https://github.com/sstephenson/rbenv)
* [chef-dk](https://downloads.getchef.com/chef-dk/)
* [vagrant](https://www.vagrantup.com/downloads.html)
* [virtualBox](https://www.virtualbox.org/wiki/Downloads)

## Supported Platforms
* Ubuntu 14.04

## Setup
* `git pull git@github.com:TouchBistro/touchbistro-elasticsearch-cookbook.git`
* ``bundle install`

### To setup local VM with your recipe

* Note: You should run these commands in sequential order
* Create basic VM without recipe:`kitchen create 1404`
* Run chef scripts on VM with:   `kitchen converge 1404`
* Generate berksfiles: `berks`

Note: You should run these commands in sequential order
* Create basic VM without recipe:          `kitchen create 1404`
* Run Chef-Solo on your VM with the recipe `kitchen converge 1404`

## Attributes

## Usage

## Tests
We are using chefspec and serverspec to test our recipe along with test-kitchen.

* to run integration tests run: `bundle exec guard start -g serverspec`
* to run unit test run:         `bundle exec guard start -g chefspec`

### touchbistro-nginx-loadbalancer::default

Include `touchbistro-nginx-loadbalancer` in your node's `run_list`:

```json
{
  "run_list": [
    "recipe[touchbistro-nginx-loadbalancer::default]"
  ]
}
```

## License and Authors
Author: [Thomas Berry](https://github.com/switchflip) and [Rob Gilson](https://github.com/D1plo1d) at [TouchBistro](www.touchbistro.com) in Toronto, Canada.
