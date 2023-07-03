class UserMailer < GenericMailer
  add_template_helper ApplicationHelper

  layout "user_mailer"

  def user_activation_mail(options)
    set_mailer_smtp(::Settings.smtp)
    @user = options[:user] || {}
    prepare_generic_email(options)
  end

  def user_reset_password_mail(options)
    set_mailer_smtp(::Settings.smtp)
    @user = options[:user] || {}
    prepare_generic_email(options)
  end

  def user_expire_password_mail(options)
    set_mailer_smtp(::Settings.smtp)
    @user = options[:user] || {}
    prepare_generic_email(options)
  end

  def user_authorize_device_mail(options)
    set_mailer_smtp(::Settings.smtp)
    @user = options[:user] || {}
    @device = options[:device] || {}
    prepare_generic_email(options)
  end

  def user_recover_two_factor_mail(options)
    set_mailer_smtp(::Settings.smtp)
    @user = options[:user] || {}
    @qr_img = options[:qr_img] || {}
    inline_attachment('qr_img.png', @qr_img.split(",")[1])
    prepare_generic_email(options)
  end

  private

  def inline_attachment(name, content)
    attachments.inline[name] = Base64.decode64(content)
  end
end
