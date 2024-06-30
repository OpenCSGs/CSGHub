require "administrate/base_dashboard"

class MirrorDashboard < Administrate::BaseDashboard
  # ATTRIBUTE_TYPES
  # a hash that describes the type of each of the model's fields.
  #
  # Each different type represents an Administrate::Field object,
  # which determines how the attribute is displayed
  # on pages throughout the dashboard.
  ATTRIBUTE_TYPES = {
    id: Field::Number,
    source_url: Field::String,
    mirror_source_id: Field::Select.with_options(searchable: true,
                                                 collection: ->(field) { JSON.parse(Starhub.api.get_mirror_sources)['data'].map { |source| [source['source_name'], source['id']] } }),
    username: Field::String,
    access_token: Field::String,
    mirrorable_type: Field::Select.with_options(searchable: true, collection: ->(field) { field.resource.class.send(field.attribute.to_s.pluralize).keys }),
    mirrorable_id: Field::Number,
    created_at: Field::DateTime,
    updated_at: Field::DateTime,
  }.freeze

  # COLLECTION_ATTRIBUTES
  # an array of attributes that will be displayed on the model's index page.
  #
  # By default, it's limited to four items to reduce clutter on index pages.
  # Feel free to add, remove, or rearrange items.
  COLLECTION_ATTRIBUTES = %i[
    id
    source_url
    mirror_source_id
    username
    access_token
    mirrorable_type
    mirrorable_id
  ].freeze

  # SHOW_PAGE_ATTRIBUTES
  # an array of attributes that will be displayed on the model's show page.
  SHOW_PAGE_ATTRIBUTES = %i[
    id
    source_url
    mirror_source_id
    username
    access_token
    mirrorable_type
    mirrorable_id
    created_at
    updated_at
  ].freeze

  # FORM_ATTRIBUTES
  # an array of attributes that will be displayed
  # on the model's form (`new` and `edit`) pages.
  FORM_ATTRIBUTES = %i[
    source_url
    mirror_source_id
    username
    access_token
    mirrorable_type
    mirrorable_id
  ].freeze

  # COLLECTION_FILTERS
  # a hash that defines filters that can be used while searching via the search
  # field of the dashboard.
  #
  # For example to add an option to search for open resources by typing "open:"
  # in the search field:
  #
  #   COLLECTION_FILTERS = {
  #     open: ->(resources) { resources.where(open: true) }
  #   }.freeze
  COLLECTION_FILTERS = {}.freeze

  # Overwrite this method to customize how lead forms are displayed
  # across all pages of the admin dashboard.
end
