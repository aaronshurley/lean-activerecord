require_relative 'db_connection'
require_relative 'sql_object'

module Searchable
  def where(params)
    wheres = params.keys.map do |attr|
      if params[attr].is_a?(Integer)
        "#{attr} = #{params[attr]}"
      else
        "#{attr} = '#{params[attr]}'"
      end
    end
    where_line = wheres.join(' AND ')

    results = DBConnection.execute(<<-SQL)
    SELECT
      *
    FROM
      #{self.table_name}
    WHERE
      #{where_line}
    SQL

    results.map { |result| new(result) }
  end
end

class SQLObject
  extend Searchable
end
