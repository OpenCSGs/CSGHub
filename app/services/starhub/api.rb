require 'starhub/client'

module Starhub
  class Api
    include SharedRepoApis
    include ModelApis
    include DatasetApis
    include ApplicationSpaceApis
    include CodeApis
    include EndpointApis

    def initialize user_ip
      @client = Starhub::Client.init_with user_ip
    end

    def create_user(name, nickname, phone, email, login_identity)
      options = {
        username: name,
        name: nickname,
        email: email,
        phone: phone,
        uuid: login_identity,
        reg_provider: ENV.fetch('REG_PROVIDER', 'default')
      }
      @client.post("/users?current_user=#{name}", options)
    end

    def update_user(name, nickname, phone, email, login_identity)
      options = {
        username: name,
        name: nickname,
        email: email,
        phone: phone,
        uuid: login_identity,
        reg_provider: ENV.fetch('REG_PROVIDER', 'default')
      }
      @client.put("/users/#{name}?current_user=#{name}", options)
    end

    def generate_git_token(username, name, options = {})
      options[:name] = name
      res = @client.post("/user/#{username}/tokens?current_user=#{username}", options)
      raise StarhubError, res.body unless res.success?
      res.body
    end

    def delete_git_token(username, token_name, current_user)
      @client.delete("/user/#{username}/tokens/#{token_name}?current_user=#{current_user}")
    end

    def get_user_models(namespace, username, options = {})
      options[:per] ||= 6
      options[:page] ||= 1
      options[:current_user] = username
      res = @client.get("/user/#{namespace}/models", options)
      raise StarhubError, res.body unless res.success?
      res.body.force_encoding('UTF-8')
    end

    def get_org_models(namespace, username, options = {})
      options[:per] ||= 6
      options[:page] ||= 1
      options[:current_user] = username
      res = @client.get("/organization/#{namespace}/models", options)
      raise StarhubError, res.body unless res.success?
      res.body.force_encoding('UTF-8')
    end

    def get_user_datasets(namespace, username, options = {})
      options[:per] ||= 6
      options[:page] ||= 1
      options[:current_user] = username
      res = @client.get("/user/#{namespace}/datasets", options)
      raise StarhubError, res.body unless res.success?
      res.body.force_encoding('UTF-8')
    end

    def get_org_datasets(namespace, username, options = {})
      options[:per] ||= 6
      options[:page] ||= 1
      options[:current_user] = username
      res = @client.get("/organization/#{namespace}/datasets", options)
      raise StarhubError, res.body unless res.success?
      res.body.force_encoding('UTF-8')
    end

    def get_user_application_spaces(namespace, username, options = {})
      options[:per] ||= 6
      options[:page] ||= 1
      options[:current_user] = username
      res = @client.get("/user/#{namespace}/spaces", options)
      raise StarhubError, res.body unless res.success?
      res.body.force_encoding('UTF-8')
    end

    def get_user_codes(namespace, username, options = {})
      options[:per] ||= 6
      options[:page] ||= 1
      options[:current_user] = username
      res = @client.get("/user/#{namespace}/codes", options)
      raise StarhubError, res.body unless res.success?
      res.body.force_encoding('UTF-8')
    end

    def get_user_endpoints(namespace, username, options = {})
      options[:per] ||= 6
      options[:page] ||= 1
      options[:current_user] = username
      res = @client.get("/user/#{namespace}/run/model", options)
      raise StarhubError, res.body unless res.success?
      res.body.force_encoding('UTF-8')
    end

    def get_org_application_spaces(namespace, username, options = {})
      options[:per] ||= 6
      options[:page] ||= 1
      options[:current_user] = username
      res = @client.get("/organization/#{namespace}/spaces", options)
      raise StarhubError, res.body unless res.success?
      res.body.force_encoding('UTF-8')
    end

    def get_org_codes(namespace, username, options = {})
      options[:per] ||= 6
      options[:page] ||= 1
      options[:current_user] = username
      res = @client.get("/organization/#{namespace}/codes", options)
      raise StarhubError, res.body unless res.success?
      res.body.force_encoding('UTF-8')
    end

    def preview_datasets_parquet_file(username, dataset_name, path, options = {})
      options[:count] ||= 6
      res = @client.get("/datasets/#{username}/#{dataset_name}/viewer/#{path}", options)
      raise StarhubError, res.body unless res.success?
      res.body
    end

    def get_ssh_key(username, current_user)
      options = {
        username: username,
        current_user: current_user
      }
      @client.get("/user/#{username}/ssh_keys", options)
    end

    def create_organization(username, org_name, org_full_name, desc, current_user)
      options = {
        username: username,
        name: org_name,
        full_name: org_full_name,
        description: desc
      }
      @client.post("/organizations?current_user=#{current_user}", options)
    end

    def update_organization(username, org_name, org_full_name, desc, current_user)
      options = {
        current_user: username,
        name: org_name,
        full_name: org_full_name,
        description: desc
      }
      @client.put("/organizations/#{org_name}?current_user=#{current_user}", options)
    end

    def text_secure_check(scenario, content)
      return unless sensitive_check_enabled?
      return if content.blank?
      options = {
        scenario: scenario,
        text: content
      }
      res = @client.post("/sensitive/text", options)
      if res.status == 400
        raise SensitiveContentError, '监测到敏感内容'
      elsif res.status == 500
        raise StarhubError, "Git服务器报错"
      else
        res
      end
    end

    def image_secure_check(scenario, oss_bucket_name, oss_object_name)
      return unless sensitive_check_enabled?
      return if oss_object_name.blank?
      options = {
        scenario: scenario,
        oss_bucket_name: oss_bucket_name,
        oss_object_name: oss_object_name
      }
      res = @client.post("/sensitive/image", options)
      if res.status == 400
        raise SensitiveContentError, '监测到敏感内容'
      elsif res.status == 500
        raise StarhubError, "Git服务器报错"
      else
        res
      end
    end

    def create_membership(org_name, op_user, role, user)
      options = {
        op_user: op_user,
        role: role,
        user: user
      }
      @client.post("/organizations/#{org_name}/members?current_user=#{op_user}", options)
    end

    def update_membership(org_name, op_user, new_role, old_role, username)
      options = {
        new_role: new_role,
        old_role: old_role,
        op_user: op_user
      }
      @client.put("/organizations/#{org_name}/members/#{username}?current_user=#{op_user}", options)
    end

    def delete_membership(org_name, op_user, role, user)
      options = {
        op_user: op_user,
        role: role,
        current_user: op_user
      }
      @client.delete("/organizations/#{org_name}/members/#{user}", options)
    end

    def get_jwt_token(username)
      options = {
        current_user: username
      }
      res = @client.post("/jwt/token?current_user=#{username}", options)
      raise StarhubError, res.body unless res.success?
      res.body
    end

    def model_predict(namespace, name, user, input, version)
      options = {
        current_user: user,
        input: input,
        version: "" #暂时不支持制定 version
      }
      res = @client.post("/models/#{namespace}/#{name}/predict?current_user=#{user}", options)
      raise StarhubError, res.body unless res.success?
      res.body
    end

    def get_user_likes(username, repotype, options = {})
      options[:per] ||= 6
      options[:page] ||= 1
      options[:current_user] = username
      res = @client.get("/user/#{username}/likes/#{repotype}", options)
      raise StarhubError, res.body unless res.success?
      res.body
    end

    def get_repo_mirror(repo_type, namespace, repo_name, options = {})
      res = @client.get("/#{repo_type}/#{namespace}/#{repo_name}/mirror", options)
      res.body
    end

    def sync_repo_mirror(repo_type, namespace, repo_name, options = {})
      res = @client.post("/#{repo_type}/#{namespace}/#{repo_name}/mirror/sync?current_user=#{options[:current_user]}", options)
      raise StarhubError, res.body unless res.success?
      res.body
    end

    def create_mirror(repo_type, namespace, name, options = {})
      res = @client.post("/#{repo_type}s/#{namespace}/#{name}/mirror?current_user=#{options[:current_user]}", options)
      raise StarhubError, res.body unless res.success?
    end

    def delete_mirror(repo_type, namespace, name, options = {})
      res = @client.delete("/#{repo_type}s/#{namespace}/#{name}/mirror?current_user=#{options[:current_user]}", options)
      raise StarhubError, res.body unless res.success?
    end

    def get_mirror_sources
      res = @client.get("/mirror/sources", options = {})
      raise StarhubError, res.body unless res.success?
      res.body
    end

    # TODO: add more starhub api

    private

    def sensitive_check_enabled?
      config_from_env = ENV.fetch('SENSITIVE_CHECK', nil)
      system_config = SystemConfig.first
      feature_flags = (system_config.feature_flags rescue {}) || {}
      sensitive_check = config_from_env || feature_flags['sensitive_check']
      sensitive_check.to_s == 'true'
    end
  end
end
