class DeviseMailer < ApplicationMailer
  def magic_link(record, token, opts = {})
    @token = token
    @resource = record
    @scope_name = Devise::Mapping.find_scope!(record)
    @remember_me = opts && opts[:remember_me] || false

    template_path = "devise/mailer"
    mail(to: record.email, subject: "Your magic link - ProdFinder", template_path: template_path)
  end

  def confirmation_instructions(record, token, opts = {})
    @token = token
    @resource = record
    @scope_name = Devise::Mapping.find_scope!(record)

    template_path = "devise/mailer"
    mail(to: record.email, subject: "Confirmation instructions - ProdFinder", template_path: template_path)
  end
end
