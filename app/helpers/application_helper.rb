module ApplicationHelper
  def bootstrap_class_for(flash_type)
    { success: 'alert-success', error: 'alert-danger', alert: 'alert-warning',
      notice: 'alert-info' }[flash_type.intern] || flash_type.to_s
  end

  def flash_messages(_opts = {})
    flash.each do |msg_type, message|
      concat(content_tag(:div, message, class: "alert #{bootstrap_class_for(msg_type)} fade in") do
               concat content_tag(:button, 'x', class: 'close', data: { dismiss: 'alert' })
               concat message
             end)
    end
    nil
  end

  # check if user if authenticated
  def authenticated?
    @current_user
  end

  def admin?
    @current_user && @current_user.admin?
  end

  # takes an 24 hour integer and formcats it into "HHam/pm".
  # like 13 => 1pm
  def hour_integer_to_humanized(time)
    Time.strptime(time.to_s, '%H').strftime('%l%P')
  end

  # take a time and returns string that
  # represents a one hour time range
  def hour_integer_to_range(time)
    startt = Time.strptime(time.to_s, '%H').strftime('%l-')
    endt = Time.strptime((time + 1).to_s, '%H').strftime('%l:%M %P')
    "#{startt}#{endt}"
  end

  # this returns the css class used in the cell of the avail table
  def avail_table_cell_status(form, value)
    form.object.day_times.include?(value) ? 'success' : 'warning'
  end

  def availablity_table(form)
    thead = content_tag(:thead) do
      content_tag(:tr) do
        concat content_tag(:th, '', class: 'time-label')
        AvailableTime.days.keys.collect { |d| concat content_tag(:th, d.capitalize) }
      end
    end

    tbody = content_tag :tbody do
      (0..23).collect do |hour|
        concat(content_tag(:tr, class: 'table-active') do
          concat(content_tag(:td, class: 'time-label') do
            content_tag(:span) { hour_integer_to_humanized(hour) }
          end)
          AvailableTime.days.collect do |day|
            concat(
              form.input(:day_times, include_hidden: false, label: false, wrapper: false) do
                form.collection_check_boxes :day_times, ["#{day.last}-#{hour}"],
                                            :to_s, :to_s, include_hidden: false, multiple: true do |cb|
                  content_tag(:td, id: "avail-#{day.last}-#{hour}", class: "#{avail_table_cell_status(form, cb.object)} avail-cell") do
                    cb.label { cb.check_box }
                  end
                end
              end
            )
          end
        end)
      end
    end
    content_tag(:table, class: "table table-bordered #{form.object.current_step}-availability-table", id: 'availability-table') { thead.concat(tbody) }
  end

  def login_label
    if authenticated?
      '<b>Review Applications</b>'.html_safe
    else
      '<b>Staff Sign-In</b>'.html_safe
    end
  end
end
