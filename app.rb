require 'sinatra'
require 'sinatra/sequel'
require 'keratin/authn'

set :database, 'sqlite://facepage.db'

migration "create users table" do
  database.create_table :users do
    primary_key :id
    string      :email

    index :email, unique: true
  end
end

Keratin::AuthN.config.tap do |config|
  # The base URL of your Keratin AuthN service
  config.issuer = "https://keratin-authn-demo.herokuapp.com"

  # The domain of your application
  config.audience = 'localhost'
end

class User < Sequel::Model
end

helpers do
  def logged_in?
    !! current_user
  end

  def current_user
    @current_user ||= User[id: nil]
  end

  def gravatar_url(email, size: 200)
    "https://www.gravatar.com/avatar/#{Digest::MD5.hexdigest(current_user.email.downcase.strip)}?size=#{size}"
  end
end

get '/' do
  if logged_in?
    erb :index
  else
    redirect to('/signup')
  end
end

get '/signup' do
  erb :signup
end
