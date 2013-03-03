# -*- coding: utf-8 -*-
require 'pry'

Plugin.create :mikutter_osakana do
  aa = open(File.expand_path('../aa.text', __FILE__)).read.chomp

  command(
    :osakana_tweet,
    name: 'おさかなといっしょにつぶやく',
    condition: Plugin::Command[:Editable],
    visible: false,
    role: :postbox
  ) do |opt|
    buff = Plugin.create(:gtk).widgetof(opt.widget).widget_post.buffer
    buff.text = aa + buff.text
    opt.widget.post_it!
  end
end
