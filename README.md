# gem: switch_pointの挙動確認

## DB構成

DB1: master/slave

DB2: master/slave

垂直分割 + master/slave構成

## 設定のポイント

### config/initializers/switch_point.rb

- rspecのために、testの場合はreadonlyを消す

readonlyの設定が無い場合、with_readonlyブロックで囲われても、writableに接続される

- DBを垂直分割する場合は、ここで別のswitch_point名を登録する(dog系とcat系のように)

### app/models/application_record.rb

- 垂直分割をする場合は、ActiveRecordを継承した親クラス(application_record)を分ける

dog系はapplication_record、cat系はapplication_record_catというように。

- application_recordに対してデフォルト設定を与える

DB接続先(use_switch_point)と、書き込み(writable!)をデフォルトにする

### app/controllers/application_controller.rb

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
例: app/controllers/dogs_controller.rb


## [手順] DBを分割する場合

- 別DBに分割するmodelの継承元を、application_recordから変更する

