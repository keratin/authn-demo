set :database, 'sqlite://facepage.db'

migration "create users table" do
  database.create_table :users do
    primary_key :id
    integer     :account_id
    string      :name
    string      :email

    index :account_id, unique: true
    index :email, unique: true
  end
end

Keratin::AuthN.config.tap do |config|
  # The base URL of your Keratin AuthN service
  config.issuer = ENV['AUTHN_URL']

  # The domain of your application
  config.audience = ENV['APP_DOMAINS']

  # client credentials
  config.username = ENV['HTTP_AUTH_USERNAME']
  config.password = ENV['HTTP_AUTH_PASSWORD']

  # Private networking
  config.authn_url = ENV['PRIVATE_AUTHN_URL'] || ENV['AUTHN_URL']
end

MG = Mailgun::Client.new(ENV['MAILGUN_API_KEY'])
def mail(data)
  MG.send_message(ENV['MAILGUN_DOMAIN'], data)
end

class User < Sequel::Model
end

helpers do
  def logged_in?
    !! current_user
  end

  def current_user
    @current_user ||= current_account_id && User[account_id: current_account_id]
  end

  def current_account_id
    Keratin::AuthN.subject_from(request.cookies['facepage'])
  end

  def gravatar_url(email, size: 200)
    "https://www.gravatar.com/avatar/#{Digest::MD5.hexdigest(email.downcase.strip)}?size=#{size}"
  end

  def incomplete_signup?
    current_account_id && !current_user
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
  if incomplete_signup?
    account = Keratin.authn.get(current_account_id).result
    @email = account['username']
  end

  erb :signup
end

post '/signup' do
  redirect to('/') unless incomplete_signup?

  @name = params[:user][:name].to_s
  @email = params[:user][:email].to_s

  @errors = []
  @errors << :name unless @name.length.between?(3, 50)
  @errors << :email unless @email =~ /\A[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,}\z/i
  return erb :signup if @errors.any?

  User.create(
    name: @name,
    email: @email,
    account_id: current_account_id
  )
  Keratin.authn.update(current_account_id, username: @email)

  redirect to('/')
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

# oauth process return page
# this could be:
# * signup
# * login
# * connecting identity
get '/register' do
  if params[:status] == 'failed'
    redirect to('/')
  else
    # use javascript to import session before redirect
    erb :register, layout: false
  end
end
