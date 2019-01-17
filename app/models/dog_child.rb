class DogChild < ApplicationRecord
  belongs_to :dog_parent, required: false

  after_create do
    if name == 'AFTER CREATE TEST'
      cat = CatChild.new
      cat.save!
    end
  end
end
