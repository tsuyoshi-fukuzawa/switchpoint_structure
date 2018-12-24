# SwitchPointStructure

## 構成

MasterDB: master/slave

AnotherDB: master/slave

(垂直分割+master/slave構成)

## 構築方法

### 初期設定ファイル

[config/initializers/switch_point.rb](https://github.com/tsuyoshi-fukuzawa/switchpoint_structure/blob/master/config/initializers/switch_point.rb)

1. MasterとSlaveをそれぞれ登録する
2. DBを垂直分割する場合は、mainとanotherのように、名前を分けて登録する
3. Rspecのために、testの場合はreadonlyを消す
  readonlyの設定を消すと、with_readonlyブロックで囲われても、writableに接続できる

### モデルのルートクラス

[app/models/application_record.rb](https://github.com/tsuyoshi-fukuzawa/switchpoint_structure/blob/master/app/models/application_record.rb)

1.application_recordに対してデフォルトで書き込みにする。

```
SwitchPoint.writable!(:main)
```

2. 垂直分割をする場合は、ActiveRecordを継承した親クラス(application_record)を分ける

dog系はapplication_record、cat系はapplication_record_catというように。

例: [application_record_cat.rb](https://github.com/tsuyoshi-fukuzawa/switchpoint_structure/blob/master/app/models/application_record_cat.rb)


### コントローラのルートクラス

[app/controllers/application_controller.rb](https://github.com/tsuyoshi-fukuzawa/switchpoint_structure/blob/master/app/controllers/application_controller.rb)

1.around_actionを指定するとREAD側へ触れるようにする

with_readonlyの共通メソッドをつくり、controllerでaround_actionでそのreadonlyメソッドを呼ぶ。

これで、controller単位でreadonly側からselectできるようになる。

なお、controllerでreadonlyを指定した場合は、メドッド内にwith_writableブロックが無い限り、
viewでの読み込みや、アソシエーションも全てreadonly側になる。

### Logger

gem 'arproxy'を使い、ログファイルに接続先のDBと、Read/Writeの情報を出す

[lib/switch_point_logger_enhancement.rb](https://github.com/tsuyoshi-fukuzawa/switchpoint_structure/blob/master/lib/switch_point_logger_enhancement.rb)

[config/initializers/arproxy.rb](https://github.com/tsuyoshi-fukuzawa/switchpoint_structure/blob/master/config/initializers/arproxy.rb)

出力例
```
DogParent Load [dog][writable] (78.1ms)  SELECT  `dog_parents`.* FROM `dog_parents` WHERE `dog_parents`.`id` = 1 LIMIT 1
```

## 構築後の手順

構築が完了した後は、以下の手順で、slave側へ処理を逃すことや、垂直分割した別DBヘ接続することができる。

### Readonlyへ処理を移す

Slaveへ接続したいcontrollerの先頭に、以下を記述する

```
around_action :with_readonly, except: []
```

【例】

[app/controllers/dogs_controller.rb](https://github.com/tsuyoshi-fukuzawa/switchpoint_structure/blob/master/app/controllers/dogs_controller.rb)


### 分割したDBへ接続する

Modelの継承元を、application_recordから変更する

【例】

[cat_parentモデル](https://github.com/tsuyoshi-fukuzawa/switchpoint_structure/blob/e32fe30274414bcbbf35787cf913e198eacc87e9/app/models/cat_parent.rb#L1)

[cat_childモデル](https://github.com/tsuyoshi-fukuzawa/switchpoint_structure/blob/e32fe30274414bcbbf35787cf913e198eacc87e9/app/models/cat_child.rb#L1)


## DB管理 (migrationなど)

### パターン

垂直分割する場合、migration等の運用手順が増える。

その際、migrationを行う方法として、以下の手段が考えられる。


#### 方法1. 擬似的に垂直分割する

同じテーブル構成のmasterDBを複数台用意し、使用するテーブルを振り分けて使う。

(例：片方をメインテーブル、もう片方を認証系データのみというように)

開発環境に影響を与えず、かつ本番DBのmigrationをあまり設定に手を加えずに運用できるのがメリット。

ただ、本番DBにトラブルが起きた時や、振り分けミスが発生した際は、リカバリが非常につらい。

#### 方法2. 別のrakeタスクを用意する

別DBに接続するrakeタスクを作成する。設定ファイル類も全て別のものを用意する(migrateファイル、database.ymlなど)

その上でデブロイ時にこれらのrakeタスクが実行されるようにする。

ただし、別DBにデプロイした本番dbのrollbackは手動で行う必要があるなど、トラブル時にリカバリがつらい。

開発時も、別のrakeタスクでコントロールするなど、少し開発体制の変更が必要。

このstructureサンプルでは、この方法2を適用するが、本番dbへのdeployについては考慮をしていない。

#### 方法3. 別のrailsを立ち上げて、そこでDBは管理する

開発が別レポジトリになり開発の手間が増えるものの、

運用としては一番シンプルで、運用難度が低いのがメリット。


### 設定

lib/tasks/db_another.rake

### コマンド

#### MAIN DBの操作

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

#### Another DB

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

