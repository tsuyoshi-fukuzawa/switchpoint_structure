require 'rails_helper'

# switchpointを使うようにし、writableのみのコンフィグにしなかった場合、このテストが失敗する
RSpec.describe DogParent do
  before(:each) do
  end
  describe 'readonly' do
    it 'readonlyが無効化されていることを確認する' do
      dog = DogParent.new(name: 'ポチ')
      dog.save!
      DogParent.with_readonly do
        expect(DogParent.all.size).to eq(1)
      end
    end
  end

  describe 'writable' do
    it 'writableでエラーにならないことを確認する' do
      DogParent.with_writable do
        dog = DogParent.new(name: 'ポチ')
        dog.save!
      end
      expect(DogParent.all.size).to eq(1)
    end
  end

  describe 'transaction_with' do
    it 'transaction_withが無効化されていることを確認する' do
      DogParent.transaction_with do
        dog = DogParent.new(name: 'ポチ')
        dog.save!
      end
      expect(DogParent.all.size).to eq(1)
    end
  end
end
