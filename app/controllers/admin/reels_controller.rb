class Admin::ReelsController < Admin::BaseController
  before_action :set_reel, only: [ :edit, :update, :destroy ]

  def index
    @q = Reel.ransack(params[:q])
    reels = @q.result

    @stats = [
      { value: reels.size,                                       label: "Total" },
      { value: reels.count { |r| r.video.attached? }, label: "Con video" },
      { value: reels.count { |r| !r.video.attached? }, label: "Sin video" },
    ]

    case params[:has_video]
    when "yes" then reels = reels.select { |r| r.video.attached? }
    when "no"  then reels = reels.select { |r| !r.video.attached? }
    end

    @reels = reels
  end

  def new
    @reel = Reel.new
  end

  def create
    @reel = Reel.new(reel_params)
    if @reel.save
      redirect_to admin_reels_path, notice: "Reel creado."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @reel.update(reel_params)
      redirect_to admin_reels_path, notice: "Reel actualizado."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @reel.destroy
    redirect_to admin_reels_path, notice: "Reel eliminado."
  end

  private

  def set_reel
    @reel = Reel.find(params[:id])
  end

  def reel_params
    params.require(:reel).permit(:tag, :label, :position, :video)
  end
end
