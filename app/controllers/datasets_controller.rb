class DatasetsController < ApplicationController
  layout 'new_application'

  before_action :check_user_info_integrity
  before_action :authenticate_user, only: [:new_file, :upload_file]
  before_action :load_branch_and_path, only: [:files, :blob, :new_file, :upload_file, :resolve]
  before_action :load_dataset_detail, only: [:show, :files, :blob, :new_file, :upload_file]

  def index
    response = {}
    Tag::DATASET_TAG_FIELDS.each do |field|
      response[field] = {}
      response[field][:color] = Tag::TAG_FIELD_COLOR_MAPPINGS[field][:color]
      response[field][:zh_name] = Tag::TAG_FIELD_COLOR_MAPPINGS[field][:zh_name]
      response[field][:tags] = Tag.where(tag_field: field, scope: 'dataset')
    end
    @task_tags = response.as_json
    @framework_tags = Tag.where(tag_type: 'framework').as_json
    @license_tags = Tag.where(tag_type: 'license').order(weight: :asc).as_json
  end

  def new
    @available_namespaces = current_user.available_namespaces
    system_config = SystemConfig.first
    license_configs = system_config.license_configs rescue nil
    @licenses = license_configs.presence || Model::DEFAULT_LICENSES
  end

  def show
    @default_tab = 'summary'
  end

  def files
    render :show
  end

  def blob
    render :show
  end

  def resolve
    dataset_ability_check

    if params[:download] == 'true'
      if params[:lfs] == 'true'
        file_url = Starhub.api.download_datasets_file(params[:namespace],
                                                      params[:dataset_name],
                                                      params[:lfs_path],
                                                      { ref: @current_branch,
                                                        lfs: true,
                                                        save_as: @current_path })
        redirect_to JSON.parse(file_url)['data'], allow_other_host: true
      else
        file = Starhub.api.download_datasets_file(params[:namespace],
                                                  params[:dataset_name],
                                                  @current_path,
                                                  { ref: @current_branch })
        send_data file, filename: @current_path
      end
    else
      content_type = helpers.content_type_format_mapping[params[:format]] || 'text/plain'
      if ['jpg', 'png', 'jpeg', 'gif', 'svg'].include? params[:format]
        result = Starhub.api.download_datasets_file(params[:namespace],
                                                    params[:dataset_name],
                                                    @current_path,
                                                    { ref: @current_branch })
        send_data result, type: content_type, disposition: 'inline'
      else
        result = Starhub.api.get_datasets_file_content(params[:namespace],
                                                       params[:dataset_name],
                                                       @current_path,
                                                       { ref: @current_branch })
        render plain: JSON.parse(result)['data']
      end
    end
  end

  def upload_file
    render :show
  end

  def new_file
    render :show
  end

  private

  def dataset_ability_check
    @owner = User.find_by(name: params[:namespace]) || Organization.find_by(name: params[:namespace])
    @local_dataset = @owner && @owner.datasets.find_by(name: params[:dataset_name])
    unless @local_dataset
      return redirect_to errors_not_found_path
    end
    if @local_dataset.dataset_private?
      if @local_dataset.owner.instance_of? User
        return redirect_to errors_unauthorized_path if @local_dataset.owner != current_user
      else
        return redirect_to errors_unauthorized_path unless current_user.org_role(@local_dataset.owner)
      end
    end
  end

  def load_dataset_detail
    dataset_ability_check

    return if action_name == 'blob' && params[:download] == 'true'

    @owner_url = helpers.code_repo_owner_url @owner
    @avatar_url = @owner.avatar_url

    if action_name == 'blob'
      @dataset, raw_tags, @last_commit, @branches, @content = Starhub.api.get_dataset_detail_blob_data_in_parallel(params[:namespace], params[:dataset_name], files_options)
    else
      @dataset, raw_tags, @branches = Starhub.api.get_dataset_detail_data_in_parallel(params[:namespace], params[:dataset_name], files_options)
    end

    if ['jpg', 'png', 'jpeg', 'gif', 'svg'].include? request.fullpath.split('.').last
      @content = {data: "<img src='#{request.fullpath.gsub('blob', 'resolve')}'>"}.to_json
    else
      @content = relative_path_to_resolve_path 'dataset', @content
    end

    @tags = Tag.build_detail_tags(JSON.parse(raw_tags)['data']).to_json
    @settings_visibility = current_user ? current_user.can_manage?(@local_dataset) : false
  end

  def load_branch_and_path
    @default_tab = 'files'
    @current_branch = params[:branch] || 'main'
    @current_path = if request.path.split('/').last.split('.').last == params[:format]
                      "#{params[:path]}.#{params[:format]}"
                    else
                      params[:path]
                    end
  end

  def files_options
    {
      ref: @current_branch,
      path: @current_path
    }
  end
end
