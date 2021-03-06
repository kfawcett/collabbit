# Author::      Eli Fox-Epstein, efoxepstein@wesleyan.edu
# Author::      Dimitar Gochev, dimitar.gochev@trincoll.edu
# Copyright::   Humanitarian FOSS Project (http://www.hfoss.org), Copyright (C) 2009.
# License::     http://www.gnu.org/copyleft/lesser.html GNU Lesser General Public License (LGPL)

class HomeController < AuthorizedController
  
  skip_authorization_filters
  
  def show
    @return_to = params[:return_to] if params[:return_to]
    if methods.include? params[:page]  
      send params[:page].to_sym
    else
      render :action => params[:page]
    end
  end

  def contact_form
    subject = params[:subject]
    body = "FROM: #{params[:contact_email]}\n\n#{params[:message_body]}"
    SignupMailer.deliver_contact_form_notification(subject,body)
    
    flash[:notice] = t('notice.instance.contact_form', :email => params[:contact_email])
    redirect_to '/about'
  end
  
  def new_trial
    SignupMailer.deliver_new_trial_notification(params)
    
    flash[:notice] = t('notice.instance.trial_requested',
                          :email => params[:email],
                          :support => "<a href=\"mailto:#{SETTINGS['host.support_email']}\">support</a>")
                          
    redirect_to '/about'
  end
  
  def demo_login
    @instance = Instance.find_by_short_name SETTINGS['demo.account']
    if @instance.blank?
      redirect_to about_path
    else
      login_as @instance.users.find_by_email(SETTINGS['demo.user'])
      handle_remember_cookie!(true)
      redirect_to "http://#{SETTINGS['demo.account']}.#{SETTINGS['host.base_url']}/overview"
    end
  end

end
