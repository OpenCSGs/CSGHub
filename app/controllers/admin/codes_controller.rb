module Admin
  class CodesController < Admin::ApplicationController
    before_action :get_repo_mirror, only: [:show]
    # Overwrite any of the RESTful controller actions to implement custom behavior
    # For example, you may want to send an email after a foo is updated.
    #
    # def update
    #   super
    #   send_foo_updated_email(requested_resource)
    # end

    # Override this method to specify custom lookup behavior.
    # This will be used to set the resource for the `show`, `edit`, and `update`
    # actions.
    #
    # def find_resource(param)
    #   Foo.find_by!(slug: param)
    # end

    # The result of this lookup will be available as `requested_resource`

    # Override this if you have certain roles that require a subset
    # this will be used to set the records shown on the `index` action.
    def scoped_resource
      super.order(updated_at: :desc)
    end

    def sync
      code = get_code params[:code_id]
      Starhub.api.sync_repo_mirror("codes",
                                  code.owner.name,
                                  code.name,
                                  { current_user: code.creator.name })
      flash[:notice] = "Synchronize successfully."
      return redirect_back(fallback_location: root_path)
      rescue Exception => e
      flash[:notice] = e
      redirect_back(fallback_location: root_path)
    end

    # Override `resource_params` if you want to transform the submitted
    # data before it's persisted. For example, the following would turn all
    # empty values into nil values. It uses other APIs such as `resource_class`
    # and `dashboard`:
    #
    # def resource_params
    #   params.require(resource_class.model_name.param_key).
    #     permit(dashboard.permitted_attributes(action_name)).
    #     transform_values { |value| value == "" ? nil : value }
    # end

    # See https://administrate-demo.herokuapp.com/customizing_controller_actions
    # for more information

    private

    def get_repo_mirror
      code = get_code params[:id]
      begin
        data = JSON.parse(Starhub.api.get_repo_mirror("codes",
                                                      code.owner.name,
                                                      code.name,
                                                      { current_user: code.creator.name }))['data']
      rescue
        data = nil
      end
      @last_updated_at = data ? DateTime.parse(data["last_updated_at"]).strftime("%Y-%m-%d %H:%M:%S %z") : nil
      @last_message = data ? data["last_message"] : nil
      @show_updated = data ? true : false
      @show_sync = data && !code.origin.nil? && data["status"] != 'finished' ? true : false
      debugger
    end

    def get_code(code_id)
      code = Code.find_by(id: code_id)
      if code == nil
        return redirect_back(fallback_location: root_path)
      end
      code
    end
  end
end
