require 'rails_helper'

RSpec.describe DogParent, type: :model do

  before(:each) do
  end

  describe 'テスト' do
    it '1回目' do
      FactoryBot.create(:dog_parent)
      expect(DogParent.all.size).to eq(1)
    end

    it '2回目' do
      FactoryBot.create(:dog_parent)
      expect(DogParent.all.size).to eq(1)
    end
  end
end
