require File.expand_path(File.dirname(__FILE__) + '/common')

describe "default plugins" do
  it_should_behave_like "in-process server selenium tests"

  before(:each) do
    user_logged_in
    Account.site_admin.add_user(@user)
  end

  it "should allow configuring twitter plugin" do
    settings = Canvas::Plugin.find(:twitter).try(:settings)
    settings.should be_nil

    Twitter.stubs(:config_check).returns("Bad check")
    get "/plugins/twitter"

    f("#plugin_setting_disabled").click
    wait_for_ajaximations
    f("#settings_api_key").send_keys("asdf")
    f("#settings_secret_key").send_keys("asdf")
    submit_form('#new_plugin_setting')

    assert_flash_error_message /There was an error/

    Twitter.stubs(:config_check).returns(nil)

    submit_form('#new_plugin_setting')
    wait_for_ajax_requests

    assert_flash_notice_message /successfully updated/

    settings = Canvas::Plugin.find(:twitter).try(:settings)
    settings.should_not be_nil
    settings[:api_key].should == 'asdf'
    settings[:secret_key].should == 'asdf'
  end

  it "should allow configuring etherpad plugin" do
    settings = Canvas::Plugin.find(:etherpad).try(:settings)
    settings.should be_nil

    get "/plugins/etherpad"
    get "/plugins/etherpad"

    f("#plugin_setting_disabled").click
    wait_for_ajaximations
    f("#settings_domain").send_keys("asdf")
    submit_form('#new_plugin_setting')

    assert_flash_error_message /There was an error/

    f("#settings_name").send_keys("asdf")
    submit_form('#new_plugin_setting')
    wait_for_ajax_requests

    assert_flash_notice_message /successfully updated/

    settings = Canvas::Plugin.find(:etherpad).try(:settings)
    settings.should_not be_nil
    settings[:domain].should == 'asdf'
    settings[:name].should == 'asdf'
  end

  it "should allow configuring google docs plugin" do
    settings = Canvas::Plugin.find(:google_docs).try(:settings)
    settings.should be_nil

    GoogleDocs.stubs(:config_check).returns("Bad check")
    get "/plugins/google_docs"

    f("#plugin_setting_disabled").click
    wait_for_ajaximations
    f("#settings_api_key").send_keys("asdf")
    f("#settings_secret_key").send_keys("asdf")
    submit_form('#new_plugin_setting')

    assert_flash_error_message /There was an error/

    GoogleDocs.stubs(:config_check).returns(nil)
    submit_form('#new_plugin_setting')
    wait_for_ajax_requests

    assert_flash_notice_message /successfully updated/

    settings = Canvas::Plugin.find(:google_docs).try(:settings)
    settings.should_not be_nil
    settings[:api_key].should == 'asdf'
    settings[:secret_key].should == 'asdf'
  end

  it "should allow configuring linked in plugin" do
    settings = Canvas::Plugin.find(:linked_in).try(:settings)
    settings.should be_nil

    LinkedIn.stubs(:config_check).returns("Bad check")
    get "/plugins/linked_in"

    f("#plugin_setting_disabled").click
    wait_for_ajaximations
    f("#settings_api_key").send_keys("asdf")
    f("#settings_secret_key").send_keys("asdf")
    submit_form('#new_plugin_setting')

    assert_flash_error_message /There was an error/

    LinkedIn.stubs(:config_check).returns(nil)
    submit_form('#new_plugin_setting')
    wait_for_ajax_requests

    assert_flash_notice_message /successfully updated/

    settings = Canvas::Plugin.find(:linked_in).try(:settings)
    settings.should_not be_nil
    settings[:api_key].should == 'asdf'
    settings[:secret_key].should == 'asdf'
  end

  it "should allow configuring scribd plugin" do
    settings = Canvas::Plugin.find(:scribd).try(:settings)
    settings.should be_nil

    ScribdAPI.stubs(:config_check).returns("Bad check")
    get "/plugins/scribd"

    f("#plugin_setting_disabled").click

    f("#settings_api_key").send_keys("asdf")
    f("#settings_secret_key").send_keys("asdf")
    keep_trying_until {
      submit_form('#new_plugin_setting')
      wait_for_ajaximations
      assert_flash_error_message /There was an error/
    }

    ScribdAPI.stubs(:config_check).returns(nil)
    submit_form('#new_plugin_setting')
    wait_for_ajax_requests

    assert_flash_notice_message /successfully updated/

    settings = Canvas::Plugin.find(:scribd).try(:settings)
    settings.should_not be_nil
    settings[:api_key].should == 'asdf'
    settings[:secret_key].should == 'asdf'
  end

  it "should allow configuring tinychat plugin" do
    settings = Canvas::Plugin.find(:tinychat).try(:settings)
    settings.should be_nil

    Tinychat.stubs(:config_check).returns("Bad check")
    get "/plugins/tinychat"

    f("#plugin_setting_disabled").click
    wait_for_ajaximations
    f("#settings_api_key").send_keys("asdf")
    f("#settings_secret_key").send_keys("asdf")
    submit_form('#new_plugin_setting')

    assert_flash_error_message /There was an error/

    Tinychat.stubs(:config_check).returns(nil)
    submit_form('#new_plugin_setting')
    wait_for_ajax_requests

    assert_flash_notice_message /successfully updated/

    settings = Canvas::Plugin.find(:tinychat).try(:settings)
    settings.should_not be_nil
    settings[:api_key].should == 'asdf'
    settings[:secret_key].should == 'asdf'
  end
end

