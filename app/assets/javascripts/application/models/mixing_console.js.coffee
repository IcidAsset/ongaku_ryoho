class OngakuRyoho.Classes.Models.MixingConsole extends Backbone.Model

  defaults:
    duration: 0
    now_playing: "Music Therapy - <strong>Ongaku Ryoho</strong>"
    shuffle: off
    repeat: off
    mute: off
    volume: 50

    # 3-band equalizer
    low_frequency: 250
    low_max_db: 9
    low_gain: 0

    mid_frequency: 2750
    mid_max_db: 9
    mid_gain: 0

    hi_frequency: 8000
    hi_max_db: 9
    hi_gain: 0


  initialize: () ->
    this.on("change:shuffle", OngakuRyoho.People.SoundGuy.set_shuffle)
        .on("change:repeat", OngakuRyoho.People.SoundGuy.set_repeat)
        .on("change:volume", OngakuRyoho.People.SoundGuy.set_volume)
        .on("change:mute", OngakuRyoho.People.SoundGuy.set_mute)
        .on("change:low_gain", OngakuRyoho.People.SoundGuy.set_biquad_filter_gain_values)
        .on("change:mid_gain", OngakuRyoho.People.SoundGuy.set_biquad_filter_gain_values)
        .on("change:hi_gain", OngakuRyoho.People.SoundGuy.set_biquad_filter_gain_values)


  toggle_attribute: (attr) ->
    this.set(attr, !this.get(attr))
