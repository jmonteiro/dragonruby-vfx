# Whether the shader effects in lib/vfx/pro/ can run here: they need a Pro
# licence, `shaders=true` in the metadata (bin/pro sets it), and anything but
# a browser.
module Pro
  FILES = ["crt", "shockwave", "dissolve", "luma_wipe"].freeze

  SITE = "https://dragonruby.org".freeze
  LINK = { x: 500, y: 250, w: 280, h: 52 }.freeze

  # `--standard 1` on the command line pretends there is no Pro licence, to
  # see what everyone else sees.
  def self.available?
    if @available.nil?
      pretending = (DR.cli_arguments || {})[:standard]
      @available = DR.version_pro? && !DR.platform?(:web) && shaders_on? && pretending.nil?
    end
    @available
  end

  # What the gallery shows in place of a shader demo that cannot run here: a
  # picture of the effect, why it is missing, and where to get Pro.
  def self.card(args, demo)
    Stage.draw(args.outputs)
    args.outputs.primitives << [
      { x: 256, y: 200, w: 768, h: 432, path: "sprites/pro/#{demo::ID}.png", a: 90 },
      Stage.text(640, 440, "Only available for DragonRuby Pro", size: 38, align: 0.5),
      Stage.text(640, 385, "This effect is a fragment shader. Shaders need a Pro licence", size: 20, color: Stage::GREY, align: 0.5),
      Stage.text(640, 355, "and do not run in the browser.", size: 20, color: Stage::GREY, align: 0.5),
      LINK.merge(path: :solid, r: 255, g: 204, b: 77),
      Stage.text(640, 276, "dragonruby.org", size: 24, color: [24, 28, 44], align: 0.5),
      Stage.text(640, 222, "Have Pro? Start the gallery with bin/pro.", size: 17, color: Stage::GREY, align: 0.5)
    ]
    click = args.inputs.mouse.click
    DR.openurl(SITE) if click && click.inside_rect?(LINK)
  end

  def self.shaders_on?
    setting = DR.args.cvars["game_metadata.shaders"]
    setting && setting.value.to_s == "true"
  end
end
