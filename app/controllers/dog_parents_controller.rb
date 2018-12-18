class DogParentsController < ApplicationController

  def index
  end

  def show
  end

  def new
    @dog_parent = DogParent.new
  end

  def create
    @dog_parent = DogParent.new
    @dog_parent.name = params.dig(:dog_parent, :name)
    if @dog_parent.save
      redirect_to dog_parents_path, notice: '作成しました'
    else
      render :new
    end
  end

  def show
    @dog_parent = DogParent.find(params[:id])
  end

  def edit
    @dog_parent = DogParent.find(params[:id])
  end

  def update
    @dog_parent = DogParent.find(params[:id])
    @dog_parent.name = params.dig(:dog_parent, :name)
    if @dog_parent.save
      redirect_to dog_parent_path(@dog_parent), notice: '保存しました'
    else
      render :edit
    end
  end

end
