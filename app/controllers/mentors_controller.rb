class MentorsController < SiteController
  def create
    @mentor = @site.mentors.new(params[:mentor])
    if @mentor.save
      redirect_to manage_site_mentor_path(@site, @mentor), notice: 'Mentor was added'
    else
      redirect_to manage_site_path(@site), alert: "Error adding mentor: #{@mentor.errors.full_messages.join(', ')}"
    end
  end

  def destroy
    @mentor = @site.mentors.find(params[:id])
    @mentor.destroy
    if @mentor.destroyed?
      flash[:notice] = "Mentor was removed"
    else
      flash[:alert] = "Cannot remove mentor: #{@mentor.errors.full_messages.join}"
    end
    redirect_to manage_site_path(@site)
  end
end
