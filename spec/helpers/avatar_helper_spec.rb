require 'spec_helper'

describe AvatarHelper do
  before(:all) do
    @me = Factory.build(:normal_person, :first_name => "My", :last_name => "Self")
    @me.id = 1
    @registered_user = Factory.build(:registered_user, :first_name => "Someone", :last_name => "Else", :id => 13)
    @registered_user.id = 13
    @invalid_registered_user = Factory.build(:registered_user, :first_name => "Someone", :last_name => "Bad")
    @invalid_registered_user.id = 4
    @amazon_config = YAML.load_file( File.join(Rails.root, "config", "amazon_s3.yml"))[Rails.env]
  end

  context "link to profile" do
    it "should link to my private page" do
      helper.stub(:current_person).and_return(@me)
#      helper.should_receive(:user_profile).and_return("/user/")

      helper.link_to_profile(@me) do
        "blah"
      end.should =~ /\<a href="\S*\/user\/1" title="My Self">blah<\/a>/i
    end

    it "should like to go to a persons public page" do
      helper.stub(:current_person).and_return(@registered_user)
#      helper.should_receive(:user_profile).and_return("/user/13")

      helper.link_to_profile(@registered_user) do
        "blah"
      end.should =~ /\<a href="\S*\/user\/13" title="Someone Else">blah<\/a>/i
    end
  end

  context "text profile" do
    it "should display a users name with a link" do
      helper.stub(:current_person).and_return(@me)
#      helper.should_receive(:user_profile).with("user/#{@registered_user.id}").and_return("/user/#{@registered_user.id}")

      @registered_user.avatar.url(:standard).gsub(/\?\d*/, '').should == "http://s3.amazonaws.com/#{@amazon_config['bucket']}/avatars/13/standard/test_image.jpg"
      @registered_user.avatar.stub(:url).and_return("http://avatar_url")

      helper.text_profile(@registered_user).should =~ /\<a href="\S*\/user\/13" title="Someone Else">Someone Else<\/a>/i
    end
  end
  
  context "profile image" do
    it "should use the facebook_profile_image if user is authenticated to facebook and useh has no avatar" do
      @auth = mock_model(Authentication, :uid => 12345)
      @me.stub(:facebook_authentication).and_return(@auth)
      @me.stub(:facebook_authenticated?).and_return(true)
      @me.stub(:avatar?).and_return(false)
      helper.should_receive(:facebook_profile_image)
      helper.profile_image(@me, 80)
    end
    
    it "should use local profile image if user is not connected with facebook" do
      helper.should_receive(:local_profile_image)
      helper.profile_image(@me, 80)      
    end
  end
  
  context "local profile image" do
    it "should display a profile image with the default size" do
      @me.avatar.url(:standard).gsub(/\?\d*/, '').should == "http://s3.amazonaws.com/#{@amazon_config['bucket']}/avatars/1/standard/test_image.jpg"
      
      @me.avatar.stub(:url).and_return("http://avatar_url")
      helper.profile_image(@me).should == "<img alt=\"My Self\" height=\"20\" src=\"http://avatar_url\" title=\"My Self\" width=\"20\" />"
    end

    it "should display a profile image with a size of 80" do
      @me.avatar.stub(:url).and_return("http://avatar_url")
      helper.profile_image(@me, 80).should == "<img alt=\"My Self\" height=\"80\" src=\"http://avatar_url\" title=\"My Self\" width=\"80\" />"
    end
  end
  
  context "avatar profile" do

    context "should display a profile image with a size of 80" do
      it "when there is no PA ID" do
        @me.avatar.stub(:url).and_return("http://avatar_url")
        helper.profile_image(@me, 80).should ==  "<img alt=\"My Self\" height=\"80\" src=\"http://avatar_url\" title=\"My Self\" width=\"80\" />"
      end

    end
  end

  context "facebook profile image" do
    
    it "should display the facebook image if person has facebook auth" do
      @auth = mock_model(Authentication, :uid => 12345)
      @me.stub(:facebook_authentication).and_return(@auth)
      @me.stub(:facebook_authenticated?).and_return(true)
      facebook_profile_image(@me, 80).should == "<img alt=\"My Self\" height=\"80\" src=\"https://graph.facebook.com/12345/picture?type=square\" title=\"My Self\" width=\"80\" />"
    end

    it "should return nil display anything if person has no facebook auth" do
      @me.stub(:facebook_authenticated?).and_return(nil)
      facebook_profile_image(@me, 80).should be_nil
    end

  end
end
