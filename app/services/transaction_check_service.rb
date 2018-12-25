class TransactionCheckService < ApplicationService
  # rails runnerから実行して確認することを想定
  # rspecは、テストデータのrollbackを考えると、master/slave、別DBのテストは不向き

  def initialize
  end

  # switchpointを入れても通常のロールバックには影響なし
  def self.check_rollback
    begin
      ApplicationRecord.transaction do
        dog_parent = DogParent.new
        dog_parent.name = 'コロ'
        dog_parent.save!
        dog_child = dog_parent.dog_children.build
        dog_child.name = 'ポチ'
        dog_child.save!
        raise
      end
    rescue => e
      self.check_dog_count
    end
  end

  # トランザクションの途中にリードオンリーを挟んでもロールバックは正常に実行される
  def self.check_rollback_once_read
    begin
      ApplicationRecord.transaction do
        dog_parent = DogParent.new
        dog_parent.name = 'コロ'
        dog_parent.save!
        master_dog_count = DogParent.all.size
        p master_dog_count
        ApplicationRecord.with_readonly do
          slave_dog_count = DogParent.all.size
          p slave_dog_count
        end
        dog_child = dog_parent.dog_children.build
        dog_child.name = 'ポチ'
        dog_child.save!
        raise
      end
    rescue => e
      self.check_dog_count
    end
  end

  # ネストした同一トランザクションは無視される(railsの仕様通り)
  def self.check_rollback_nested
    begin
      ApplicationRecord.transaction do
        dog_parent = DogParent.new
        dog_parent.name = 'コロ'
        dog_parent.save!

        begin
          ApplicationRecord.transaction do
            dog_child = dog_parent.dog_children.build
            dog_child.name = 'ポチ'
            dog_child.save!
            raise
          end
        rescue => e
          p "ネスト完了"
          self.check_dog_count
        end
        raise
      end
    rescue => e
      self.check_dog_count
    end
  end

  # 別DBの処理をメインのトランザクションで扱ってもエラーにはならず別DBの値は保存できる
  def self.check_rollback_mix
    begin
      ApplicationRecord.transaction do
        dog_parent = DogParent.new
        dog_parent.name = 'コロ'
        dog_parent.save!

        cat_parent = CatParent.new
        cat_parent.name = 'タマ'
        cat_parent.save!
      end
    rescue => e
      p "ここには来ません"
    end
    self.check_dog_count
    self.check_cat_count
  end

  # 別DBの処理を、違うDBのトランザクションで扱ってもロールバックできない
  def self.check_rollback_mix_raise
    begin
      ApplicationRecord.transaction do
        dog_parent = DogParent.new
        dog_parent.name = 'コロ'
        dog_parent.save!

        cat_parent = CatParent.new
        cat_parent.name = 'タマ'
        cat_parent.save!

        raise
      end
    rescue => e
      p "犬はロールバックされますが"
      self.check_dog_count
      p "猫はロールバックされていません"
      self.check_cat_count
    end
  end

  # MainDBのトランザクションの中に、AnotherDBのトランザクションを入れて、それぞれロールバックすることができます。
  def self.check_rollback_nested_another_transaction
    begin
      ApplicationRecord.transaction do
        dog_parent = DogParent.new
        dog_parent.name = 'コロ'
        dog_parent.save!

        begin
          ApplicationRecordAnother.transaction do
            cat_parent = CatParent.new
            cat_parent.name = 'タマ'
            cat_parent.save!
            raise
          end
        rescue => e
          p "別DBの猫系だけrollback成功"
          self.check_cat_count
        end

        raise
      end
    rescue => e
      p "メインDBの犬系だけrollback成功"
      self.check_dog_count
    end
  end

  private

  def self.check_dog_count
    p ({ dog_parent: DogParent.all.size, dog_child: DogChild.all.size })
  end

  def self.check_cat_count
    p ({ cat_parent: CatParent.all.size, cat_child: CatChild.all.size })
  end

end
