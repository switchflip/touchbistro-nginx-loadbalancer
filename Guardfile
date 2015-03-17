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
    
    watch(%r{^test/.+_spec\.rb$})           {"spec"}
    watch(%r{'test/support/(.+).rb$'})      {"spec"}
    watch('test/*_helper.rb')               {"spec"}
  end
end




