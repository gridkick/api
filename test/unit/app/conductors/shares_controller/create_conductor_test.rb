require 'test_helper'

###  controller does not exist

# class SharesController::CreateConductorTest < ActiveSupport::TestCase
#   it 'vivifies a list of emails given a space separated list of emails' do
#     e = [ 'email1@example.com' , 'email2@example.com' ]
#     p = ActionController::Parameters.new( { :emails => e.join( ' ' ) } )
#     u = User.new

#     c = SharesController::CreateConductor.new p , u
#     c.emails.sort.must_equal e.sort
#   end

#   it 'vivifies a list of shares given a space separated list of emails' do
#     e = [ 'email1@example.com' , 'email2@example.com' ]
#     p = ActionController::Parameters.new( { :emails => e.join( ' ' ) } )
#     u = User.new

#     c = SharesController::CreateConductor.new p , u
#     c.create
#     c.shares.wont_be_empty
#     c.shares.all? { | s | s.must_be_a Share }.must_equal true
#   end

#   it 'saves each share' do
#     e = [ 'email1@example.com' , 'email2@example.com' ]
#     p = ActionController::Parameters.new( { :emails => e.join( ' ' ) } )
#     u = User.new

#     Share.any_instance.stubs( :save ).returns true

#     c = SharesController::CreateConductor.create p , u
#     c.save.must_equal true

#     Share.any_instance.unstub :save
#   end
# end
