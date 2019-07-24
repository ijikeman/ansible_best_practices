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

ルール
- 同名の変数は設定しない。
  - 上書きできるが優先度考えて構成を理解することは不可能
-
### 記載場所について
1. varsを設定する場合、一番優先度の低い箇所に記載することを考える
#### 1. group_vars/all.yml ... 一番優先度が低い
```
[判断基準]
- 全ての環境(ステージ)に適用する必要がある
- 全てのホストに対して適用する必要がある

[記載例]
- 全ての環境にインストールしたいパッケージ ARRAY_COMMON_INSALLED_PACKAGES
- 全ての環境に作りたいディレクトリ ARRAY_COMMON_MKDIRS
- 全ての環境に作りたいユーザ ARRAY_COMMON_USERS
```

```

#### 2.group_vars/webserver.yml ... 2番目に優先度が低い
```
[判断基準]
- 全ての環境(ステージ)に適用する必要がある
- 特定のホスト群に対して適用する必要がある

[記載例]
- 特定のホスト群に対して適用したいパッケージ ARRAY_WEBSERVER_PACKAGES
```


2.
