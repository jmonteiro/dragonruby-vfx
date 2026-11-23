# The gallery: one demo on screen at a time, with its name, a line about it and
# its controls. Demos play by themselves until the visitor touches something.
#
# Command line:  --demo <id>   start on that demo
#                --shots 1     save shots/<id>.png for every demo, then quit
#                --film 1      save every other frame of every demo to film/<id>/, then quit
#                --only 1      with --shots or --film: stop after the first demo
module Gallery
  DEMOS = [Demos::Shake, Demos::HitStop, Demos::CameraFx, Demos::Squash, Demos::Particles, Demos::Trail,
           Demos::Transition, Demos::Lights, Demos::Fog, Demos::RgbSplit, Demos::Pixelate, Demos::Film,
           Demos::Silhouette, Demos::DamageNumbers, Demos::Lightning, Demos::Ribbon, Demos::Decals,
           Demos::Weather, Demos::Parallax, Demos::Slices, Demos::Warp, Demos::Shadows].freeze

  PREVIOUS = { x: 16, y: 668, w: 52, h: 40 }.freeze
  FOLLOWING = { x: 1212, y: 668, w: 52, h: 40 }.freeze
  IDLE_BEFORE_AUTOPLAY = 300
  POINTER_RESTS = 180
  FILM_FOR = 240 # frames, unless the demo names its own
  NUMBER_KEYS = [:one, :two, :three, :four, :five, :six, :seven, :eight, :nine].freeze

  def self.tick(args)
    gallery = args.state.gallery ||= start
    input = read(args, gallery)
    demo = DEMOS[gallery[:index]]
    gallery[:demo] ||= demo.setup
    demo.tick(args, gallery[:demo], input)
    args.outputs.primitives << chrome(demo, gallery[:index])
    gallery[:clock] += 1
    shoot(args, gallery, demo) if gallery[:shots]
    film(args, gallery, demo) if gallery[:film]
  end

  def self.start
    cli = DR.cli_arguments || {}
    index = DEMOS.index { |demo| cli[:demo].to_s == demo::ID } || 0
    { index: index, demo: nil, clock: 0, idle: IDLE_BEFORE_AUTOPLAY,
      shots: !cli[:shots].nil?, film: !cli[:film].nil?, only: !cli[:only].nil?,
      still: POINTER_RESTS, spot: nil }
  end

  def self.show(gallery, index)
    gallery[:index] = index % DEMOS.length
    gallery[:demo] = nil
    gallery[:clock] = 0
    gallery[:idle] = IDLE_BEFORE_AUTOPLAY
  end

  # What the visitor did this frame, in the terms a demo cares about.
  def self.read(args, gallery)
    keys = args.inputs.keyboard.key_down
    click = args.inputs.mouse.click
    step = 0
    step = -1 if keys.left || (click && click.inside_rect?(PREVIOUS))
    step = 1 if keys.right || (click && click.inside_rect?(FOLLOWING))
    show(gallery, gallery[:index] + step) unless step == 0

    number = NUMBER_KEYS.index { |name| keys.send(name) }
    action = step == 0 && (keys.space || !click.nil?)
    gallery[:idle] = action || number ? 0 : gallery[:idle] + 1
    { action: action ? true : false, number: number ? number + 1 : nil, auto: gallery[:idle] >= IDLE_BEFORE_AUTOPLAY,
      mouse: args.inputs.mouse, pointer: pointer(args, gallery) }
  end

  # The mouse position while the mouse has moved lately, otherwise nil: demos
  # that follow the pointer go back to moving by themselves when it rests.
  def self.pointer(args, gallery)
    mouse = args.inputs.mouse
    spot = [mouse.x, mouse.y]
    gallery[:still] = spot == gallery[:spot] ? gallery[:still] + 1 : 0
    gallery[:still] = POINTER_RESTS if gallery[:spot].nil?
    gallery[:spot] = spot
    gallery[:still] < POINTER_RESTS ? { x: mouse.x, y: mouse.y } : nil
  end

  # The bars above and below the demo.
  def self.chrome(demo, index)
    [{ x: 0, y: 656, w: 1280, h: 64, path: :solid, r: 10, g: 12, b: 20, a: 225 },
     { x: 0, y: 0, w: 1280, h: 84, path: :solid, r: 10, g: 12, b: 20, a: 225 },
     button(PREVIOUS, "<"), button(FOLLOWING, ">"),
     Stage.text(640, 688, demo::TITLE, size: 28, align: 0.5),
     Stage.text(1196, 688, "#{index + 1} / #{DEMOS.length}", size: 18, color: Stage::GREY, align: 1),
     Stage.text(84, 688, "lib/vfx/#{demo::ID}.rb", size: 18, color: Stage::GREY),
     Stage.text(640, 56, demo::BLURB, size: 19, align: 0.5),
     Stage.text(640, 26, "#{demo::CONTROLS}    Arrows: other effects", size: 17, color: Stage::GREY, align: 0.5)]
  end

  def self.button(rect, sign)
    [rect.merge(path: :solid, r: 255, g: 255, b: 255, a: 28),
     Stage.text(rect[:x] + (rect[:w] / 2), rect[:y] + (rect[:h] / 2), sign, size: 26, align: 0.5)]
  end

  def self.shoot(args, gallery, demo)
    if gallery[:clock] == demo::SHOT_AT
      args.outputs.screenshots << picture("shots/#{demo::ID}.png")
    elsif gallery[:clock] > demo::SHOT_AT + 2
      following(gallery)
    end
  end

  # Every other frame, so the pictures play back at 30 a second.
  def self.film(args, gallery, demo)
    length = demo.const_defined?(:FILM_FOR) ? demo::FILM_FOR : FILM_FOR
    if gallery[:clock] > length
      following(gallery)
    elsif gallery[:clock].even?
      args.outputs.screenshots << picture("film/#{demo::ID}/#{1000 + gallery[:clock].idiv(2)}.png")
    end
  end

  # The colour named here is saved as transparent, and it defaults to black.
  # Name one no demo draws, so black stays black in the picture.
  def self.picture(path)
    { x: 0, y: 0, w: 1280, h: 720, path: path, r: 255, g: 0, b: 254 }
  end

  def self.following(gallery)
    return DR.request_quit if gallery[:only] || gallery[:index] + 1 >= DEMOS.length

    show(gallery, gallery[:index] + 1)
  end
end
