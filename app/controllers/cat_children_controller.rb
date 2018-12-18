class CatChildrenController < ApplicationController

  def children
    @cat_parent = CatParent.find(params[:id])
    @cat_children = @cat_parent.cat_children
  end

  def child_show
    @cat_child = CatChild.find(params[:id])
  end

  def child_new
    @cat_parent = CatParent.find(params[:id])
    @cat_child = CatChild.new
  end

  def child_create
    @cat_parent = CatParent.find(params[:id])
    @cat_child = @cat_parent.cat_children.build
    @cat_child.name = params.dig(:cat_child, :name)
    if @cat_child.save
      redirect_to children_cat_child_path(@cat_parent), notice: '作成しました'
    else
      render :child_new
    end
  end

  def child_show
    @cat_child = CatChild.find(params[:id])
  end

  def child_edit
    @cat_child = CatChild.find(params[:id])
  end

  def child_update
    @cat_child = CatChild.find(params[:id])
    @cat_child.name = params.dig(:cat_child, :name)
    if @cat_child.save
      redirect_to child_show_cat_child_path(@cat_child), notice: '保存しました'
    else
      render :child_edit
    end
  end
end
