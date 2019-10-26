# Ansible Best Practiceを元によりより汎用性を高めた構成で作っております
# コーディング規約

# Discription Directories
```
group_vars/
  all.yml ... 優先度低1 varsファイル(命名規則: COMMON_*)
  [HOSTGROUP].yml ... 優先度低2 varsファイル(命名規則: COMMON_HOSTGROUP_*)
  ...

inventories/ - インベントリ(サーバリスト)と環境毎の設定値
  production/ - 本番環境
    hosts - インベントリファイル
    group_vars/
      all.yml - 優先度低3 varsファイル(命名規則: INVENTORY_*)
      [HOSTGROUP].yml - 優先度低4 varsファイル(命名規則: INVENTORY_HOSTGROUP_*)
  staging/ - ステージング環境
  development/ - 開発環境
  docker/ - テスト用Docker環境
roles/
  common_tasks/ - 他のロールから呼ばれる汎用的なタスクリスト
  common/ - 全てのホストで共通で実行するタスク
  [role_name]/ - 各種ロール。フォルダ名はミドルウェア名単位が好ましい
  template_basic_role/ - テンプレートロール
    defaults/ - 使わない(上書き可能なデフォルトの値)
    files/ - タスク内で使用するシェルなど
    handlers/ - notifyで呼び出す処理を記載
    meta/ - 各roleとの依存関係の記述
    tasks/ - タスク一覧
      main.yml - roleを指定するとデフォルトで呼ばれるタスク
      install.yml - インストール処理(main.ymlからincludeとして呼ばれる)
      setup.yml - 設定処理(main.ymlからincludeとして呼ばれる)
ansible.cfg - Ansible設定ファイル
[playbook].yml - 各Playbook
```

# Discription Basic Role
### [説明]
- OSの種別やバージョンを考慮しない基本的な構成となります。
- このテンプレートはDaemonを扱うロールとなります

### [構成]
```
template_basic_role/
  files/
  handlers/
    main.yml - 起動、停止、再起動、リロードを行うハンドラが実装されています（基本的に変更不要)
  tasks/
    main.yml - install.yml及びsetup.ymlをincludeしています（基本的に変更不要)
    install.yml - パッケージのインストール処理を記載します
    setup.yml - 設定ファイルの設置などを記載します
  templates/
  vars/
    main.yml - 操作するデーモン名(サービス名)を指定しています
```

### [使い方]
ここではtemplate_basic_roleをコピーしhttpdのrole作成する例を紹介します

- インストールするパッケージと操作するサービス名を指定
```
$ roles/httpd/vars/main.yml
---
NAME_DAEMON: 'httpd'
NAME_PACKAGE: 'httpd'
---
```

- 設定ファイル設置時にReload実行されるように変更
```
$ roles/httpd/tasks/setup.yml
---
- name: Setup Config
  template:
    src: httpd.conf.j2
    dest: /etc/httpd/conf/httpd.conf
    owner: apache
    group: apache
    mode: 0644
  notify: "{{ NAME_SERVICE_MANAGER }} Restarted {{ NAME_DAEMON }}"
---
```

# Discription Advanced Role
### [説明]
- OSの種別やバージョンを考慮した構成となります
- このテンプレートはDaemonを扱うロールとなります

