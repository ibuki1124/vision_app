class PostsController < ApplicationController
  before_action :is_post_user?, only: [:edit, :update]
  
  def top
  end

  def new
    @post = Post.new
  end

  def create
    @post = Post.new(post_params)
    @post.user_id = current_user.id
    if @post.vision_image.attached?
      tags = Vision.get_image_data(post_params[:vision_image])
    else
      tags = ["none"]
    end
    if @post.save
      tags.each do |tag|
        @post.tags.create(name: tag)
      end
      redirect_to post_path(@post)
    else
      render :new
    end
  end

  def search
    @q = Tag.ransack(params[:q])
    @results = @q.result
    # 検索でヒットした投稿のidを配列に入れる
    @post_id = []
    @results.each do |a|
      @post_id.push(a.post_id)
    end
    # 重複している投稿idを消し投稿を取得し配列に入れる
    @post = []
    @post_id.uniq.each do |id|
      @post.push(Post.find(id))
    end
    
  end

  def index
    @q = Tag.ransack(params[:q])
    @posts = Post.all
  end

  def show
    @post = Post.find(params[:id])
  end

  def edit
  end

  def update
    @post.update(post_params)
    redirect_to post_path(@post)
  end

  def destroy
    @post = Post.find(params[:id])
    @post.destroy
    redirect_to posts_path
  end

  private
  def post_params
    params.require(:post).permit(:title, :vision_image)
  end
  
  def is_post_user?
    @post = Post.find(params[:id])
    unless @post.user_id == current_user.id
      redirect_to post_path(@post)
    end
  end
end
