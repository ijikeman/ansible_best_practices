require 'rake'
require 'rspec/core/rake_task'
require 'yaml'
require 'ansible_spec'

#.ansiblespecに記載されているplaybook(.yml)を読み込む
properties = AnsibleSpec.get_properties
# {"name"=>"Ansible-Sample-TDD", "hosts"=>["192.168.0.103","192.168.0.103"], "user"=>"root", "roles"=>["nginx", "mariadb"]}
# {"name"=>"Ansible-Sample-TDD", "hosts"=>[{"name" => "192.168.0.103:22","uri"=>"192.168.0.103","port"=>22, "private_key"=> "~/.ssh/id_rsa"}], "user"=>"root", "roles"=>["nginx", "mariadb"]}

# get ansible.cfg
cfg = AnsibleSpec::AnsibleCfg.new

# .ansiblespec の inventory file を読み込み groupsを作成
# {"group1"=>["host1", "host2"], "group2"=>["host3", "host4"]}
groups = {}
hosts  = []
current_group = nil
inventory_file = nil
File::open(ENV['PWD'] + '/.ansiblespec') do |f|
  while line = f.gets
    if md = line.match(/inventory\s*:\s*(.+)/)
      inventory_file = md[1]
    end
  end
end
if inventory_file
  File::open(inventory_file) do |f|
    while line = f.gets
      # Remove comment
      md = line.match(/^([^;]+)/)
      next unless md
      line = md[0]
      if line =~ /^\[([^\]]+)\]/
        current_group = $1
      elsif line =~ /^(\S+)/
        if current_group
          groups[current_group] ||= []
          groups[current_group] << $1
        else
          hosts << $1
        end
      end
    end
  end
else
  puts '"inventory_file" line is not found in .ansiblespec file'
  exit
end

# propertyのhostsが0の場合ははずす
properties = properties.compact.reject{|e| e["hosts"].length == 0}

namespace :spec do
  # rake spec:allを設定(後述する rake spec:property['group']以下のタスクの処理を全て紐づけ実行)
  desc "Run serverspec of all"
  task :all => properties.map {|property| "#{property['group']}" }

  properties.each_with_index.map do |property, index|
    # rake spec:property['group']を定義
    desc "Run serverspec for group #{property['group']}"
    # 後述する spec:property['group']:[host['uri']の処理を全て紐づけ実行
    task "#{property['group']}" => property['hosts'].map {|host| "#{property['group']}:#{host['uri']}" }

    # Exec serverspec foreach host on group
    property['hosts'].each do |host|
      desc "Run serverspec for #{host['uri']} in group #{property['group']}"
      RSpec::Core::RakeTask.new("#{property['group']}:#{host['uri']}".to_sym) do |t| # rake spec:[group]:[host]を定義
        # 実行内容を記載
        puts "Run serverspec for #{host['uri']} in group #{property['group']}"
        # host毎に環境変数を設定
        ENV['TARGET_HOSTS'] = host['hosts']
        ENV['TARGET_HOST'] = host['uri']
        ENV['TARGET_PORT'] = host['port'].to_s
        ENV['TARGET_GROUP_INDEX'] = index.to_s
        ENV['TARGET_PRIVATE_KEY'] = host['private_key']
        unless host['user'].nil?
          ENV['TARGET_USER'] = host['user']
        else
          ENV['TARGET_USER'] = property['user']
        end
        ENV['TARGET_PASSWORD'] = host['pass']
        ENV['TARGET_CONNECTION'] = host['connection']

        # 以下のspecを実行
        # roles/[role_name]/spec/all_spec.rb
        # roles/[role_name]/spec/[group_name]/all_spec.rb
        # roles/[role_name]/spec/[group_name]/[host]_spec.rb
        t.pattern = '{' + cfg.roles_path.join(',') + '}/{' + property['roles'].join(',') + '}/spec/{all_spec.rb,' + property['group'] + '/all_spec.rb,' + property['group'] + '/' + host['uri'] + '_spec.rb}'
      end
    end
  end
end
