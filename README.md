# gem: switch_pointの挙動確認

## DB構成

DB1: master/slave

DB2: master/slave

垂直分割 + master/slave構成

## 設定のポイント

### [config/initializers/switch_point.rb](https://github.com/tsuyoshi-fukuzawa/switchpoint_structure/blob/master/config/initializers/switch_point.rb)

- rspecのために、testの場合はreadonlyを消す

→ readonlyの設定が無い場合、with_readonlyブロックで囲われても、writableに接続される

- DBを垂直分割する場合は、ここで別のswitch_point名を登録する(dog系とcat系のように)

### [app/models/application_record.rb](https://github.com/tsuyoshi-fukuzawa/switchpoint_structure/blob/master/app/models/application_record.rb)

- 垂直分割をする場合は、ActiveRecordを継承した親クラス(application_record)を分ける

→ dog系はapplication_record、cat系はapplication_record_catというように。
→ 例: [application_record_cat.rb](https://github.com/tsuyoshi-fukuzawa/switchpoint_structure/blob/master/app/models/application_record_cat.rb)

- application_recordに対してデフォルト設定を与える

→ DB接続先(use_switch_point)と、書き込み(writable!)をデフォルトにする

### [app/controllers/application_controller.rb](https://github.com/tsuyoshi-fukuzawa/switchpoint_structure/blob/master/app/controllers/application_controller.rb)

- with_readonlyの共通メソッドをつくる

controller単位で、必要に応じてreadonly側からselectできるようになる。

## 上記の設定をした場合の挙動

- デフォルトはmasterへread/writeが走る
- controllerで"around_action :with_readonly"を指定した場合のみ、そのコントローラとviewがslave側から読み込まれる。

## [手順] Slave側へ処理を移す場合

- Slaveへ接続したいcontrollerの先頭に、以下を記述する
```
around_action :with_readonly, except: []
```
例: [app/controllers/dogs_controller.rb](https://github.com/tsuyoshi-fukuzawa/switchpoint_structure/blob/master/app/controllers/dogs_controller.rb)


## [手順] DBを分割する場合

- 別DBに分割するmodelの継承元を、application_recordから変更する

例: 

- [cat_parentモデル](https://github.com/tsuyoshi-fukuzawa/switchpoint_structure/blob/e32fe30274414bcbbf35787cf913e198eacc87e9/app/models/cat_parent.rb#L1)

- [cat_childモデル](https://github.com/tsuyoshi-fukuzawa/switchpoint_structure/blob/e32fe30274414bcbbf35787cf913e198eacc87e9/app/models/cat_child.rb#L1)

## Logger
gem 'arproxy'を使い、ログファイルに接続先のDBと、Read/Writeの情報を出す

出力例
```
DogParent Load [dog][writable] (78.1ms)  SELECT  `dog_parents`.* FROM `dog_parents` WHERE `dog_parents`.`id` = 1 LIMIT 1
```

### Logger設定方法
- [lib/switch_point_logger_enhancement.rb](https://github.com/tsuyoshi-fukuzawa/switchpoint_structure/blob/master/lib/switch_point_logger_enhancement.rb)

- [config/initializers/arproxy.rb](https://github.com/tsuyoshi-fukuzawa/switchpoint_structure/blob/master/config/initializers/arproxy.rb)

