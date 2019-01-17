require 'rails_helper'

#
# TESTで使用するDBをMainとAnotherに分けること
#
RSpec.describe DogParent do
  before(:each) do
    @rescued = false
  end

  describe '複数DBのトランザクション(main: master, another: master)' do

    describe 'トランザクションを一つ張る場合、他方のDBはロールバックできない' do

      it 'Main(犬)からTransactionWithを張った場合は、Another(猫)はロールバックできない' do
        begin
          ApplicationRecord.transaction_with do
            inu = DogParent.new
            inu.save!

            koinu = DogChild.new
            koinu.save!

            neko = CatParent.new
            neko.save!

            koneko = CatChild.new
            koneko.save!

            expect(DogParent.all.size).to eq(1)
            expect(DogChild.all.size).to eq(1)
            expect(CatParent.all.size).to eq(1)
            expect(CatChild.all.size).to eq(1)
            raise 'rollback'
          end
        rescue => e
          @rescued = true
          expect(e.to_s).to eq('rollback')
        end
        expect(@rescued).to eq(true)
        expect(DogParent.all.size).to eq(0)
        expect(DogChild.all.size).to eq(0)
        expect(CatParent.all.size).to eq(1)
        expect(CatChild.all.size).to eq(1)
      end

      it 'Another(猫)からTransactionWithを張った場合は、Main(犬)はロールバックされない' do
        begin
          ApplicationRecordAnother.transaction_with do
            inu = DogParent.new
            inu.save!

            koinu = DogChild.new
            koinu.save!

            neko = CatParent.new
            neko.save!

            koneko = CatChild.new
            koneko.save!

            expect(DogParent.all.size).to eq(1)
            expect(DogChild.all.size).to eq(1)
            expect(CatParent.all.size).to eq(1)
            expect(CatChild.all.size).to eq(1)
            raise 'rollback'
          end
        rescue => e
          @rescued = true
          expect(e.to_s).to eq('rollback')
        end
        expect(@rescued).to eq(true)
        expect(DogParent.all.size).to eq(1)
        expect(DogChild.all.size).to eq(1)
        expect(CatParent.all.size).to eq(0)
        expect(CatChild.all.size).to eq(0)
      end

      it 'ActiveRecord::BaseからTransactionWithを張った場合は、その瞬間エラーになる' do
        begin
          ActiveRecord::Base.transaction_with do
          end
        rescue => e
          @rescued = true
          expect(e.to_s).to eq("ActiveRecord::Base isn't configured to use switch_point")
        end
        expect(@rescued).to eq(true)
      end

      it 'ActiveRecord::BaseからTransaction(Withなし)を張った場合は、ロールバックできず、悲惨なことになる' do
        begin
          ActiveRecord::Base.transaction do
            inu = DogParent.new
            inu.save!

            koinu = DogChild.new
            koinu.save!

            neko = CatParent.new
            neko.save!

            koneko = CatChild.new
            koneko.save!

            expect(DogParent.all.size).to eq(1)
            expect(DogChild.all.size).to eq(1)
            expect(CatParent.all.size).to eq(1)
            expect(CatChild.all.size).to eq(1)
            raise 'rollback'
          end
        rescue => e
          @rescued = true
          expect(e.to_s).to eq('rollback')
        end
        expect(@rescued).to eq(true)
        expect(DogParent.all.size).to eq(1)
        expect(DogChild.all.size).to eq(1)
        expect(CatParent.all.size).to eq(1)
        expect(CatChild.all.size).to eq(1)
      end

      it 'Main(犬)からTransaction(Withなし)を張った場合は、TransactionWithと同じ挙動だが、Another(猫)はロールバックできない' do
        # defaultがwritableになっているため同じ挙動になる。ただし、後述するreadonly内にtransactionを張った場合、with無しだとエラーになるので、transaction(with無し)は使用すべきではない
        begin
          ApplicationRecord.transaction do
            inu = DogParent.new
            inu.save!

            koinu = DogChild.new
            koinu.save!

            neko = CatParent.new
            neko.save!

            koneko = CatChild.new
            koneko.save!

            expect(DogParent.all.size).to eq(1)
            expect(DogChild.all.size).to eq(1)
            expect(CatParent.all.size).to eq(1)
            expect(CatChild.all.size).to eq(1)
            raise 'rollback'
          end
        rescue => e
          @rescued = true
          expect(e.to_s).to eq('rollback')
        end
        expect(@rescued).to eq(true)
        expect(DogParent.all.size).to eq(0)
        expect(DogChild.all.size).to eq(0)
        expect(CatParent.all.size).to eq(1)
        expect(CatChild.all.size).to eq(1)
      end
    end

    describe 'トランザクションをネストさせる場合' do

      before(:each) do
        @rescued_nested = false
      end

      it '同じDBに二重のトランザクションを張るとRails本来の挙動' do
        # Railsの挙動通り、内部が無視される
        begin
          ApplicationRecord.transaction_with do
            inu = DogParent.new
            inu.save!

            begin
              ApplicationRecord.transaction_with do
                koinu = DogChild.new
                koinu.save!
                raise 'nestedはrollbackされない'
              end
            rescue => e
              expect(DogParent.all.size).to eq(1)
              expect(DogChild.all.size).to eq(1)
              @rescued_nested = true
              expect(e.to_s).to eq("nestedはrollbackされない")
            end
            expect(DogParent.all.size).to eq(1)
            expect(DogChild.all.size).to eq(1)
            raise 'ここでrollbackされる'
          end
        rescue => e
          expect(DogParent.all.size).to eq(0)
          expect(DogChild.all.size).to eq(0)
          @rescued = true
          expect(e.to_s).to eq("ここでrollbackされる")
        end
        expect(@rescued_nested).to eq(true)
        expect(@rescued).to eq(true)
        expect(DogParent.all.size).to eq(0)
        expect(DogChild.all.size).to eq(0)
      end


      it '両方のDBにネストでトランザクションを張り、内部、外部、それぞれロールバックしたときは、それぞれがロールバックされる' do
        begin
          ApplicationRecord.transaction_with do
            inu = DogParent.new
            inu.save!

            begin
              ApplicationRecordAnother.transaction_with do
                neko = CatParent.new
                neko.save!
                expect(CatParent.all.size).to eq(1)
                raise '別DBがrollbackされる'
              end
            rescue => e
              expect(DogParent.all.size).to eq(1)
              expect(CatParent.all.size).to eq(0)
              @rescued_nested = true
              expect(e.to_s).to eq("別DBがrollbackされる")
            end
            expect(DogParent.all.size).to eq(1)
            expect(CatParent.all.size).to eq(0)
            raise 'ここでメインDBがrollbackされる'
          end
        rescue => e
          expect(DogParent.all.size).to eq(0)
          expect(CatParent.all.size).to eq(0)
          @rescued = true
          expect(e.to_s).to eq("ここでメインDBがrollbackされる")
        end
        expect(@rescued_nested).to eq(true)
        expect(@rescued).to eq(true)
        expect(DogParent.all.size).to eq(0)
        expect(CatParent.all.size).to eq(0)
      end

      it '両方のDBにネストで一気にトランザクションを張ると、理想に近い、同時のロールバックができる' do
        begin
          ApplicationRecord.transaction_with do
            ApplicationRecordAnother.transaction_with do
              inu = DogParent.new
              inu.save!
              neko = CatParent.new
              neko.save!
              expect(DogParent.all.size).to eq(1)
              expect(CatParent.all.size).to eq(1)
              raise '一気にrescueへ'
            end
          end
        rescue => e
          expect(DogParent.all.size).to eq(0)
          expect(CatParent.all.size).to eq(0)
          @rescued = true
          expect(e.to_s).to eq("一気にrescueへ")
        end
        expect(@rescued).to eq(true)
        expect(DogParent.all.size).to eq(0)
        expect(CatParent.all.size).to eq(0)
      end

      it '両方のDBにネストでトランザクションを張り、内部だけロールバックしたとき、内部だけロールバックされる。' do
        ApplicationRecord.transaction_with do
          inu = DogParent.new
          inu.save!

          begin
            ApplicationRecordAnother.transaction_with do
              neko = CatParent.new
              neko.save!
              expect(CatParent.all.size).to eq(1)
              raise '別DBだけrollbackする'
            end
          rescue => e
            expect(DogParent.all.size).to eq(1)
            expect(CatParent.all.size).to eq(0)
            @rescued_nested = true
            expect(e.to_s).to eq("別DBだけrollbackする")
          end
          expect(DogParent.all.size).to eq(1)
          expect(CatParent.all.size).to eq(0)
        end
        expect(@rescued_nested).to eq(true)
        expect(@rescued).to eq(false)
        expect(DogParent.all.size).to eq(1)
        expect(CatParent.all.size).to eq(0)
      end

      it '両方のDBにネストでトランザクションを張り、外部だけロールバックしたときは、外部だけロールバックされる' do
        begin
          ApplicationRecord.transaction_with do
            inu = DogParent.new
            inu.save!

            ApplicationRecordAnother.transaction_with do
              neko = CatParent.new
              neko.save!
              expect(CatParent.all.size).to eq(1)
            end

            expect(DogParent.all.size).to eq(1)
            expect(CatParent.all.size).to eq(1)
            raise 'メインDBだけrollbackする'
          end
        rescue => e
          expect(DogParent.all.size).to eq(0)
          expect(CatParent.all.size).to eq(1)
          @rescued = true
          expect(e.to_s).to eq("メインDBだけrollbackする")
        end
        expect(@rescued_nested).to eq(false)
        expect(@rescued).to eq(true)
        expect(DogParent.all.size).to eq(0)
        expect(CatParent.all.size).to eq(1)
      end
    end

    describe 'TransactionWithの引数にモデル名を入れる用法は、RootClassでuse_switchpointを定義するパターンでは使えない' do
      # つまりtransaction_withの引数には何も入れられない

      it '同じDBなのに、チェックが失敗してしまう' do
        # ApplicationRecord -> use switchpointを宣言 = Mainと判別される
        # DogParent -> ApplicationRecordを継承しており、モデル内ではuse switchpointを宣言していない = nilと判別
        # DogChild  -> ApplicationRecordを継承しており、モデル内ではuse switchpointを宣言していない = nilと判別
        begin
          ApplicationRecord.transaction_with(DogParent, DogChild) do
          end
        rescue => e
          @rescued = true
          # Mainとnilで不一致になるのでエラーになってしまう
          expect(e.to_s).to eq("switch_point's model names must be consistent")
        end
        expect(@rescued).to eq(true)
        expect(DogParent.all.size).to eq(0)
        expect(DogChild.all.size).to eq(0)
      end

      it '違うDBなのにチェックが通ってしまう' do
        begin
          DogParent.transaction_with(CatParent) do
            inu  = DogParent.new
            inu.save!
            neko = CatParent.new
            neko.save!
            raise 'rollback'
          end
        rescue => e
          @rescued = true
          expect(e.to_s).to eq('rollback')
        end
        expect(@rescued).to eq(true)
        expect(DogParent.all.size).to eq(0)
        expect(CatParent.all.size).to eq(1)
      end
    end
  end

  describe 'ReadonlyとTransaction (main: master/slave, another: 未使用)' do

    it 'Readonlyの中にトランザクションがある場合はWritableになる' do
      # Transaction_withの中で、with_writableが呼ばれているから
      begin
        ApplicationRecord.with_readonly do
          ApplicationRecord.transaction_with do
            inu = DogParent.new
            inu.save!

            koinu = DogChild.new
            koinu.save!

            expect(DogParent.all.size).to eq(1)
            expect(DogChild.all.size).to eq(1)
            raise 'rollback'
          end
        end
      rescue => e
        @rescued = true
        expect(e.to_s).to eq('rollback')
      end
      expect(@rescued).to eq(true)
      expect(DogParent.all.size).to eq(0)
      expect(DogChild.all.size).to eq(0)
    end

    it 'トランザクションの中にReadonlyを入れるとsave(!)でエラーになる' do
      begin
        ApplicationRecord.transaction_with do
          ApplicationRecord.with_readonly do
            inu = DogParent.new
            inu.save
          end
        end
      rescue => e
        @rescued = true
        expect(e.to_s).to eq('main is readonly, but destructive method insert is called')
      end
      expect(@rescued).to eq(true)
      expect(DogParent.all.size).to eq(0)
      expect(DogChild.all.size).to eq(0)
    end

    it 'Readonlyの中にトランザクション(Withなし)がある場合はエラーになる' do
      # つまりtransaction_withを使うのが一番安全
      begin
        ApplicationRecord.with_readonly do
          ApplicationRecord.transaction do
            inu = DogParent.new
            inu.save!
          end
        end
      rescue => e
        @rescued = true
        expect(e.to_s).to eq('main is readonly, but destructive method insert is called')
      end
      expect(@rescued).to eq(true)
      expect(DogParent.all.size).to eq(0)
      expect(DogChild.all.size).to eq(0)
    end

    it '(念のため)犬Readonlyの中に猫トランザクションがある場合は、当然、猫トランザクションには影響がない' do
      begin
        ApplicationRecord.with_readonly do
          ApplicationRecordAnother.transaction_with do
            neko = CatParent.new
            neko.save!

            koneko = CatChild.new
            koneko.save!

            expect(CatParent.all.size).to eq(1)
            expect(CatChild.all.size).to eq(1)
            raise 'rollback'
          end
        end
      rescue => e
        @rescued = true
        expect(e.to_s).to eq('rollback')
      end
      expect(@rescued).to eq(true)
      expect(CatParent.all.size).to eq(0)
      expect(CatChild.all.size).to eq(0)
    end

  end

  describe 'ReadonlyとReadonly (main: slave, another: slave)' do
    # 両方ともReadonlyで囲めば、両方ともReadonlyになる。

    it 'Readonlyの中に別DBのReadonlyを入れる' do
      # anotherはswitch_pointがnull

      dog_config = DogParent.connection.pool.spec.config
      cat_config = CatParent.connection.pool.spec.config

      expect(dog_config[:switch_point][:name]).to eq(:main)
      expect(dog_config[:switch_point][:mode]).to eq(:writable)
      expect(cat_config[:switch_point][:name]).to eq(:another)
      expect(cat_config[:switch_point][:mode]).to eq(:writable)

      ApplicationRecord.with_readonly do

        dog_config = DogParent.connection.pool.spec.config
        cat_config = CatParent.connection.pool.spec.config

        expect(dog_config[:switch_point][:name]).to eq(:main)
        expect(dog_config[:switch_point][:mode]).to eq(:readonly)
        expect(cat_config[:switch_point][:name]).to eq(:another)
        expect(cat_config[:switch_point][:mode]).to eq(:writable)

        ApplicationRecordAnother.with_readonly do

          dog_config = DogParent.connection.pool.spec.config
          cat_config = CatParent.connection.pool.spec.config

          expect(dog_config[:switch_point][:name]).to eq(:main)
          expect(dog_config[:switch_point][:mode]).to eq(:readonly)
          expect(cat_config[:switch_point][:name]).to eq(:another)
          expect(cat_config[:switch_point][:mode]).to eq(:readonly)

        end
      end
    end
  end

  describe 'After Create' do
    # 子犬の名前を'AFTER CREATE TEST'とすると、子猫が産まれる仕組みにしてある
    # class DogChild < ApplicationRecord
    #   ...
    #   after_create do
    #     if name == 'AFTER CREATE TEST'
    #       cat = CatChild.new
    #       cat.save!
    #     end
    #   end
    # end

    it '気がつかずTransactionをメインだけに張っていると、ロールバックできず、悲しい' do
      begin
        ApplicationRecord.transaction_with do
          inu = DogParent.new
          inu.save!
          koinu = DogChild.new(name: 'AFTER CREATE TEST')
          koinu.save!
          expect(DogParent.all.size).to eq(1)
          expect(DogChild.all.size).to eq(1)
          expect(CatChild.all.size).to eq(1)
          raise 'rollback'
        end
      rescue => e
        @rescued = true
        expect(e.to_s).to eq('rollback')
      end
      expect(@rescued).to eq(true)
      expect(DogParent.all.size).to eq(0)
      expect(DogChild.all.size).to eq(0)
      expect(CatChild.all.size).to eq(1)
    end

    it 'ダブルでTransactionを張っていれば、ロールバックされる' do
      begin
        ApplicationRecord.transaction_with do
          ApplicationRecordAnother.transaction_with do
            inu = DogParent.new
            inu.save!
            koinu = DogChild.new(name: 'AFTER CREATE TEST')
            koinu.save!
            expect(DogParent.all.size).to eq(1)
            expect(DogChild.all.size).to eq(1)
            expect(CatChild.all.size).to eq(1)
            raise 'rollback'
          end
        end
      rescue => e
        @rescued = true
        expect(e.to_s).to eq('rollback')
      end
      expect(@rescued).to eq(true)
      expect(DogParent.all.size).to eq(0)
      expect(DogChild.all.size).to eq(0)
      expect(CatChild.all.size).to eq(0)
    end
  end

  describe 'After Commit' do
    # 子犬の名前を'AFTER COMMIT TEST'とすると、子猫が産まれる仕組みにしてある
    # そもそもAfterCommitでのDB操作は設計的におかしいので、トリガーのタイミングを調べる

    it '別DBのtransaction_withの完了で発動しないか確認する' do
      ApplicationRecordAnother.transaction_with do
        neko = CatParent.new
        neko.save!
        ApplicationRecord.transaction_with do
          koinu = DogChild.new(name: 'AFTER COMMIT TEST')
          koinu.save!
          expect(CatChild.all.size).to eq(0)
        end
        expect(CatChild.all.size).to eq(1)
      end
      expect(CatChild.all.size).to eq(1)
    end

    it '別DBのtransaction_withの完了で発動しないか確認する' do
      ApplicationRecord.transaction_with do
        koinu = DogChild.new(name: 'AFTER COMMIT TEST')
        koinu.save!
        ApplicationRecordAnother.transaction_with do
          neko = CatParent.new
          neko.save!
        end
        expect(CatChild.all.size).to eq(0)
      end
      expect(CatChild.all.size).to eq(1)
    end
  end

  describe '不整合パターン' do

    it 'WritableのTransaction中にReadonlyを参照してしまう' do
      ApplicationRecord.transaction_with do
        inu = DogParent.new
        inu.save!
        expect(DogParent.all.size).to eq(1)
        ApplicationRecord.with_readonly do
          expect(DogParent.all.size).to eq(0)
        end
      end
    end

    it 'WritableのTransaction中にReadonlyを参照してしまう' do
      # rspecがSAVEPOINTをつかって動くためreadonlyに伝搬しないので、確認できないが以下も問題なし
      # dog = nil
      # ApplicationRecord.with_readonly do
      #   dog = DogParent.all.first
      #   ApplicationRecord.transaction_with do
      #     dog.name = 'ポチ1'
      #     dog.save!
      #   end
      #   p dog.name -> 'ポチ1'
      # end
    end
  end
end
