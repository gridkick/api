class MysqlChangePasswordWorker
  include App::SqlChangePasswordWorker

  def change_password!
    retry_until_finished :change_mysql_password do
      results =
        queries.map do | query |
          begin
            connection.query  query
          rescue Exception => e
            e
          end
        end
      
      results.all? { | result | NilClass === result }
    end
  end

  def connection
    @_connection ||=
      retry_until_finished :establish_mysql2_connection do
        begin
          Mysql2::Client.new \
            :host     => db_host,
            :password => db_password,
            :port     => db_port,
            :username => db_username
        rescue Mysql2::Error => e
          false
        end
      end
  end

  def hosts
    %w(
      %
      localhost
    )
  end

  def queries
    @_queries =
      hosts.map do | host |
        query_string % host
      end.concat( terminating_query )
  end

  def query_string
    "UPDATE mysql.user SET Password=password('#{ new_random_password }') WHERE User='#{ db_username }' AND Host='%s';"
  end

  def terminating_query
    [ 'FLUSH PRIVILEGES;' ]
  end
  
  def db_name
    'mysql'
  end
end
