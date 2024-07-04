module Admin
  class MirrorsController < Admin::ApplicationController
    # Overwrite any of the RESTful controller actions to implement custom behavior
    # For example, you may want to send an email after a foo is updated.
    #
    # def update
    #   super
    #   send_foo_updated_email(requested_resource)
    # end

    def create
      mirror_params[:mirror_source_id] = mirror_params[:mirror_source_id].to_i
      mirrorable = mirror_params[:mirrorable_type].classify.constantize.find_by(id: mirror_params[:mirrorable_id])
      mirror = mirrorable.build_mirror(mirror_params)
      mirror.user = mirrorable.creator

      if mirror.save
        redirect_to admin_mirrors_path, notice: "Mirror was successfully created."
      else
        redirect_to new_admin_mirror_path, alert: "Mirror was not created."
      end
      rescue Exception => e
      redirect_to new_admin_mirror_path, alert: e.to_s
    end

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

    def mirror_params
      params.require(:mirror).permit(:source_url, :mirror_source_id, :username, :access_token, :mirrorable_type, :mirrorable_id)
    end
  end
end
