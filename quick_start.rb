require 'bundler'
Bundler.require

class QuickStart < Sinatra::Base
  configure :development do
    require 'sinatra/reloader'
    register Sinatra::Reloader
  end

  enable :sessions
  set :public_folder, Proc.new { File.join(root, "static") }

  CONNECTION_PROCESS = [
    :connection_string_present,
    :connection_string_valid,
    :able_to_connect,
    :able_to_authenticate,
    :able_to_write
  ]

  before do
    @connection_state = get_connection_state
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
    haml :add_environmental_variable
  end

  get "/test-mongohq-connection" do
    haml :test_mongohq_connection
  end

  def get_connection_state
    state_array = []
    CONNECTION_PROCESS.map do |step|
      if send("test_#{step}".to_sym, ENV['MONGO_URL'])
        state_array << step
      else
        break
      end
    end

    @connection_success = state_array == CONNECTION_PROCESS

    state_array
  end

  #
  # Series of tests for the presence and validity of the MONGO_URL
  #
  def test_connection_string_present(uri)
    uri && uri != ''
  end

  def test_connection_string_valid(uri)
    uri =~ Moped::MongoUri::URI
  end

  def test_able_to_connect(uri)
    Timeout::timeout(5) do
      uri_without_auth = uri.gsub(/\/[^\:\\]+:[^\:\@]+\@/, '//')
      s = Moped::Session.connect(uri_without_auth + "?timeout=5")
      s.command({isMaster: 1})
    end
  rescue
    false
  end

  def test_able_to_authenticate(uri)
    Timeout::timeout(5) do
      s = Moped::Session.connect(uri + "?timeout=5")
      s["system.namespaces"].find().count()
    end
  rescue
    false
  end

  def test_able_to_write(uri)
    Timeout::timeout(5) do
      s = Moped::Session.connect(uri + "?safe=true&timeout=5")
      s["congratulations"].insert({name: "Congratulations from MongoHQ! You've connected, and are on your way to using your MongoHQ database."})
    end
  rescue
    false
  end
end
