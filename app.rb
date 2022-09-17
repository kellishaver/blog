require 'rubygems'
require 'bundler/setup'
require 'sinatra'
require 'kramdown'

def get_post_list
    JSON.parse(File.read('./posts/index.json')).reverse!
end

def get_post_short(id)
  return unless id
  
  md = File.read("./posts/#{id}/short.md")
  Kramdown::Document.new(md).to_html
end

def get_post_full(id)
  return unless id
  
  md = File.read("./posts/#{id}/full.md")
  Kramdown::Document.new(md).to_html
end

@@per_page = 5

get '/' do
  @page = params[:page] ? params[:page].to_i : 1
  @total_pages = (get_post_list.size.to_f / @@per_page.to_f).ceil
  erb :index
end

get '/posts/:id/*' do
  id = params[:id].to_i
  @post = get_post_list.select { |post| post["id"].to_i == id.to_i }&.first
  @body = get_post_full(id)
  erb :post
end

helpers do
  def posts (page: 1)
    first_post = @@per_page * page - @@per_page
    last_post = first_post + @@per_page

    items = get_post_list
    items[first_post...last_post]
  end

  def slug(post)
    "/posts/#{post['id']}/#{post['title'].downcase.strip.gsub(' ', '-').gsub(/[^\w-]/, '')}"
  end
end