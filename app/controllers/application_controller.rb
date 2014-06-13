class ApplicationController < ActionController::API
  include ActionController::StrongParameters
  include ActionController::ParameterValidation
  include ActionController::MimeResponds

  respond_to :json
end
