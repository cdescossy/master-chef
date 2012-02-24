config_file = ENV['MASTER_CHEF_CONFIG']

raise "Please specify config file with env var MASTER_CHEF_CONFIG" unless config_file
raise "File not found #{config_file}" unless File.exists? config_file

config = JSON.load(File.read(config_file))

run_list = ["recipe[master-chef::init]"] + config["run_list"]
json_file = Tempfile.new "chef_config"
json_file.write JSON.dump({"run_list" => run_list})
json_file.close

ENV['MASTER_CHEF_CONFIG'] = File.expand_path(config_file)

puts "************************* Master chef solo SOLO *************************"
puts "Hostname : #{`hostname`}"
puts "Repos : #{config["repos"].inspect}"
puts "Run list : #{run_list.inspect}"
puts "******************************************************************************"

def exec_local cmd
  begin
    abort "#{cmd} failed. Aborting..." unless system cmd
  rescue
    abort "#{cmd} failed. Aborting..."
  end
end

git_cache_directory = ENV["GIT_CACHE_DIRECTORY"] || "/var/chef/cache/git_repos"
exec_local "mkdir -p #{git_cache_directory}"

cookbooks = []
roles = []

config["repos"]["git"].each do |url|
  name = File.basename(url)
  target = File.join(git_cache_directory, name)
  unless File.exists? target
    puts "Cloning git repo #{url}"
    exec_local "cd #{git_cache_directory} && git clone #{url} #{name}"
  end
  exec_local "cd #{target} && git pull > /dev/null"
  cookbook = File.join(target, "cookbooks")
  cookbooks << cookbook if File.exists? cookbook
  role = File.join(target, "roles")
  roles << role if File.exists? role
end

log_level :info
log_location STDOUT
json_attribs json_file.path
cookbook_path cookbooks
role_path roles
