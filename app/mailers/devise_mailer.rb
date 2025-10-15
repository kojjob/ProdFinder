class DeviseMailer < Devise::Passwordless::Mailer
  def confirmation_instructions(record, token, opts = {})
    @token = token
    @resource = record
    @scope_name = Devise::Mapping.find_scope!(record)

    template_path = "devise/mailer"
    mail(to: record.email, subject: "Confirmation instructions - ProdFinder", template_path: template_path)
  end

  def magic_link(record, token, opts = {})
    @token = token
    @resource = record
    @scope_name = Devise::Mapping.find_scope!(record)

    template_path = "devise/mailer"
    mail(to: record.email, subject: "Magic link - ProdFinder", template_path: template_path)
  end

  def passwordless_login(record, token, opts = {})
    @token = token
    @resource = record
    @scope_name = Devise::Mapping.find_scope!(record)

    template_path = "devise/mailer"
    mail(to: record.email, subject: "Sign in to ProdFinder", template_path: template_path)
  end
end
