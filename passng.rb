require 'RMagick'
require 'sinatra'
require 'digest'
require 'encryptor'
require 'base64'
include Magick


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
  path = "/generate/#{rand(36**40).to_s(36)}"
  redirect to(path)
end

get '/send/:key' do
  # save encrypted key in DB, return token for URL
  token = params['key']
end

# base64 for PoC
get '/:token' do
  content_type 'image/png'
  # lookup token in DB, retun matching encrypted key
  #decrypt key
  #render password as graphic
  render_pass Base64.decode64(params['token'])
end

# random passwords
get '/generate/:token' do
  content_type 'image/png'
  @type = params['type']
  render_pass(generate(8))
end
