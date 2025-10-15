class DeviseMailer < Devise::Passwordless::Mailer
  def confirmation_instructions(record, token, opts = {})
    @token = token
    @resource = record
    @scope_name = Devise::Mapping.find_scope!(record)

    template_path = "devise/mailer"
    mail(to: record.email, subject: "Confirmation instructions - ProdFinder", template_path: template_path)
  end
end
