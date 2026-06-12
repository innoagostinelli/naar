class Admin::BaseController < ApplicationController
  http_basic_authenticate_with(
    name:     ENV.fetch("ADMIN_USER", "naar_admin"),
    password: ENV.fetch("ADMIN_PASS", "naar2026!")
  )
  layout "admin"
end