```
template_advanced_role/
  files/
  handlers/
  tasks/
    main.yml - 各環境に応じたvarsの読み込み, install.yml及びsetup.ymlをincludeしています（基本的に変更不要)
    install.yml - 各環境に応じたinstall_.ymlをincludeしています
    install_RedHat_6.yml - RedHat6系の場合のinstall処理を記載します
    install_RedHat_7.yml - RedHat7系の場合のinstall処理を記載します
    install_Debian_6.yml - Debian系の場合のinstall処理を記載します
    setup.yml - 各環境に応じたsetup_.ymlをincludeしています
    setup_RedHat_6.yml - RedHat6系の場合のsetup処理を記載します
    setup_RedHat_7.yml - RedHat7系の場合のsetup処理を記載します
    setup_Debian_6.yml - Debian系の場合のsetup処理を記載します
  templates/
    sample.conf.RedHat_6.j2 - 各環境に応じた設定ファイルを設置
    sample.conf.RedHat_7.j2
  vars/
    main.yml
    RedHat_6.yml - RedHat6系の場合のデーモン名(サービス名)や設定ファイルの設置場所を記載します
    RedHat_7.yml - RedHat7系の場合のデーモン名(サービス名)や設定ファイルの設置場所を記載します
    Debian_6.yml - Debian系の場合のデーモン名(サービス名)や設定ファイルの設置場所を記載します
```

ここではtemplate_advanced_roleをコピーしhttpdのrole作成する例を紹介します

- インストールするパッケージと操作するサービス名を指定
```
$ roles/httpd/vars/RedHat_6.yml
---
NAME_SERVICE_MANAGER: Service
NAME_DAEMON: httpd
NAME_PACKAGE: httpd
---
```

```
$ roles/httpd/vars/Debian_6.yml
---
NAME_PACKAGE: apache2
NAME_DAEMON: apache2
---
```

- 設定ファイル設置時にReload実行されるように変更
```
$ roles/httpd/tasks/setup_RedHat_6.yml
---
- name: Setup Config
  template:
    src: httpd.conf.j2
    dest: /etc/httpd/conf/httpd.conf
    owner: apache
    group: apache
    mode: 0644
  notify: "{{ NAME_SERVICE_MANAGER }} Restarted {{ NAME_DAEMON }}"
---
```

# Discription Vars
### [説明]
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
- 全ての環境にインストールしたいパッケージ COMMON_INSTALLED_PACKAGES
- 全ての環境に作りたいディレクトリ COMMON_MKDIRS
- 全ての環境に作りたいユーザ COMMON_USERS
```

#### 優先度低2. group_vars/[HOSTGROUP].yml
```
[判断基準]
- 全ての環境(ステージ)に適用: ○
- 全てのホストに対して適用: ×(特定のホスト群に対して適用)

[記載例]
- WEBサーバ群に対して適用したいパッケージ COMMON_HOSTGROUP_INSTALLED_PACKAGES
- WEBサーバ群のApacheのドキュメントルート HTTPD_SETTINGS.DOCUMENT_ROOT
```

#### 優先度低3. inventories/[STAGE]/group_vars/all.yml
```
[判断基準]
- 全ての環境(ステージ)に適用: ×(特定のステージに対して適用)
- 全てのホストに対して適用: ○

[記載例]
- 本番環境の全てのサーバに適用したいパッケージ INVENTORY_INSTALLED_PACKAGES
- ZABBIXサーバのIP IPADDRESS_ZABBIX_SERVER
```

#### 優先度低4. inventories/[STAGE]/group_vars/[HOSTGROUP].yml
```
[判断基準]
- 全ての環境(ステージ)に適用: ×(特定のステージに対して適用)
- 全てのホストに対して適用: ×(特定のホスト群に対して適用)

[記載例]
- 本番環境のWEBのサーバ群に適用したいパッケージ INVENTORY_HOSTGROUP_INSTALLED_PACKAGES
- ZABBIXサーバのIP IPADDRESS_ZABBIX_SERVER
```

#### 優先度低5. ホスト個別の値について(WEBサーバ群の中で1ホストだけ環境が違うなど)
```
各ステージ且つ各ホストグループよりもさらに細かい、各ホスト個別の値について方法は複数あるので紹介。
- 1. ホストグループを分ける
inventory/production/hosts
```
[web:children]
10.0.0.1
web2

[web2]
10.0.0.2
```

inventory/production/group_vars/web.yml
inventory/production/group_vars/web1.yml
を用意すると
web1.ymlの値が優先される

- 2. Dynamic Inventoryを利用する
