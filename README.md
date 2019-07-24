# Ansible Best Practiceを元によりより汎用性を高めた構成で作っております
コーディング規約


# Discription Directories
```
group_vars/
  all.yml
  webserver.yml
  mailserver.yml

inventories/
  production/
    hosts
    group_vars/
      all.yml
      webserver.yml
      mailserver.yml
  staging/

roles/
  common_tasks/
    tasks/
      flush_handlers.yml
      mkdir.yml
      package_install.yml
      service_reloaded.yml
      service_started.yml
      service_started_RedHat_6.yml
      service_started_RedHat_7.yml
      ...
  common/
  os/
  crond/
    handlers/
    tasks/
      main.yml
      install.yml
      setup.yml
    templates/
      crontab_root.j2
    files/
    vars/
      main.yml
  httpd/
    tasks/
      main.yml
      install.yml
      install_RedHat_6.yml
      install_RedHat_7.yml
      setup.yml
      setup_RedHat.yml
      setup_Debian.yml
    vars/
      main.yml
      RedHat_6.yml
      RedHat_7.yml
      Debian.yml
```

# Discription Vars

varsは様々な箇所で記載することができますが、反面適材適所に記載しなければ全体として見通しが悪く保守性の低くなってしまいます。

複数人で開発を行っている場合は特に、記載する場所と目的を明確にし統一したルールで運用する必要があります。

### [ルール]
- 各優先度毎に同名の変数は設定しない。ただし、同一優先度で同名の変数を利用し汎用性を高める記載方法で使う場合は問題ない
  - 理由: 上書きできるが優先度考えて構成を理解することは不可能

- varsを設定する場合、一番優先度の低い箇所に記載することを考える

### [記載場所について]
#### 優先度低1. group_vars/all.yml
```
[判断基準]
- 全ての環境(ステージ)に適用: ○
- 全てのホストに対して適用: ○

[記載例]
- 全ての環境にインストールしたいパッケージ ARRAY_COMMON_INSALLED_PACKAGES
- 全ての環境に作りたいディレクトリ ARRAY_COMMON_MKDIRS
- 全ての環境に作りたいユーザ ARRAY_COMMON_USERS
```

#### 優先度低2. group_vars/[HOSTGROUP].yml
```
[判断基準]
- 全ての環境(ステージ)に適用: ○
- 全てのホストに対して適用: ×(特定のホスト群に対して適用)

[記載例]
- WEBサーバ群に対して適用したいパッケージ ARRAY_HOSTGROUP_INSTALL_PACKAGES
- WEBサーバ群のApacheのドキュメントルート DIR_HTTPD_DOCUMENT_ROOT
```

#### 優先度低3. inventories/[STAGE]/group_vars/all.yml
```
[判断基準]
- 全ての環境(ステージ)に適用: ×(特定のステージに対して適用)
- 全てのホストに対して適用: ○

[記載例]
- ZABBIXサーバのIP IPADDRESS_ZABBIX_SERVER
```
