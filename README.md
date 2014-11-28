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

## Supported Platforms

Ubuntu 14.04

## Attributes

## Usage

## Tests
We are using chefspec and serverspec to test our recipe along with test-kitchen.

* to run integration tests run `bundle exec guard start -g serverspec`
* to run unit test run `bundle exec guard start -g chefspec`

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

Author:: Thomas Berry (thom.berry@gmail.com)
