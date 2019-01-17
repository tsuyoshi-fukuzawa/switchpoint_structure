class DogChild < ApplicationRecord
  belongs_to :dog_parent, required: false

  after_create do
    if name == 'AFTER CREATE TEST'
      cat = CatChild.new
      cat.save!
    end
  end

  after_commit do
    if name == 'AFTER COMMIT TEST'
      cat = CatChild.new
      cat.save!
    end
  end
end
