This is a demo app written in Sinatra that uses [Keratin AuthN](https://github.com/keratin/authn) to
manage authentication. The commits are written in tutorial fashion and may be revised over time as
best practices change.

Start here: https://github.com/keratin/authn-demo/commits/master

## Developing

### Installing Dependencies:

1. Install Docker, Ruby, and Bundler
2. Create a `.env` file from `.env.sample`
3. Install Rubygem dependencies: `bundle install`

### Running Processes:

4. Start AuthN server: `./authn`
5. Start Demo app: `bundle exec rackup config.ru`
