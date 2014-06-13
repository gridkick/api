require 'test_helper'

# TODO share mailer

# class ShareMailerTest < ActionMailer::TestCase
#   it 'sends new share emails' do
#     from = 'email1@example.com'
#     to = 'email2@example.com'
#     s = Share.new :email => to
#     s.build_user :email => from

#     email = ShareMailer.share_email( s ).deliver

#     ActionMailer::Base.deliveries.must_include email
#     email.from.must_include 'founders@gridkick.com'
#     email.to.must_include to

#     body = email.text_part.body.to_s
#     body.must_match /stack provides Redis/i
#   end
# end
