enable :sessions

# Root page
get '/' do
  # Look in app/views/index.erb
  @users = User.all
  erb :index
end

# Display a form for creating a new user
get '/users/new' do
  erb :create_user
end

# Create a new user
post '/users/new' do
  new_user = User.new(:name => params[:user_name], :email => params[:email], :password => params[:password])

  user_created = new_user.save

  if user_created
    default_album = Album.new(:name => "#{new_user.name}'s Uncategorized Photos", :is_default => true)
    new_user.albums << default_album

    new_user.save

    session.clear

    session[:user_id] = new_user.id
    redirect to "/"
  else
    redirect to "/users/new"
  end
end

# Display the login form
get '/login' do
  erb :login_page
end

# Log the user in if they entered valid information
post '/login' do
  session.clear
  user = User.authenticate(params[:email], params[:password])

  if user.nil?
    redirect to "/login"
  else
    session[:user_id] = user.id

    redirect to "/"
  end
end

# Logout
get '/logout' do
  session.clear

  redirect to '/'
end

# Display the form to upload an image
get '/photo/new' do
  redirect to '/' if session[:user_id].nil?

  erb :upload_image_page
end

# Upload a specified image from the local machine
post '/photo/new' do
  redirect to '/' if session[:user_id].nil?

  current_user = User.where("id = ?", session[:user_id]).first

  if current_user.nil?
    redirect to '/'
  end

  image_path = params[:image_file_path]
  album_name = params[:album_name]

  File.open("public/images/" + image_path[:filename], "w") do |f|
    f.write(image_path[:tempfile].read)
  end

  file_name = image_path[:filename]

  if album_name.nil? || album_name == ""
    album = current_user.albums.where("is_default = ?", true).first
  else
    album = current_user.albums.where("name = ?", album_name).first #Album.where("name = ?", album_name).first
  end

  if album.nil?
    album = Album.create(:name => album_name)
    current_user.albums << album

    current_user.save
  end

  new_photo = Photo.new(:path => file_name)
  album.photos << new_photo

  album.save

  redirect to "/"
end

# View a list of all albums uploaded by the user with user_id
get '/users/:user_id/albums' do
  @user_to_view = User.find(params[:user_id])

  erb :users_albums_page
end

# View all photos in the album with album_id
get '/albums/:album_id' do
  @album = Album.find(params[:album_id])
  @photos = @album.photos
  erb :display_album_page
end

# View the photo with photo_id
get '/photos/:photo_id' do
  @photo = Photo.find(params[:photo_id])
  erb :display_photo
end





















