require 'rails_helper'

#
# TESTで使用するDBをMainとAnotherに分けること
#
RSpec.describe DogParent do
  describe 'RSPECでデータが消えるか確認' do
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
      expect(CatParent.all.size).to eq(0)
    end
  end

  describe 'Factoryデータが消えるか確認' do
    before(:each) do
      FactoryBot.create(:dog_parent)
      FactoryBot.create(:cat_parent)
    end
    it '1回目' do
      expect(DogParent.all.size).to eq(1)
      expect(CatParent.all.size).to eq(1)
    end

    it '2回目' do
      expect(DogParent.all.size).to eq(1)
      expect(CatParent.all.size).to eq(1)
    end
  end
end