module Admin
  class Base < ApplicationController
    before_filter :ensure_founders!
    
    private 
      def ensure_founders!
        if ['production', 'staging'].include? Rails.env
          redirect_to "/databases" unless emails.included? current_user.email
        else
          return true
        end
      end
      
      def emails
        ["founders@gridkick.com", "westonplatter@gmail.com"]
      end
  
  end
end
