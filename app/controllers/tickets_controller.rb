class TicketsController < ApplicationController
  before_action :ensure_authorized, only: :index
  before_action :ensure_related_to_ticket, only: :show

  def index
    if current_user.admin?
      @tickets = Ticket.all.paginate(:page => params[:page], :per_page => params[:number])
    elsif current_user.om_support?
      @tickets = Ticket.joins(:department).where('departments.department_name' => 'OM').paginate(:page => params[:page], :per_page => params[:number])
    elsif current_user.it_support?
      @tickets = Ticket.joins(:department).where('departments.department_name' => 'IT').paginate(:page => params[:page], :per_page => params[:number])
    end
  end

  def show
    @ticket = Ticket.find(params[:id])
    @comment = Comment.new(ticket_id: @ticket.id)
  end

  def new
    @ticket = Ticket.new
    @departments = Department.all.map { |department| [department.department_name, department.id] }
  end

  def create
    @ticket = current_user.tickets.build(ticket_params)
    respond_to do |format|
      if @ticket.save
        format.html { redirect_to user_dashboard_url, notice: 'New ticket has been reported' }
      else
        format.html { render :new }
      end
    end
  end

  def update
    @ticket = Ticket.find(params[:id])
    status_closed = Status.find_by(status: 'closed')
    respond_to do |format|
      if @ticket.update(status_id: status_closed.id)
        format.html { redirect_to user_dashboard_url, notice: 'Ticket closed' }
      else
        format.html { redirect_to user_dashboard_url, alert: 'Could not close the ticket' }
      end
    end
  end

  private

  def ticket_params
    params.require(:ticket).permit(:title, :note, :status_id, :department_id)
  end

  def ensure_authorized
    redirect_to user_dashboard_url, alert: 'Forbidden access' if current_user.none?
  end

  def ensure_related_to_ticket
    ticket = Ticket.find(params[:id])
    unless (ticket.user == current_user ||
                          current_user.admin? ||
                          (current_user.it_support? && ticket.department.department_name == 'IT') ||
                          (current_user.om_support? && ticket.department.department_name == 'OM'))
        redirect_to user_dashboard_url, alert: 'Forbidden access'
    end
  end
end
