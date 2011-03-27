module AvatarHelper
  # Create Avatar and Link for a Users Profile
  def user_profile(person)
    if person
      link_to_profile(person) do
        loggedin_image(person)
      end
    else
      loggedout_image
    end
  end

  def text_profile(person)
    if person
      link_to_profile(person) do
        person.name
      end
    else
      person.name
    end
  end

  def conversation_profile(person)
    avatar_profile(person, 40)
  end

  def contribution_profile(person)
    avatar_profile(person, 40)
  end

  def featured_profile(person)
    avatar_profile(person, 50)
  end

  def local_profile_image(person, size=20, options = {})
    css_class = options.delete(:class)
    image_tag person.avatar.url(:standard), alt: person.name, height: size, width: size, title: person.name, class: css_class
  end
  
  # Use this one if you want to display an image_tag for the profile.
  def profile_image(person, size=20, options = {})
    if person.facebook_authenticated? && !person.avatar?
      facebook_profile_image(person, size, options)
    else
      local_profile_image(person, size, options)
    end
  end  
  
  # Gets image from facebook graph
  # https://graph.facebook.com/#{uid}/picture
  # optional params: type=small|square|large
  # square (50x50), small (50 pixels wide, variable height), and large (about 200 pixels wide, variable height):
  def facebook_profile_image(person, size = 20, options = {})
    type = options.delete(:type) || :square
    css_class = options.delete(:class)
    if person.facebook_authenticated?
      image_tag person.facebook_profile_pic_url(type), alt: person.name, height: size, width: size, title: person.name, class: css_class
    end
  end

  def loggedin_image(person, size=40)
    # image_tag person.avatar.url(:standard), alt: person.name, class: 'callout', height: size, width: size
    profile_image(person, size, :class => 'callout')
  end

  def loggedout_image(size=40)
    image_tag "avatar_#{size}.gif", alt: 'default avatar', class: 'callout', height: size, width: size
  end

  def avatar_profile(person, size=20)
    if person
      link_to_profile(person) do
        profile_image(person, size)
      end
    else
      profile_image(person, size)
    end
  end

  def link_to_profile(person)
    link_to yield, user_url(person), title: person.name
  end

  def link_to_settings(person)
    link_to "Settings", secure_edit_user_url(person), title: "Profile Settings", class: 'user-link'
  end

  # Creates an image_tag for a particular person
  # options includes options passed along to image_tag along with
  # :style_name which is a directive for paperclip which determines the
  # ':style' paperclip should use for the image. 
  #
  def avatar_tag(person, options={})
    style_name = options.delete(:style_name) || :small
    url = person.avatar.url(style_name)
    if request.ssl? then url = url.gsub(/http:/i, 'https:') end
    image_options = {
      :width => 50,
      :height => 50,
      :alt => "avatar",
      :title => person.name}.merge(options)
    image_tag(url, image_options)
  end

end
