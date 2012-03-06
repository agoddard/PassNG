require 'RMagick'
require 'sinatra'
require 'data_mapper'
include Magick

DataMapper::setup(:default, "sqlite::memory:")

class Pass
  include DataMapper::Resource
  property :id, Serial
  property :token1, Text, :required => true
  property :token2, Text, :required => true  
  property :data, Text, :required => true
  property :created_at, DateTime
end

DataMapper.finalize.auto_upgrade!

def render_pass(pass)
  width = pass.length*50
  fill = "grey"
  image = Magick::ImageList.new
  image.new_image(width, 100) {self.background_color = fill}    
  text = Magick::Draw.new
  text.pointsize = 40
  text.kerning = 0
  text.text_antialias = true
  text.gravity = Magick::WestGravity
  text.annotate(image, 110,110,100,0, pass) {
    self.fill = ("black")
  }
  image.format = "png"
  return image.to_blob
end

def generate(size)
    chars = ("a".."z").to_a + ("A".."Z").to_a + ("0".."9").to_a - ['1','l','I',0,'O']
    sym = ['!','@','#','$','%','^','&','*']
    pass = ""
    (1..size).each do |i|
      pass << chars[rand(chars.size-1)]
    end
    return pass + sym[rand(sym.size-1)]
end

get '/' do
  path = "/generate/#{rand(36**6).to_s(36)}/#{rand(36**10).to_s(36)}"
  redirect to(path)
end

get '/:token1/:token2' do
  content_type 'image/png'
  lookup = Pass.first(:token1 => params['token1'], :token2 => params['token2'])
  if !lookup
    redirect to '/missing'
  else
    data = lookup[:data]
    lookup.destroy
    render_pass data
  end
end

get '/missing' do
  403
end

error 403 do
  "The URL you entered has doesn't exist"
end
  

get '/generate/:token1/:token2' do
  token1 = params['token1']
  token2 = params['token2']
  #make sure this token combination hasn't been used
  dbtoken = Pass.first(:token1 => token1, :token2 => token2)
  if dbtoken
    redirect('/')
  else
    image_url = "/render/#{token1}/#{token2}"
    user_url = "/#{token1}/#{token2}"
    erb :generate, :locals => { :image_url => image_url, :user_url => user_url}
  end
end

get '/render/:token1/:token2' do
  content_type 'image/png'
  token1 = params['token1']
  token2 = params['token2']
  #make sure this token combination hasn't been used
  dbtoken = Pass.first(:token1 => token1, :token2 => token2)
  if dbtoken
    redirect('/')
  else
    p = Pass.new
    p.token1 = token1
    p.token2 = token2
    p.data = generate(8)
    p.created_at = Time.now
    p.save
  end
  lookup = Pass.first(:token1 => token1, :token2 => token2)
  render_pass lookup[:data]
  
end
  
  
