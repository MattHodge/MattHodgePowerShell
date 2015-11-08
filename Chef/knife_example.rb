log_level :info
log_location STDOUT
node_name 'your_user'
client_key 'your_user.pem'
validation_client_name 'chef-validator'
validation_key '~/.chef/chef-validator.pem'
chef_server_url 'https://your.chef.server.com:443/organizations/your_org'
chef_server_root 'https://your.chef.server.com:443'
syntax_check_cache_path 'syntax_check_cache'
knife[:editor] = 'C:/Windows/System32/notepad.exe'
current_dir = File.dirname(__FILE__)
cookbook_path [
  'D:/ProjectsGit/your-chef-repo/cookbooks'
]
knife[:vault_mode] = 'client'
