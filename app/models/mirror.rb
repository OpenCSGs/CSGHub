class Mirror < ApplicationRecord
  belongs_to :user
  belongs_to :mirrorable, polymorphic: true

  validates_presence_of :source_url, :mirror_source_id, :mirrorable_type, :mirrorable_id

  enum :mirrorable_type, Model: 'Model', Dataset: 'Dataset', Code: 'Code', Space: 'Space'

  after_create :sync_created_mirror_to_starhub_server
  after_destroy :delete_mirror_from_starhub_server

  private

  def sync_created_mirror_to_starhub_server
    Starhub.api(user.session_ip).create_mirror(mirrorable_type.downcase,
                                               mirrorable.owner.name,
                                               mirrorable.name,
                                               { source_url: source_url,
                                               mirror_source_id: mirror_source_id,
                                               password: access_token,
                                               username: username,
                                               current_user: user.name })
  end

  def delete_mirror_from_starhub_server
    Starhub.api(user.session_ip).delete_mirror(mirrorable_type.downcase,
                                              mirrorable.owner.name,
                                              mirrorable.name,
                                              { current_user: user.name })
  end
end
