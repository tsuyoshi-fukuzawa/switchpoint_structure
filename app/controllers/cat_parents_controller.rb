class CatParentsController < ApplicationController

  def index
  end

  def show
  end

  def new
    @cat_parent = CatParent.new
  end

  def create
    @cat_parent = CatParent.new
    @cat_parent.name = params.dig(:cat_parent, :name)
    if @cat_parent.save
      redirect_to cat_parents_path, notice: '作成しました'
    else
      render :new
    end
  end

  def show
    @cat_parent = CatParent.find(params[:id])
  end

  def edit
    @cat_parent = CatParent.find(params[:id])
  end

  def update
    @cat_parent = CatParent.find(params[:id])
    @cat_parent.name = params.dig(:cat_parent, :name)
    if @cat_parent.save
      redirect_to cat_parent_path(@cat_parent), notice: '保存しました'
    else
      render :edit
    end
  end

end
