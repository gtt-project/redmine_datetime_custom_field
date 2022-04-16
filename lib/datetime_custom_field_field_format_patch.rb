require_dependency 'redmine/field_format'

module Redmine
  module FieldFormat
    Rails.logger.info "o=>inserting DateTimeFormat in Redmine::FieldFormat"

    # Plugin : new class for format
    class DateTimeFormat < Unbounded
      add 'datetime'
      self.form_partial = 'custom_fields/formats/datetime'
      field_attributes :show_hours

      #############################
      # Plugin specific : REWRITTEN
      def cast_single_value(custom_field, value, customized=nil)
        value.to_time rescue nil
      end

      #############################
      # Plugin specific : REWRITTEN
      def validate_single_value(custom_field, value, customized=nil)
        if (
          (value =~ /^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}(:\d{2})?$/) &&
          (value.to_date rescue false)
        )
          []
        else
          [::I18n.t('activerecord.errors.messages.not_a_datetime')]
        end
      end

      #############################
      # Plugin specific : REWRITTEN
      def edit_tag(view, tag_id, tag_name, custom_value, options={})
        # Compared to Date format :
        # - size 10 -> 15
        # - calendar_for -> datetime_for
        view.datetime_local_field_tag(tag_name, custom_value.value, options.merge(:id => tag_id, :step => 1, :value => format_datetime(custom_value.value)))
      end

      #############################
      # Plugin specific : REWRITTEN
      def bulk_edit_tag(view, tag_id, tag_name, custom_field, objects, value, options={})
        # Compared to Date format :
        # - size 10 -> 15
        # - calendar_for -> datetime_for
        view.datetime_local_field_tag(tag_name, value, options.merge(:id => tag_id, :step => 1, :value => format_datetime(custom_value.value))) +
          bulk_clear_tag(view, tag_id, tag_name, custom_field, value)
      end

      # query_filter_options
      #   NOT changed, use method on parent class : considered as a date
    end
  end
end

##########
# OVERRIDE standard Redmine date validator in order to add the dd/mm/YYYY format to the default YYYY-mm-dd
class DateTimeValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    before_type_cast = record.attributes_before_type_cast[attribute.to_s]
    if before_type_cast.is_a?(String) && before_type_cast.present?
      unless (before_type_cast =~ /\A\d{4}-\d{2}-\d{2}T\d{2}:\d{2}(:\d{2})?\z/) && value
        record.errors.add attribute, :not_a_datetime
      end
    end
  end
end
