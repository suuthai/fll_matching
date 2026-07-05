admin_creds = Rails.application.credentials.admin!

User.find_or_create_by!(email: admin_creds.email!) do |user|
  user.name = admin_creds.name!
  user.password = admin_creds.password!
  user.role = :admin
end
