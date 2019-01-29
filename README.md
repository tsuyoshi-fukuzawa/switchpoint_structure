# SwitchPointStructure

switchpointを使った複数DB構成に接続するrailsの構築例。

MasterDB: master/slave

AnotherDB: master/slave

(垂直分割+master/slave構成)

# 構築方法

## 初期設定ファイル

- [config/initializers/switch_point.rb](https://github.com/tsuyoshi-fukuzawa/switchpoint_structure/blob/master/config/initializers/switch_point.rb)

1. MasterとSlaveをそれぞれ登録する
2. DBを垂直分割する場合は、mainとanotherのように、名前を分けて登録する
3. test環境は、Switchpointのconnectionを使わず、ActiveRecord::Baseを使うようにモンキーパッチを無効化する。(DatabaseCleanerがうまく動作しないため)

## モデルのルートクラス

- [app/models/application_record.rb](https://github.com/tsuyoshi-fukuzawa/switchpoint_structure/blob/master/app/models/application_record.rb)

1. デフォルトで書き込みにする。

```
SwitchPoint.writable!(:main)
```

2.垂直分割をする場合は、ActiveRecordを継承した親クラス(application_record)を分ける

dog系はApplicationRecord、cat系はApplicationRecordAnotherというように。

例: [application_record_cat.rb](https://github.com/tsuyoshi-fukuzawa/switchpoint_structure/blob/master/app/models/application_record_cat.rb)


## コントローラのルートクラス

- [app/controllers/application_controller.rb](https://github.com/tsuyoshi-fukuzawa/switchpoint_structure/blob/master/app/controllers/application_controller.rb)

1.around_actionを指定するとREAD側へ振れるようにする。

with_readonlyの共通メソッドをつくり、controllerでaround_actionでそのreadonlyメソッドを呼ぶ。

これで、controller単位でreadonly側からselectできるようになる。
なお、controllerでreadonlyを指定した場合は、メドッド内にwith_writableブロックが無い限り、
viewでの読み込みや、アソシエーションも全てreadonly側になる。

## 挙動について

### Readonly

別DBのreadonlyを同時に使いたい場合は、以下のように二重で張ることで対応できる

```
ApplicationRecord.with_readonly do
  ApplicationRecordAnother.with_readonly do
    
  end
end

```

### Transaction

transactionを張る場合は、with_writableと、transactionが同時に生成されるtransaction_withを使うことを推奨。

```
ApplicationRecord.transaction_with do
  xxxx.save!
end
```

## Logger

gem 'arproxy'を使い、ログファイルに接続先のDBと、Read/Writeの情報を出す

- [lib/switch_point_logger_enhancement.rb](https://github.com/tsuyoshi-fukuzawa/switchpoint_structure/blob/master/lib/switch_point_logger_enhancement.rb)
- [config/initializers/arproxy.rb](https://github.com/tsuyoshi-fukuzawa/switchpoint_structure/blob/master/config/initializers/arproxy.rb)

出力例
```
DogParent Load [dog][writable] (78.1ms)  SELECT  `dog_parents`.* FROM `dog_parents` WHERE `dog_parents`.`id` = 1 LIMIT 1
```

# 構築後の手順

構築が完了した後は、以下の手順で、slave側へ処理を逃すことや、垂直分割した別DBヘ接続することができる。

## Readonlyへ処理を移す

- [app/controllers/dogs_controller.rb](https://github.com/tsuyoshi-fukuzawa/switchpoint_structure/blob/master/app/controllers/dogs_controller.rb)

Slaveへ接続したいcontrollerの先頭に、以下を記述する

```
around_action :with_readonly, except: []
```

## 分割したDBへ接続する

- [cat_parentモデル](https://github.com/tsuyoshi-fukuzawa/switchpoint_structure/blob/e32fe30274414bcbbf35787cf913e198eacc87e9/app/models/cat_parent.rb#L1)
- [cat_childモデル](https://github.com/tsuyoshi-fukuzawa/switchpoint_structure/blob/e32fe30274414bcbbf35787cf913e198eacc87e9/app/models/cat_child.rb#L1)

Modelの継承元を、application_recordから変更する

# DB migration

## 設定

[lib/tasks/db_another.rake](https://github.com/tsuyoshi-fukuzawa/switchpoint_structure/blob/master/lib/tasks/db_another.rake)

## コマンド

### MAIN DBの操作

DBの作成
```
bundle exec rake db:create
```

DBの削除
```
bundle exec rake db:drop
```

DBの更新
```
bundle exec rake db:migrate
```

### Another DB

DBの作成
```
bundle exec rake another:db:create
```

DBの削除
```
bundle exec rake another:db:drop
```

DBの更新
```
bundle exec rake another:db:migrate
```

# Deploy

capistranoのタスクを追加し、deploy:migrationのafterで動作するようにする

lib/capistrano/tasks/another.rake

## コマンド

### migration

cap production deploy

### rollback

cap production another:db:rollback