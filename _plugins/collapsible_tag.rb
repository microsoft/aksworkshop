module Jekyll
  class CollapsibleTagBlock < Liquid::Block

    def render(context)
      contents = super

      # pipe param through liquid to make additional replacements possible
      content = Liquid::Template.parse(contents).render context

      %Q{<button class='toggle-collapsible'>Toggle solution</button><div class='collapsible-content'>@content</div>}

    end

  end
end

Liquid::Template.register_tag('collapsible', Jekyll::CollapsibleTagBlock)