class DogChildrenController < ApplicationController
  # メソッド指定で除外できるが、遅延発生時にデータ不整合が起きたように見えるので非推奨。書き込みがあるコントローラではreadonlyにしないほうがいよい
  around_action :with_readonly, except: [:child_create, :child_update]

  def children
    @dog_parent = DogParent.find(params[:id])
    @dog_children = @dog_parent.dog_children
  end

  def child_show
    @dog_child = DogChild.find(params[:id])
  end

  def child_new
    @dog_parent = DogParent.find(params[:id])
    @dog_child = DogChild.new
  end

  def child_create
    @dog_parent = DogParent.find(params[:id])
    @dog_child = @dog_parent.dog_children.build
    @dog_child.name = params.dig(:dog_child, :name)
    if @dog_child.save
      redirect_to children_dog_child_path(@dog_parent), notice: '作成しました'
    else
      render :child_new
    end
  end

  def child_show
    @dog_child = DogChild.find(params[:id])
  end

  def child_edit
    @dog_child = DogChild.find(params[:id])
  end

  def child_update
    @dog_child = DogChild.find(params[:id])
    @dog_child.name = params.dig(:dog_child, :name)
    if @dog_child.save
      redirect_to child_show_dog_child_path(@dog_child), notice: '保存しました'
    else
      render :child_edit
    end
  end
end
