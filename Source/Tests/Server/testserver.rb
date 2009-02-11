require 'rubygems'
require 'sinatra'
require 'sequel'
require 'json'
require 'faker'

# connect to an in-memory database
DB = Sequel.sqlite

# setup a persons table
DB.create_table :people do
  primary_key :id
  column :name, :text
  column :email, :text
  column :bio, :text
  column :address, :text
  column :telephone, :text
  column :created_at, :date
end

class Sequel::Model
  def to_json
    values.to_json
  end
end
# simple person model
class Person < Sequel::Model
  validates_presence_of :name, :email, :address
  
  def self.respond(params)
    #edit or create
    if params[:id]
      person = self.find(params[:id])
    else
      person = self.new
    end
    puts params.inspect
    data = JSON.parse(params[:data])
    if person.update(data)
      {:status => 200, :name => person.name}
    else
      {:status => 500}
    end
  end
end

# create some records using Faker
10.times do
  Person.create({
    :name => Faker::Name.name,
    :email => Faker::Internet.email,
    :address => Faker::Address.street_address,
    :telephone => Faker::PhoneNumber.phone_number,
    :bio => Faker::Lorem.paragraph,
    :created_at => Time.now
  })
end

# Set every request to JSON
before do
  content_type 'application/json'
end

#GET /status/500 returns the given status code
get '/status/:code' do
  status params[:code].to_i
end

get '/search' do
  Person.find('id > ?', params[:limit]).to_json
end

#GET /people returns all posts as json
get '/people' do
  Person.all.to_json
end
 
#GET /person/1 returns that post as json
get '/person/:id' do
  Person.find(params[:id]).to_json
end
 
#PUT /person/1 update that puts with json
put '/person/:id' do
  Person.respond(params).to_json
end
 
#POST /post body with data field set to JSON: { "title": "test", "body": "body test" }
post '/person' do
  st = Person.respond(params)
  status st[:status]
  st.to_json
end
 
#DELETE /post/1 deletes post
delete '/person/:id' do
  person = Person.find(params[:id])
  ok if person.destroy
end