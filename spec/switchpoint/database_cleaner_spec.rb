require 'rails_helper'

# テストでswitchpointを使うようにコンフィグを修正した場合、このテストが失敗する。
RSpec.describe DogParent do
  describe 'データが消えるか確認' do
    before(:each) do
    end
    it '1回目' do
      dog = DogParent.new
      dog.save!
      expect(DogParent.all.size).to eq(1)

      cat = CatParent.new
      cat.save!
      expect(CatParent.all.size).to eq(1)
    end

    it '2回目' do
      expect(DogParent.all.size).to eq(0)
      expect(CatParent.all.size).to eq(0)
    end
  end
end