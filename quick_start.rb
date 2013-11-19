require 'bundler'
Bundler.require

class QuickStart < Sinatra::Base
  configure :development do
    require 'sinatra/reloader'
    register Sinatra::Reloader
  end

  enable :sessions
  set :public_folder, Proc.new { File.join(root, "static") }

  before do
    if ENV['MONGOHQ_URL'] =~ /^mongodb:\/\//
      redirect "/test_connection_string"
    end
  end

  get "/" do
    redirect "/welcome"
  end

  get "/welcome" do
    haml :welcome
  end

  get "/create-mongohq-account" do
    haml :create_mongohq_account
  end

  get "/create-mongohq-database" do
    haml :create_mongohq_database
  end

  get "/add-user-to-mongohq-database" do
    haml :add_user_to_mongohq_database
  end

  get "/add-environmental-variable" do
    @configure_environmental_variable = <<-CODE
> gem install rhc
> rhc setup
> rhc -a mongohq --set-env MONGO_URL=mongodb://my-username:my-password@paulo.mongohq.com:10079/my-database
    CODE

    haml :add_environmental_variable
  end

  get "/test-mongohq-connection" do
    begin
      @checks = []
      @success = false

      if ENV['MONGO_URL'] && ENV['MONGO_URL'] != ''
        @checks << {status: "correct", message: "An environmental variable is set for <span class='code'>MONGO_URL</span>."}

        @db = Moped::Session.connect(ENV['MONGO_URL'])
        @checks << {status: "correct", message: "A correctly formatted <span class='code'>MONGO_URL</span> is provided."}

        @db.command({isMaster: 1})
        @checks << {status: "correct", message: "We've connected to the MongoDB running at your given <class='code'>MONGO_URL</span>."}

        @db["system.namespaces"].find().each { |i| i } # hack to actually execute the query

        @checks << {status: "correct", message: "We've authenticated and queried against the database."}

        @db["congratulations"].insert({name: "Congratulations from MongoHQ! You've connected, and are on your way to using your database."})

        @checks << {status: "correct", message: "A document has been added to the congratulations collection for your database.  View it from the MongoHQ console."}

        @success = true
      else
        @checks << {status: "error", message: "No environmental variable is set for <span class='code'>MONGO_URL</span>", link: "/add-environmental-variable"}
      end

      haml :test_mongohq_connection
    rescue Moped::Errors::InvalidMongoURI
      @checks << {status: "error", message: <<-MESSAGE, link: "/add-environmental-variable"}
Improperly formatted <span class='code'>MONGO_URL</span>.  Your connection string is:</p>

<span class='code'>#{ENV['MONGO_URL']}</span>

<p>A proper connections string looks like:</p>

<span class='code'>mongodb://username:password@host:port/database-name</span>
      MESSAGE

      haml :test_mongohq_connection
    rescue Moped::Errors::ConnectionFailure
      @checks << {status: "error", message: <<-MESSAGE, link: "/add-environmental-variable"}
No Mongo accessible at <span class='code'>MONGO_URL</span>.  Your connection string is:</p>

<span class='code'>#{ENV['MONGO_URL']}</span>

<p>To resolve, double check the <span class='code'>host:port</span> portion of the connection string that is formatted like so:</p>

<span class='code'>mongodb://username:password@host:port/database-name</span>

<p>This error means the application cannot connect to a Mongo running at the given <span class='code'>host:port</span>.</p>
      MESSAGE

      haml :test_mongohq_connection
    rescue Moped::Errors::QueryFailure
      error = $1.to_i if $!.message =~ /error ([0-9]+):/

      case error
      when 16550
      @checks << {status: "error", message: <<-MESSAGE, link: "/add-user-to-mongohq-database"}
The following error was returned when querying your database:
<pre>
#{$!.message}
</pre>

Typically, this is a username / password error.
      MESSAGE

      haml :test_mongohq_connection

      else
        raise error.inspect
      end
    rescue Moped::Errors::AuthenticationFailure
      @checks << {status: "error", message: <<-MESSAGE, link: "/add-user-to-mongohq-database"}
Authentication failed for given <span class='code'>MONGO_URL</span>.  Your connection string is:</p>

<span class='code'>#{ENV['MONGO_URL']}</span>

<p>To resolve, double check the <span class='code'>username:password</span> portion of the connection string that is formatted like so:</p>

<span class='code'>mongodb://username:password@host:port/database-name</span>

<p>This error message means the connection succeeded, but the authentication failed.</p>
      MESSAGE

      haml :test_mongohq_connection
    end
  end
end
