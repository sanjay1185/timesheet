require File.dirname(__FILE__) + '/../test_helper'

class UserTest < ActiveSupport::TestCase
  # Be sure to include AuthenticatedTestHelper in test/test_helper.rb instead.
  # Then, you can remove it from this and the functional test.
  include AuthenticatedTestHelper
  fixtures :users

  def test_should_create_user
    assert_difference 'User.count' do
      user = create_user(:login => 'alanjones', :email => 'aj@agency.com', :email_confirmation => 'aj@agency.com')
      assert !user.new_record?, "#{user.errors.full_messages.to_sentence}"
    end
  end

  def test_should_require_login
    assert_no_difference 'User.count' do
      u = create_user(:login => nil)
      assert u.errors.on(:login)
    end
  end

  def test_should_require_password
    assert_no_difference 'User.count' do
      u = create_user(:password => nil)
      assert u.errors.on(:password)
    end
  end

  def test_should_require_password_confirmation
    assert_no_difference 'User.count' do
      u = create_user(:password_confirmation => nil)
      assert u.errors.on(:password_confirmation)
    end
  end

  def test_should_require_email
    assert_no_difference 'User.count' do
      u = create_user(:email => nil)
      assert u.errors.on(:email)
    end
  end

  def test_should_reset_password
    u = users(:aaron)
    u.password = 'new password'
    u.password_confirmation = 'new password'
    u.reset_password
    u.save(false)
    assert_equal users(:aaron), User.authenticate('aaron', 'new password')
  end

  def test_should_not_rehash_password
    users(:aaron).update_attributes(:login => 'aaron')
    assert_equal users(:aaron), User.authenticate('aaron', 'test')
  end

  def test_should_authenticate_user
    assert_equal users(:aaron), User.authenticate('aaron', 'test')
  end

  def test_should_set_remember_token
    users(:aaron).remember_me
    assert_not_nil users(:aaron).remember_token
    assert_not_nil users(:aaron).remember_token_expires_at
  end

  def test_should_unset_remember_token
    users(:aaron).remember_me
    assert_not_nil users(:aaron).remember_token
    users(:aaron).forget_me
    assert_nil users(:aaron).remember_token
  end

  def test_should_remember_me_for_one_week
    before = 1.week.from_now.utc
    users(:aaron).remember_me_for 1.week
    after = 1.week.from_now.utc
    assert_not_nil users(:aaron).remember_token
    assert_not_nil users(:aaron).remember_token_expires_at
    assert users(:aaron).remember_token_expires_at.between?(before, after)
  end

  def test_should_remember_me_until_one_week
    time = 1.week.from_now.utc
    users(:aaron).remember_me_until time
    assert_not_nil users(:aaron).remember_token
    assert_not_nil users(:aaron).remember_token_expires_at
    assert_equal users(:aaron).remember_token_expires_at, time
  end

  def test_should_remember_me_default_two_weeks
    before = 2.weeks.from_now.utc
    users(:aaron).remember_me
    after = 2.weeks.from_now.utc
    assert_not_nil users(:aaron).remember_token
    assert_not_nil users(:aaron).remember_token_expires_at
    assert users(:aaron).remember_token_expires_at.between?(before, after)
  end

protected
  def create_user(options = {})
    record = User.new({ :password => 'test1', :password_confirmation => 'test1',
                        :title => 'Mr', :firstName => 'Bob', :lastName => 'Smith' }.merge(options))
    record.save

    return record

  end
end
