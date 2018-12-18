class AnimalsController < ApplicationController
  def index
    ApplicationRecord.with_readonly do
      @dog_parents_count = DogParent.all.size
    end
    ApplicationRecordCat.with_readonly do
      @cat_parents = CatParent.all
    end
  end
end
