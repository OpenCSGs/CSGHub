class OrganizationsController < ApplicationController
  layout 'repo_application'

  before_action :check_user_info_integrity
  before_action :authenticate_user, except: [:show]

  def edit
    @organization = Organization.find_by(name: params[:id])
    authorize @organization
  end

  def new
  end

  def show
    @organization = Organization.find_by(name: params[:id])
    unless @organization
      flash[:alert] = "未找到对应的组织"
      return redirect_to errors_not_found_path
    end
    user_org_role = current_user && current_user.org_role(@organization)
    @admin = user_org_role == 'admin'
    @members = @organization.members
    @models = csghub_api.get_org_models(@organization.name, current_user&.name)
    @datasets = csghub_api.get_org_datasets(@organization.name, current_user&.name)
    @spaces = csghub_api.get_org_application_spaces(@organization.name, current_user&.name)
    @codes = csghub_api.get_org_codes(@organization.name, current_user&.name)
  end

  def members
    @organization = Organization.find_by(name: params[:id])
    authorize @organization
    user_org_role = current_user && current_user.org_role(@organization)
    @admin = user_org_role == 'admin'
  end
end
