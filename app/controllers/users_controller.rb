class UsersController < ApplicationController
  before_filter :authenticate_user!
  before_filter :correct_user,   only: [:edit, :update, :crop]
  before_filter :admin_user,     only: :destroy
  
  def new
    @user = User.new
  end

  def show
    @user = User.find(params[:id])
    @microposts = @user.microposts.paginate(page: params[:page])
    if @user.avatar? 
      @avatar = Avatar.find(@user.avatar)
    end
    if request.path != user_path(@user)
      redirect_to @user, status: :moved_permanently
    end
  end

  def create
    @user = User.new(params[:user])
    if @user.save
      sign_in @user
      flash[:success] = "Welcome to the Sample App!"
      redirect_to @user
    else
      render 'new'
    end
  end

  def edit
  end

  def update    
    if @user.update_attributes(params[:user])
      sign_in @user
      if params[:user][:image].present?
        render :crop
      else
        flash[:success] = "Profile updated"
        redirect_to @user
      end
    else
      render 'edit'
    end
  end
  
  def index
    @users = User.paginate(page: params[:page])
  end

  def destroy
    User.find(params[:id]).destroy
    flash[:success] = "User destroyed."
    redirect_to users_path
  end

  def following
    @title = "Following"
    @user = User.find(params[:id])
    @users = @user.followed_users.paginate(page: params[:page])
    render 'show_follow'
  end

  def followers
    @title = "Followers"
    @user = User.find(params[:id])
    @users = @user.followers.paginate(page: params[:page])
    render 'show_follow'
  end

  private

    def correct_user
      @user = User.find(params[:id])
      logger.info "1 #{@user.id}"
      logger.info "1 #{current_user.id}"
      redirect_to(root_path) unless current_user == (@user)
    end

    def admin_user
      redirect_to(root_path) unless current_user.admin?
    end

end
