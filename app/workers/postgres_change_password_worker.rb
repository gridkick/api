class PostgresChangePasswordWorker
  include App::SqlChangePasswordWorker

  def change_password!
    retry_until_finished :change_postgres_password do
      result =
        begin
          connection.exec query_string
        rescue PG::Error => e
          nil
        end

      case result
      when PG::Result
        result.result_status == 1
      else
        false
      end
    end
  end

  def connection
    @_connection ||=
      retry_until_finished :establish_postgres_connection do
        begin
          PG.connect \
            :dbname   => db_name,
            :host     => db_host,
            :password => db_password,
            :port     => db_port,
            :user     => db_username
        rescue PG::Error => e
          false
        end
      end
  end

  def db_name
    'postgres'
  end

  def query_string
    "ALTER USER #{ db_username } WITH PASSWORD '#{ new_random_password }'"
  end
end
