# A sample Guardfile
# More info at https://github.com/guard/guard#readme

# also see this
# http://stackoverflow.com/questions/14724427/setting-up-guard-with-minitest-in-rails-3-2

guard :minitest do
  # watch(%r|^app/controllers/(.*)\.rb|) { |m| "test/controllers/#{m[1]}_test.rb" }
  # watch(%r|^app/helpers/(.*)\.rb|)     { |m| "test/helpers/#{m[1]}_test.rb" }
  # watch(%r|^app/models/(.*)\.rb|)      { |m| "test/unit/app/#{m[1]}_test.rb" }  
  # watch(%r|^app/workers/(.*)\.rb|)     { |m| "test/unit/app/workers/#{m[1]}_test.rb" }  
  
  watch(%r|^app/(.*)\.rb|)      { |m| "test/unit/**/*_test.rb" } 
end
