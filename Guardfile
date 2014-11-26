# A sample Guardfile
# More info at https://github.com/guard/guard#readme

# Note: The cmd option is now required due to the increasing number of ways
#       rspec may be run, below are examples of the most common uses.
#  * bundler: 'bundle exec rspec'
#  * bundler binstubs: 'bin/rspec'
#  * spring: 'bin/rsspec' (This will use spring if running and you have
#                          installed the spring binstubs per the docs)
#  * zeus: 'zeus rspec' (requires the server to be started separetly)
#  * 'just' rspec: 'rspec'


group :chefspec do
  guard :rspec, cmd: 'SPEC_TYPE="chefspec" bundle exec rspec --pattern test/unit/*/*_spec.rb' do
    watch(%r{^test/.+_spec\.rb$})
    watch(%r{^lib/(.+)\.rb$})               { |m| "test/lib/#{m[1]}_spec.rb" }
    watch(%r{^recipes/(.+)\.rb$})           { |m| "test/recipes/#{m[1]}_spec.rb" }

    watch(%r{^recipes/(.+)\.rb$})           {"spec"}
    watch(%r{'test/support/(.+).rb$'})      {"spec"}
    watch(%r{^templates/(.+).erb$})         {"spec"}

    watch('.kitchen.yml')                   {"spec"}
    watch('test/*_helper.rb')               {"spec"}
  end
end

group :serverspec do
  guard :rspec, cmd: 'SPEC_TYPE="serverspec" bundle exec kitchen verify 1404' do
    
    watch(%r{^test/.+_spec\.rb$})

    watch(%r{'test/support/(.+).rb$'})      {"spec"}

    watch('test/*_helper.rb')               {"spec"}
  end
end




