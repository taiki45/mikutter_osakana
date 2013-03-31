# -*- coding: utf-8 -*-

$LOAD_PATH.unshift File.expand_path('../lib', __FILE__)

require 'account'
require 'level'


module Osakana
  Plugin.create :mikutter_osakana do
    aa = open(File.expand_path('../aa.text', __FILE__)).read.chomp
    pattern = Regexp.new(Regexp.escape(aa))
    me = Account.new
    on_save_do = -> level { Plugin.call(:osakana_saved, level) }
    me.add_callback on: :save, do: on_save_do

    def tell(msg)
      Plugin.call(:update, nil, [Message.new(message: msg, system: true)])
    end

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

    command(
      :osakana,
      name: 'osakana now.',
      condition: Plugin::Command[:Editable],
      visible: true,
      role: :postbox
    ) do |opt|
      buff = Plugin.create(:gtk).widgetof(opt.widget).widget_post.buffer
      buff.text = "#{aa} <#{me.level}れべるなう"
      opt.widget.post_it!
    end

    command(
      :osakana_save,
      name: 'save status.',
      condition: -> _ { true },
      visible: true,
      role: :timeline
    ) do |opt|
      me.save
      tell "saved. current status is level: #{me.level}, exp: #{me.exp}."
    end

    filter_gui_postbox_post do |box|
      buff = Plugin.create(:gtk).widgetof(box).widget_post.buffer
      me.increase :post if buff.text =~ pattern
      [box]
    end

    on_favorite do |service, user, msg|
      me.increase :fav if msg.to_s =~ pattern
      [service, user, msg]
    end

    on_update do |service, msgs|
      msgs.each do |msg|
        me.increase :apper if msg.to_s =~ pattern
      end
      [service, msgs]
    end

    on_period do
      me.save
    end


    targets = (1..10).map {|i| i ** i }

    targets.each_with_index do |target, index|
      depend = index > 0 ? [] : ["osakana_level_#{targets[index - 1]}".to_sym]

      defachievement(
        "osakana_level_#{targets[index]}".to_sym,
        description: "レベルをあげるでし",
        hint: "おさかなといっしょにあそぼ…？",
        depends: depend
      ) do |ach|

        on_osakana_saved do |level|
          if level >= target
            activity :achievement, "レベル#{level}達成おめでとうでし"
            ach.take!
          end
        end
      end

    end
  end
end
