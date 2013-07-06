#= require_self
#= require_tree "./engines"
#= require_tree "./machinery"
#= require_tree "./machinery/record_box"
#= require_tree "./machinery/source_manager"
#= require_tree "./source_types"
#= require_tree "./models"
#= require_tree "./collections"
#= require_tree "./views"
#= require_tree "./views/record_box"
#= require_tree "./views/source_manager"
#= require_tree "./people"

window.OngakuRyoho =

  Classes:
    SourceTypes: {}
    Models: {}
    Collections: {}
    Views: { RecordBox: {}, SourceManager: {} }
    Machinery: { RecordBox: {}, SourceManager: {} }
    People: {}
    Engines: {}
    Routers: {}
