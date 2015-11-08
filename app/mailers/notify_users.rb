class NotifyUsers < ApplicationMailer

  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.notify_users.notify.subject
  #
  def notify(organization, user)
    @organization = organization

    mail to: user.email, subject: "Your organization's dashboard is ready"
  end
end
