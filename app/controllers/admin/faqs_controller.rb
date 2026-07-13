class Admin::FaqsController < Admin::BaseController
  before_action :set_faq, only: [ :edit, :update, :destroy ]

  def index
    @q = Faq.ransack(params[:q])
    @faqs = @q.result
  end

  def new
    @faq = Faq.new
  end

  def create
    @faq = Faq.new(faq_params)
    if @faq.save
      redirect_to admin_faqs_path, notice: "FAQ creada."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @faq.update(faq_params)
      redirect_to admin_faqs_path, notice: "FAQ actualizada."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @faq.destroy
    redirect_to admin_faqs_path, notice: "FAQ eliminada."
  end

  private

  def set_faq
    @faq = Faq.find(params[:id])
  end

  def faq_params
    params.require(:faq).permit(:question, :answer, :position)
  end
end
