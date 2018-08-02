class CommentsController < ApplicationController
  def create
    @ticket = Ticket.find(params[:comment][:ticket_id])
    redirect_to ticket_path(@ticket.id), alert: 'This ticket is closed' and return if @ticket.closed?
    @comment = Comment.new(comment_params)
    respond_to do |format|
      if @comment.save
        @comment.update_ticket_status!(user: @comment.user, ticket: @ticket)
        user_ids = @comment.ticket.comments.where.not(user_id: current_user.id).pluck(:user_id)
        user_ids.append(@comment.ticket.user.id) if user_ids.empty?
        @comment.ticket.notify_users(user_ids)
        @emails = @ticket.comments.joins(:user).distinct.pluck(:email)
        if !@emails.include?(@ticket.user.email)
          @emails.push(@ticket.user.email)
        end
        @emails.delete(current_user.email)
        @emails.each do |email|
          SlackService.new.call(email, @ticket.id) 
        end
        format.html { redirect_to ticket_path(@ticket.id), notice: 'Comment was created' }
        format.js
      else
        if @comment.body.empty?
          format.html { redirect_to ticket_path(@ticket.id), alert: 'Couldn\'t create comment without any text' }
        else
          format.html { redirect_to ticket_path(@ticket.id), alert: 'There was an error while creating comment' }
        end
      end
    end
  end

  private

  def comment_params
    params.require(:comment).permit(:body, :ticket_id, uploads: []).merge(user_id: current_user.id)
  end
end