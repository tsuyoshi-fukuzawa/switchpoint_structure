require 'rails_helper'

RSpec.describe DogParent, type: :model do

  before(:each) do
  end

  describe 'DB Config' do
    it 'MainDBに接続がいっていることを確認する' do
      inu = DogParent.new(name: 'ポチ')
      inu.save!
      expect(DogParent.all.size).to eq(1)

      dog_config = DogParent.connection.pool.spec.config
      expect(dog_config[:switch_points][0][:name]).to eq(:main)
      expect(dog_config[:switch_points][0][:mode]).to eq(:writable)
    end
  end
end
