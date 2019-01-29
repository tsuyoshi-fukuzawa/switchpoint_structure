require 'rails_helper'

# switchpointを使うようにコンフィグを修正した上で実行すること
RSpec.describe DogParent, type: :model do

  before(:each) do
  end

  describe 'DB Config' do
    it 'AnotherDBに接続がいっていることを確認する' do
      neko = CatParent.new(name: 'ポチ')
      neko.save!
      expect(CatParent.all.size).to eq(1)

      cat_config = CatParent.connection.pool.spec.config
      # configでreadonlyのみにすると、:switch_pointではなく、switch_pointsになり、配列が入ってくる
      expect(cat_config[:switch_points][0][:name]).to eq(:main)
      expect(cat_config[:switch_points][0][:mode]).to eq(:writable)
    end
  end
end
