module Jekyll
  class CollapsibleTagBlock < Liquid::Block

    def render(context)
      text = super
      "<button class=\"collapsible\">Show solution</button>"
      "<div class=\"collapsible-content\">""
        #{text}
      </div>"
    end

  end
end

Liquid::Template.register_tag('collapsible', Jekyll::CollapsibleTagBlock)