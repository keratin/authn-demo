set :database, 'sqlite://facepage.db'

migration "create users table" do
  database.create_table :users do
    primary_key :id
    integer     :account_id
    string      :email

    index :account_id, unique: true
    index :email, unique: true
  end
end

Keratin::AuthN.config.tap do |config|
  # The base URL of your Keratin AuthN service
  config.issuer = ENV['AUTHN_HOST']

  # The domain of your application
  config.audience = ENV['APPLICATION_DOMAIN']
end

MG = Mailgun::Client.new(ENV['MAILGUN_API_KEY'])
def mail(data)
  MG.send_message(ENV['MAILGUN_DOMAIN'], data)
end

class User < Sequel::Model
end

helpers do
  def logged_in?
    !! current_account_id
  end

  def current_user
    @current_user ||= User[account_id: current_account_id]
  end

  def current_account_id
    Keratin::AuthN.subject_from(request.cookies['authn'])
  end

  def gravatar_url(email, size: 200)
    "https://www.gravatar.com/avatar/#{Digest::MD5.hexdigest(email.downcase.strip)}?size=#{size}"
  end
end

get '/' do
  if logged_in?
    erb :index
  else
    redirect to('/signup')
  end
end

get '/login' do
  erb :login
end

get '/signup' do
  erb :signup
end

post '/signup' do
  if logged_in?
    user = User.create(
      email: params[:user][:email],
      account_id: current_account_id
    )
    redirect to('/')
  else
    erb :signup
  end
end

get '/account' do
  if logged_in?
    erb :account
  else
    redirect to('/signup')
  end
end

# webhook from Keratin AuthN
# normally protected by HTTP Basic Auth over SSL
post '/password_resets' do
  if user = User[account_id: params[:account_id]]
    mail(
      from: 'Keratin Demo <demo@keratin.tech>',
      to: user.email,
      subject: 'Password Reset',
      html: <<-HTML
        <body>
          <p>
            Forget your password?
            <a href="#{url("/password_resets?token=#{params[:token]}")}">
              RESET HERE
            </a>
          </p>
        </body>
      HTML
    )
  end

  200
end

# email landing page
get '/password_resets' do
  @token = params[:token]
  erb :reset
end
