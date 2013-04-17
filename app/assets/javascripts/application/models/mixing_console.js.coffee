class OngakuRyoho.Classes.Models.MixingConsole extends Backbone.Model

  defaults:
    duration: 0
    now_playing: "Music Therapy - <strong>Ongaku Ryoho</strong>"
    shuffle: false
    repeat: false
    mute: false
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
