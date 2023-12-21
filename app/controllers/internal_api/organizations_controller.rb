class InternalApi::OrganizationsController < InternalApi::ApplicationController
  before_action :authenticate_user

  def create
    new_org = Organization.new organization_params
    if params[:logo].present?
      image_url_code = AliyunOss.instance.upload 'org-logo', params[:logo]
      new_org.logo = image_url_code
    end
    new_org.creator = current_user
    Organization.transaction do
      new_org.save!
      OrgMembership.create!(organization: new_org, user: current_user, role: :admin)
    end
    render json: {message: '组织创建成功!'}, status: 200
  rescue => error
    render json: {message: error.message}, status: 500
  end

  def update
  end

  private

  def organization_params
    params.permit(:name, :nickname, :homepage, :org_type)
  end
end
