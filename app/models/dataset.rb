class Dataset < ApplicationRecord
  attr_accessor :skip_create_callback

  enum :visibility, { dataset_public: 'public', dataset_private: 'private' }, default: :dataset_private

  belongs_to :owner, polymorphic: true
  belongs_to :creator, class_name: 'User', foreign_key: :creator_id
  has_many :discussions, as: :discussionable, dependent: :destroy
  has_one :mirror, as: :mirrorable

  after_create :sync_created_dataset_to_starhub_server
  after_destroy :delete_dataset_from_starhub_server
  before_save :detect_sensitive_content
  after_update :update_starhub_server_dataset

  skip_callback :create, :after, :sync_created_dataset_to_starhub_server, if: :skip_create_callback

  validates :name, format: { with: NAME_RULE }

  validates :name, uniqueness: { scope: [:owner_type, :owner_id], case_sensitive: false }

  def path
    "#{owner.name}/#{name}"
  end

  def as_json options=nil
    {
      id: id,
      name: name,
      nickname: nickname,
      desc: desc,
      visibility: visibility,
      license: license,
      path: path,
      updated_at: updated_at
    }
  end

  private

  def sync_created_dataset_to_starhub_server
    res = Starhub.api(creator.session_ip).create_dataset(creator.name,
                                                         name,
                                                         owner.name,
                                                         nickname,
                                                         desc,
                                                         { license: license, private: dataset_private?  })
    raise StarhubError, res.body unless res.success?
  end

  def update_starhub_server_dataset
    res = Starhub.api(creator.session_ip).update_dataset(creator.name,
                                                         name,
                                                         owner.name,
                                                         nickname,
                                                         desc,
                                                         { private: dataset_private?,
                                                           current_user: creator&.name
                                                         })
    raise StarhubError, res.body unless res.success?
  end

  def delete_dataset_from_starhub_server
    res = Starhub.api(creator.session_ip).delete_dataset(owner.name, name, {current_user: creator.name})
    raise StarhubError, res.body unless res.success?
  end

  def detect_sensitive_content
    Starhub.api(creator.session_ip).text_secure_check('nickname_detection', name)
  end
end
