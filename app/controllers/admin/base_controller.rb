class Admin::BaseController < ApplicationController
  include Pagy::Backend

  ADMIN_USER = ENV.fetch("ADMIN_USER", "naar_admin")
  ADMIN_PASS = ENV.fetch("ADMIN_PASS", "naar2026!")

  http_basic_authenticate_with(name: ADMIN_USER, password: ADMIN_PASS)
  layout "admin"
end
