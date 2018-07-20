class CommentsController < ApplicationController
# <<<<<<< HEAD
# =======
	before_action :ensure_ticket_not_closed
# >>>>>>> staging

	def create
		@comment = Comment.create(comment_params)
		ticket_creator = @comment.ticket.user == @comment.user
		respond_to do |format|
			if @comment.save
				ticket_creator ? @comment.ticket.user_response : @comment.ticket.support_response
				@comment.ticket.save
				format.html { redirect_to user_dashboard_path, notice: 'Comment was created' }
				format.js
			else
				format.html { redirect_to user_dashboard_path, alert: 'There was an error while creating comment' }
			end
		end
	end

# <<<<<<< HEAD
# 	def destroy
# 		@comment = Comment.find(params[:id])
# 		respond_to do |format|
# 			if @comment.destroy
# 				format.html { redirect_to request.referrer, notice: 'Comment was deleted' }
# 				format.js
# 			else
# 				format.html { redirect_to request.referrer, alert: 'There was an error while deleting comment' }
# 			end
# 		end
# 	end

# =======
# >>>>>>> staging
	private
	def comment_params
		params.require(:comment).permit(:body, :ticket_id).merge(user_id: current_user.id)
	end

	def ensure_ticket_not_closed
		@ticket = Ticket.find(params[:comment][:ticket_id])
		if @ticket.status.status == 'closed'
			redirect_to ticket_path(@ticket.id), alert: 'This ticket is closed'
		end
	end

end