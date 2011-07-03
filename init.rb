require 'redmine'

require 'dispatcher'
require 'redmine_ckeditor'
Dispatcher.to_prepare do
  RedmineCkeditor.apply_patch
end

Redmine::Plugin.register :redmine_ckeditor do
  name 'Redmine CKEditor plugin'
  author 'Akihiro Ono'
  description 'This is a CKEditor plugin for Redmine'
  version '0.0.6-ebrahim'
  requires_redmine :version_or_higher => '1.1.0'
  url 'http://github.com/ebrahim/redmine_ckeditor'

  settings(:partial => 'settings/ckeditor')

  wiki_format_provider 'CKEditor', RedmineCkeditor::WikiFormatting::Formatter,
    RedmineCkeditor::WikiFormatting::Helper
end
