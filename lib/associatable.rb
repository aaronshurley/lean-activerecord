require_relative 'searchable'
require 'active_support/inflector'

# to make sure that 'human' pluralizes properly
ActiveSupport::Inflector.inflections do |inflection|
  inflection.plural /^human$/i , "humans"
end

class AssocOptions
  attr_accessor :foreign_key, :class_name, :primary_key

  def model_class
    @class_name.constantize
  end

  def table_name
    model_class.table_name
  end
end

module Associatable
  def belongs_to(name, options = {})
    self.assoc_options[name] = BelongsToOptions.new(name, options)
    define_method(name) do
      options = self.class.assoc_options[name]
      key_val = self.send(options.foreign_key)
      options
        .model_class
        .where(options
        .primary_key => key_val)
        .first
    end
  end

  def has_many(name, options = {})
    self.assoc_options[name] = HasManyOptions.new(name, self.name, options)
    define_method(name) do
      options = self.class.assoc_options[name]
      key_val = self.send(options.primary_key)
      options
        .model_class
        .where(options.foreign_key => key_val)
    end
  end

  def has_one_through(name, through, source)
    define_method(name) do
      through_options = self.class.assoc_options[through]
      source_options =
        through_options.model_class.assoc_options[source]

      through_table = through_options.table_name
      through_primary_key = through_options.primary_key
      through_foreign_key = through_options.foreign_key

      source_table = source_options.table_name
      source_pk = source_options.primary_key
      source_fk = source_options.foreign_key

      key_val = self.send(through_foreign_key)
      results = DBConnection.execute(<<-SQL, key_val)
        SELECT
          #{source_table}.*
        FROM
          #{through_table}
        JOIN
          #{source_table}
        ON
          #{through_table}.#{source_fk} = #{source_table}.#{source_pk}
        WHERE
          #{through_table}.#{through_primary_key} = ?
      SQL

      source_options.model_class.parse_all(results).first
    end
  end

  def assoc_options
    @assoc_options ||= {}
    @assoc_options
  end
end

class BelongsToOptions < AssocOptions
  extend Associatable
  def initialize(name, options = {})
    @class_name = options[:class_name] || name.to_s.singularize.camelcase
    @foreign_key = options[:foreign_key] || class_name.to_s.underscore.concat("_id").to_sym
    @primary_key = options[:primary_key] || :id
  end
end

class HasManyOptions < AssocOptions
  extend Associatable
  def initialize(name, self_class_name, options = {})
    @class_name = options[:class_name] || name.to_s.singularize.camelcase
    @foreign_key = options[:foreign_key] || self_class_name.to_s.underscore.concat("_id").to_sym
    @primary_key = options[:primary_key] || :id
  end
end

class SQLObject
  extend Associatable
end
