require 'redmine'
require 'redmine_ckeditor'

Rails.application.config.to_prepare do
  RedmineCkeditor.apply_patch
end

Redmine::Plugin.register :redmine_ckeditor do
  name 'Redmine CKEditor plugin'
  author 'Akihiro Ono'
  description 'This is a CKEditor plugin for Redmine'
  version '1.1.5'
  requires_redmine :version_or_higher => '3.0.0'
  url 'http://github.com/a-ono/redmine_ckeditor'

  settings(:partial => 'settings/ckeditor')

  wiki_format_provider 'CKEditor', RedmineCkeditor::WikiFormatting::Formatter,
    RedmineCkeditor::WikiFormatting::Helper
end

Loofah::HTML5::WhiteList::ALLOWED_PROTOCOLS.replace RedmineCkeditor.allowed_protocols
