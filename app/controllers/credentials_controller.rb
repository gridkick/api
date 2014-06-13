class CredentialsController < ApplicationController
  before_filter :authenticate_user!

  def index
    credentials = [ current_user.iam_user ]
    credentials.compact!
    render :json => credentials
  end
end
