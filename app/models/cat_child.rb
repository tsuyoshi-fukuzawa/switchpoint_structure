class CatChild < ApplicationRecordAnother
  belongs_to :cat_parent, required: false
end
