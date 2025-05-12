ActiveAdmin.register_page "Dashboard" do
  menu priority: 1, label: proc { I18n.t("active_admin.dashboard") }

  content title: proc { I18n.t("active_admin.dashboard") } do
    div style: "background-color: #f7fafc; padding: 20px; font-family: 'Inter', -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;" do
      columns do
        column do
          panel "User Statistics", style: "background: white; border: 7px solid #FFEFD5; border-radius: 8px; box-shadow: 10 4px 6px rgba(0,0,0,0.05); transition: transform 0.2s;" do
            div style: "background-color: #FFEFD5; color: white; padding: 10px; border-radius: 6px 6px 0 0; margin: -10px -10px 10px -10px;" do
              h3 "User Statistics", style: "margin: 0; font-size: 27px;"
            end
            ul style: "list-style: none; padding: 0; margin: 0;" do
              li style: "padding: 8px 0; border-bottom: 5px solid #FFFACD;" do
                "Total Users: #{User.count}"
              end
              li style: "padding: 12px 0; border-bottom: 5px solid #FFFACD;" do
                "Regular Users: #{User.where(role: 'user').count}"
              end
              li style: "padding: 8px 0;" do
                "Supervisors: #{User.where(role: 'supervisor').count}"
              end
            end
          end
        end

        column do
          panel "Admin Statistics", style: "background: white; border: 10px solid #e2e8f0; border-radius: 8px; box-shadow: 0 4px 6px rgba(0,0,0,0.05); transition: transform 0.2s;" do
            div style: "background-color: #FFFACD; color: white; padding: 10px; border-radius: 6px 6px 0 0; margin: -10px -10px 10px -10px;" do
              h3 "Admin Statistics", style: "margin: 0; font-size: 27px;"
            end
            ul style: "list-style: none; padding: 0; margin: 0;" do
              li style: "padding: 8px 0;" do
                "Total Admins: #{AdminUser.count}"
              end
            end
          end
        end

        column do
          panel "Movie Statistics", style: "background: white; border: 7px solid #7DC4E4; border-radius: 8px; box-shadow: 0 4px 6px rgba(0,0,0,0.05); transition: transform 0.2s;" do
            div style: "background-color: #7DC4E4; color: white; padding: 10px; border-radius: 6px 6px 0 0; margin: -10px -10px 10px -10px;" do
              h3 "Movie Statistics", style: "margin: 0; font-size: 27px;"
            end
            ul style: "list-style: none; padding: 0; margin: 0;" do
              li style: "padding: 8px 0; border-bottom: 3px solid #FFEFD5;" do
                "Total Movies: #{Movie.count}"
              end
              li style: "padding: 8px 0; border-bottom: 3px solid #FFEFD5;" do
                "Premium Movies: #{Movie.where(premium: true).count}"
              end
              li style: "padding: 8px 0; border-bottom: 3px solid #FFEFD5;" do
                "Non-Premium Movies: #{Movie.where(premium: false).count}"
              end
              li style: "padding: 8px 0; border-bottom: 3px solid #FFEFD5;" do
                "Average Rating: #{Movie.average(:rating)&.round(2) || 'N/A'}"
              end
              li style: "padding: 8px 0; border-bottom: 3px solid #FFEFD5;" do
                "Movies by Genre: #{Movie.group(:genre).count.to_h.to_s}"
              end
              li style: "padding: 8px 0;" do
                "Recent Movies: #{Movie.order(release_year: :desc).limit(5).pluck(:title).join(', ')}"
              end
            end
          end
        end
      end
    end

    # Add inline CSS for hover effects
    style do
      raw "
        .panel:hover {
          transform: translateY(-2px);
        }
      "
    end
  end
end