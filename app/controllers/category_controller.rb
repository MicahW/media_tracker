class CategoryController < ApplicationController
  before_action :logged_in_user, only: [:show, :create, :index, :add_child]
  
  def add_existing_child
    category = Category.find(params[:id])
    child = Category.find(params[:child_id])
    SubCategorie.add_relationship(category,child)
    redirect_to category_path(params[:id])
  end
  
  def add_child
    category = Category.find(params[:id])
    child = Category.add_category(current_user,params[:name])
    SubCategorie.add_relationship(category,child)
    redirect_to category_path(params[:id])
  end
  
  def create
    cat = Category.add_category(current_user, params[:name])
    flash[:danger] = cat.name + " added"
    @struct = Category.get_hierarchical_struct(current_user)
    render '/category/index/'
  end
  
  def index
    @struct = Category.get_hierarchical_struct(current_user)
    puts @struct
  end

  def show
    cats = Category.get_all_categories(current_user)
    @categories = []
    
    cats.each do |c|
      if c["id"].to_i != params[:id].to_i
        @categories.push(Category.find(c["id"]))
      end
    end
  
    @category = Category.find(params[:id])
    if @category.has_category?(current_user)
      @children = SubCategorie.find_children(@category)
      @parent = SubCategorie.find_parents(@category)
      if @parent.values.length == 0
        @parent = nil
      else
        @parent = Category.find(@parent[0]["parents_id"].to_i)
      end
      puts @parent
    else
      redirect_to root_path
    end
  end
      
  
end
