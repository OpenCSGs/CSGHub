class Code < ApplicationRecord
  enum :visibility, { code_public: 'public', code_private: 'private' }, default: :code_private

  belongs_to :owner, polymorphic: true
  belongs_to :creator, class_name: 'User', foreign_key: :creator_id
  has_many :discussions, as: :discussionable, dependent: :destroy

  after_create :sync_created_code_to_starhub_server
  after_destroy :delete_code_from_starhub_server
  after_update :update_starhub_server_code
  before_save :detect_sensitive_content

  validates :name, format: { with: /\A(?=.{2,70}$)(?!.*[_]{2})(?!.*[-]{2})(?!.*[.]{2})[a-zA-Z0-9_.-]+\Z/ }

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

  def sync_created_code_to_starhub_server
    res = Starhub.api.create_code(creator.name,
                                  name,
                                  owner.name,
                                  nickname,
                                  desc,
                                  { license: license,
                                    private: code_private? })
    raise StarhubError, res.body unless res.success?
  end

  def delete_code_from_starhub_server
    res = Starhub.api.delete_code(owner.name, name, { current_user: owner.name })
    raise StarhubError, res.body unless res.success?
  end

  def update_starhub_server_code
    res = Starhub.api.update_code(creator.name,
                                   name,
                                   owner.name,
                                   nickname,
                                   desc,
                                   { private: code_private? })
    raise StarhubError, res.body unless res.success?
  end

  def detect_sensitive_content
    Starhub.api.text_secure_check('nickname_detection', name)
  end
end
