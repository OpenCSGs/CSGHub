class InternalApi::DatasetsController < InternalApi::ApplicationController
  before_action :authenticate_user, except: [:index, :files, :readme, :preview_parquet]

  include Api::SyncStarhubHelper
  include Api::BuildCommitHelper
  include Api::FileOptionsHelper
  include Api::RepoValidation

  def index
    res_body = Starhub.api.get_datasets(current_user&.name,
                                        params[:search],
                                        params[:sort],
                                        params[:task_tag],
                                        params[:framework_tag],
                                        params[:license_tag],
                                        params[:page],
                                        params[:per_page])
    api_response = JSON.parse(res_body)
    render json: { datasets: api_response['data'], total: api_response['total'] }
  end

  def files
    last_commit, files = Starhub.api.get_dataset_detail_files_data_in_parallel(params[:namespace], params[:dataset_name], files_options)
    render json: { last_commit: JSON.parse(last_commit)['data'], files: JSON.parse(files)['data'] }
  end

  def readme
    readme = Starhub.api.get_dataset_file_content(params[:namespace], params[:dataset_name], 'README.md')
    readme_content = JSON.parse(readme)['data']
    readme_content = relative_path_to_resolve_path 'dataset', readme_content
    render json: { readme: readme_content }
  rescue StarhubError
    render json: { readme: '' }
  end

  def create
    dataset = current_user.created_datasets.build(dataset_params)
    if dataset.save
      render json: { path: dataset.path, message: '数据集创建成功!' }, status: :created
    else
      render json: { message: dataset.errors.full_messages.to_sentence }, status: :unprocessable_entity
    end
  end

  def update
    @dataset.nickname = params[:nickname] if params[:nickname].present?
    @dataset.desc = params[:desc] if params[:desc].present?

    if @dataset.save
      render json: { message: '更新成功' }
    else
      render json: { message: "更新失败" }, status: :bad_request
    end
  end

  def destroy
    if @dataset.destroy
      render json: { message: '删除成功' }
    else
      render json: { message: "删除 #{params[:namespace]}/#{params[:dataset_name]} 失败" }, status: :bad_request
    end
  end

  def create_file
    options = create_file_params.slice(:branch).merge({ message: build_create_commit_message,
                                                        new_branch: 'main',
                                                        username: current_user.name,
                                                        email: current_user.email,
                                                        content: Base64.encode64(params[:content])
                                                      })
    sync_create_file('dataset', options)
    render json: { message: '创建文件成功' }
  end


  def update_file
    options = update_file_params.slice(:branch, :sha).merge({ message: build_update_commit_message,
                                                        new_branch: 'main',
                                                        username: current_user.name,
                                                        email: current_user.email,
                                                        content: Base64.encode64(params[:content]),
                                                        sha: params[:sha]
                                                      })
    sync_update_file('dataset', options)
    render json: { message: '更新文件成功' }
  end

  def update_readme_tags
    tags = params[:tags]
    # 更新 README 元数据中的 tags
    readme_metadata = Starhub.api.get_dataset_file_content(params[:namespace], params[:dataset_name], 'README.md')
    blob =  Starhub.api.get_dataset_sha(params[:namespace], params[:dataset_name], 'README.md')
    blob_data = JSON.parse(blob) if blob.present?
    sha = blob_data&.dig("data", "sha")
    metadata = JSON.parse(readme_metadata)
    metadata_data = metadata['data']

    
    # 查找元数据部分的开始和结束位置
    start_index = metadata_data.index('---')
    end_index = metadata_data.index('---', start_index + 3)
  
    # 提取元数据部分
    metadata_part = metadata_data[start_index...end_index + 4]
    metadata_hash = YAML.safe_load(metadata_part)

    # 更新或添加 tags
    metadata_hash['tags'] = tags
    # 重新生成元数据部分
    updated_metadata_part = YAML.dump(metadata_hash)
    updated_metadata_part += "---\n"  # 手动添加`---`标记
  
    # 更新 README 内容
    updated_readme_content = metadata_data.sub(metadata_part, updated_metadata_part)
    options = update_file_params.slice(:branch).merge({ message: build_update_commit_message,
                                                              new_branch: 'main',
                                                              username: current_user.name,
                                                              email: current_user.email,
                                                              content: Base64.encode64(updated_readme_content),
                                                              sha:sha
                                                            })
    sync_update_file('dataset', options)
    render json: { message: 'README tags updated successfully' }
  rescue StandardError => e
    render json: { error: e.message }, status: :unprocessable_entity
  end

  def upload_file
    file = params[:file]
    options = {
      branch: 'main',
      file_path: file.original_filename,
      file: Multipart::Post::UploadIO.new(file.tempfile.path, file.content_type),
      email: current_user.email,
      message: build_upload_commit_message,
      username: current_user.name
    }
    sync_upload_file('dataset', options)
    render json: { message: '上传文件成功' }
  end

  def preview_parquet
    json_data = Starhub.api.get_dataset_files(params[:namespace], params[:dataset_name], { path: params[:path] })
    parquet_file_path = JSON.parse(json_data)['data']
                            .filter_map { |file| file['path'].end_with?('.parquet') ? file['path'] : nil }
                            .sort_by { |path| path.downcase }.first
    if parquet_file_path
      preview_data = Starhub.api.preview_datasets_parquet_file(params[:namespace], params[:dataset_name], parquet_file_path)
      render json: preview_data
    else
      render json: {}
    end
  end

  private

  def dataset_params
    params.permit(:name, :nickname, :desc, :owner_id, :owner_type, :license)
  end

  def create_file_params
    params.permit(:path, :content, :branch, :commit_title, :commit_desc)
  end

  def update_file_params
    params.permit(:path, :content, :branch, :commit_title, :commit_desc, :sha)
  end
end
